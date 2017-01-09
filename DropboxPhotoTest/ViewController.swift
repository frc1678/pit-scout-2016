//
//  ViewController.swift
//  DropboxPhotoTest
//
//  Created by Bryton Moeller on 12/30/15.
//  Copyright © 2015 citruscircuits. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
//import SwiftyDropbox
//import SwiftPhotoGallery
import Haneke
import MWPhotoBrowser

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIScrollViewDelegate, MWPhotoBrowserDelegate {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var bottomScrollViewConstraint: NSLayoutConstraint!
    
    var browser = MWPhotoBrowser()
    var photoManager : PhotoManager!
    var number : Int!
    var firebase = FIRDatabase.database().reference()
    var firebaseStorageRef : FIRStorageReference!
    var ourTeam : FIRDatabaseReference!
    var photos = [MWPhoto]()
    var canViewPhotos : Bool = true //This is for that little time in between when the photo is taken and when it has been passed over to the uploader controller.
    var numberOfImagesOnFirebase = -1
    var notActuallyLeavingViewController = false
    let selectedImageURL = PSUITextInputViewController()
    let imageQueueCache = Shared.imageCache
    let keysList = Shared.dataCache
    
    var activeField : UITextField? {
        didSet {
            scrollPositionBeforeScrollingToTextField = scrollView.contentOffset.y
            self.scrollView.scrollRectToVisible((activeField?.frame)!, animated: true)
        }
    }
    var scrollPositionBeforeScrollingToTextField : CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Dismisses keyboard when tapping outside of keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        self.ourTeam.observeSingleEvent(of: .value, with: { (snap) -> Void in //Updating UI
            
            //Adding the PSUI Elements
            //Buttons
            let screenWidth = Int(self.view.frame.width)
            let addImageButton = PSUIButton(title: "Add Image", width: screenWidth, y: 0, buttonPressed: { (sender) -> () in
                self.notActuallyLeavingViewController = true
                let picker = UIImagePickerController()
                
                picker.sourceType = .camera
                picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)!
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            })
            
            var verticalPlacement : CGFloat = addImageButton.frame.origin.y + addImageButton.frame.height
            
            let longPressImageButton = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.didLongPressImageButton(_:)))
            addImageButton.addGestureRecognizer(longPressImageButton)
            
            self.scrollView.addSubview(addImageButton)
            
            let viewImagesButton = PSUIButton(title: "View Images", width: screenWidth, y: Int(verticalPlacement), buttonPressed: { (sender) -> () in
                self.notActuallyLeavingViewController = true
                self.updateMyPhotos { [unowned self] in
                    let nav = UINavigationController(rootViewController: self.browser)
                    nav.delegate = self
                    self.present(nav, animated: true, completion: {
                        self.browser.reloadData()
                    })
                }
            })
            
            self.scrollView.addSubview(viewImagesButton)
            
            verticalPlacement = viewImagesButton.frame.origin.y + viewImagesButton.frame.height
            
            /* Text Input
            let numberOfWheels = PSUITextInputViewController()
            numberOfWheels.setup("Num. Wheels", firebaseRef: self.ourTeam.child("pitNumberOfWheels"), initialValue: snap.childSnapshot(forPath: "pitNumberOfWheels").value)
            numberOfWheels.neededType = .int */
            
            self.selectedImageURL.setup("Selected Image", firebaseRef: self.ourTeam.child("selectedImageUrl"), initialValue: snap.childSnapshot(forPath: "selectedImageUrl").value)
            self.selectedImageURL.neededType = .string
            
            //Segmented Control
            let programmingLanguage = PSUISegmentedViewController()
            programmingLanguage.setup("Prog. Lang.", firebaseRef: self.ourTeam.child("pitProgrammingLanguage"), initialValue: snap.childSnapshot(forPath: "pitProgrammingLanguage").value)
            programmingLanguage.segments = ["Java", "C++", "Labview", "Other"]
            
            //Switch
            let tankTread = PSUISwitchViewController()
            tankTread.setup("Has Tank Tread", firebaseRef: self.ourTeam.child("pitTankTread"), initialValue: snap.childSnapshot(forPath: "pitTankTread").value)
            
            // Segmented Control
            let pitOrganization = PSUISegmentedViewController()
            pitOrganization.setup("Pit Organization", firebaseRef: self.ourTeam.child("pitOrganization"), initialValue: snap.childSnapshot(forPath: "pitOrganization").value)
            pitOrganization.segments = ["Terrible", "Bad", "Okay", "Good", "Great"]

            // Segmented Control
            let availableWeight = PSUITextInputViewController()
            availableWeight.setup("Available Weight", firebaseRef: self.ourTeam.child("pitAvailableWeight"), initialValue: snap.childSnapshot(forPath: "pitAvailableWeight").value)
            availableWeight.neededType = .int
            
            
            /* //Switch
            let willCheesecake = PSUISwitchViewController()
            willCheesecake.setup("Will Cheesecake", firebaseRef: self.ourTeam.child("pitWillCheesecake"), initialValue: snap.childSnapshot(forPath: "pitWillCheesecake").value) */
            
            // self.addChildViewController(numberOfWheels)
            self.addChildViewController(self.selectedImageURL)
            self.addChildViewController(programmingLanguage)
            self.addChildViewController(tankTread)
            self.addChildViewController(pitOrganization)
            self.addChildViewController(availableWeight)
            //self.addChildViewController(willCheesecake)
            
            for childViewController in self.childViewControllers {
                self.scrollView.addSubview(childViewController.view)
                childViewController.view.frame.origin.y = verticalPlacement
                
                let width = NSLayoutConstraint(item: childViewController.view, attribute: NSLayoutAttribute.width, relatedBy: .equal, toItem: self.scrollView, attribute: .width, multiplier: 1.0, constant: 0)
                let center = NSLayoutConstraint(item: childViewController.view, attribute: NSLayoutAttribute.centerX, relatedBy: .equal, toItem: self.scrollView, attribute: .centerX, multiplier: 1.0, constant: 0)
                
                self.scrollView.addConstraints([width, center])
                
                verticalPlacement = childViewController.view.frame.origin.y + childViewController.view.frame.height
            }
        })
        
        scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: scrollPositionBeforeScrollingToTextField), animated: true)
        
        
        self.ourTeam.child("otherImageUrls").observe(.value, with: { (snap) -> Void in
            if self.numberOfImagesOnFirebase == -1 { //This is the first time that the firebase event gets called, it gets called once nomatter what when you first get here in code.
                self.numberOfImagesOnFirebase = Int(snap.childrenCount)
                self.updateMyPhotos({})
            } else {
                self.numberOfImagesOnFirebase = Int(snap.childrenCount)
                self.updateMyPhotos({})
            }
        })
        
        browser = MWPhotoBrowser.init(delegate: self)
        
        // browser options
        browser.displayActionButton = false; // Show action button to allow sharing, copying, etc (defaults to YES)
        browser.displayNavArrows = true; // Whether to display left and right nav arrows on toolbar (defaults to NO)
        browser.displaySelectionButtons = true; // Whether selection buttons are shown on each image (defaults to NO)
        browser.enableGrid = false; // Whether to allow the viewing of all the photo thumbnails on a grid (defaults to YES)
        browser.autoPlayOnAppear = false; // Auto-play first video
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
        keysList.set(value: [String]().asData(), key: "keys")
        startUploadingImageQueue()
    }
    
    func didLongPressImageButton(_ recognizer: UIGestureRecognizer) {
        notActuallyLeavingViewController = true
        if recognizer.state == UIGestureRecognizerState.ended {
            let picker = UIImagePickerController()
            
            picker.sourceType = .photoLibrary
            picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
            picker.delegate = self
            present(picker, animated: true, completion: nil)
        }
    }
    
    func updateMyPhotos(_ callback: @escaping ()->()) {
        self.photoManager.getSharedURLsForTeam(self.number) { (urls) -> () in
            self.photos.removeAll()
            for url in urls! {
                self.photos.append(MWPhoto(url: URL(string: url as! String)))
            }
            callback()
        }
    }
    
    func numberOfPhotos(in photoBrowser: MWPhotoBrowser!) -> UInt {
        return UInt(self.photos.count)
    }
    
    func photoBrowser(_ photoBrowser: MWPhotoBrowser!, photoAt index: UInt, selectedChanged selected: Bool) {
        if selected {
            self.photoManager.getSharedURLsForTeam(self.number) { (urls) -> () in
                self.dismiss(animated: true, completion: nil)
                self.photoManager.updateUrl(self.number, callback: { i in
                    self.selectedImageURL.set(self.photoManager.makeURLForTeamNumAndImageIndex(self.number, imageIndex: i) as AnyObject)
                })
            }
        }
    }
    
    func photoBrowser(_ photoBrowser: MWPhotoBrowser!, photoAt index: UInt) -> MWPhotoProtocol! {
        return self.photos[Int(index)]
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        notActuallyLeavingViewController = false
        canViewPhotos = false
        picker.dismiss(animated: true, completion: nil)
        self.photos.append(MWPhoto(image: image))
        photoManager.photoSaver.saveImage(image)
        addToFirebaseStorageQueue(image: image)
    }
    //You shold only have to call this once each time the app wakes up
    func startUploadingImageQueue() {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            while true {
                if Reachability.isConnectedToNetwork() {
                    self.keysList.fetch(key: "keys").onSuccess({ (keysData) in
                        let keys = (Array.convertFromData(keysData) ?? []) as [String]
                        var keysToKill = [String]()
                        for key in keys {
                            self.imageQueueCache.fetch(key: key).onSuccess({ (image) in
                                self.storeOnFirebase(image: image, done: { 
                                    keysToKill.append(key)
                                })
                                sleep(60)
                            })
                        }
                        self.keysList.set(value: (keys.filter { !keysToKill.contains($0) }).asData(), key: "keys")
                    })
                }
                sleep(30)
            }
        })
        
    }
    
    func addImageKey(key : String) {
        self.keysList.fetch(key: "keys").onSuccess({ (keysData) in
            var keys = (Array.convertFromData(keysData) ?? []) as [String]
            keys.append(key)
            self.keysList.set(value: keys.asData(), key: "keys")
        })
    }
    
    func addToFirebaseStorageQueue(image: UIImage) {
        let key = String(describing: Date())
        addImageKey(key: key)
        self.imageQueueCache.set(value: image, key: key)
    }
    
    func storeOnFirebase(image: UIImage, done: @escaping ()->()) {
            self.photoManager.updateUrl(self.number, callback: { [unowned self] i in
                let name = self.photoManager.makeFilenameForTeamNumAndIndex(self.number, imageIndex: i)
                
                self.firebaseStorageRef.child(name).put(UIImagePNGRepresentation(image)!, metadata: nil) { metadata, error in
                    
                    if (error != nil) {
                        print("ERROR: \(error)")
                    } else {
                        // Metadata contains file metadata such as size, content-type, and download URL.
                        let downloadURL = metadata!.downloadURL()?.absoluteString
                        self.photoManager.putPhotoLinkToFirebase(downloadURL!, teamNumber: self.number, selectedImage: false)
                        
                        print("UPLOADED: \(downloadURL)")
                        done()
                    }
                }
                self.canViewPhotos = true
            })
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { // So that the scroll view can scroll so you can see the text field you are editing
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        activeField = textField
    }
    
    func keyboardWillHide(_ notification:Notification){
        scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: scrollPositionBeforeScrollingToTextField), animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func isNull(_ object: AnyObject?) -> Bool {
        if object_getClass(object) == object_getClass(NSNull()) {
            return true
        }
        return false
    }
    
    override var shouldAutorotate : Bool {
        return false
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        notActuallyLeavingViewController = false
    }
    
    override func viewWillDisappear(_ animated: Bool) { //If you are leaving the view controller, and only have one image, make that the selected one.
        super.viewWillDisappear(animated)
        self.photoManager.getSharedURLsForTeam(self.number) { (urls) -> () in
            if urls?.count == 1 {
                self.selectedImageURL.set(self.photoManager.makeURLForTeamNumAndImageIndex(self.number, imageIndex: 0) as AnyObject)
            }
        }
    }
    
    func dismissKeyboard () {
        view.endEditing(true)
    }
    
}



extension Dictionary {
    var vals : [AnyObject] {
        var v = [AnyObject]()
        for (_, value) in self {
            v.append(value as AnyObject)
        }
        return v
    }
    var keys : [AnyObject] {
        var k = [AnyObject]()
        for (key, _) in self {
            k.append(key as AnyObject)
        }
        return k
    }
    var FIRJSONString : String {
        //if self.keys[0] as? String != nil && self.vals[0] as? String != nil {
            var JSONString = "{\n"
            for i in 0..<self.keys.count {
                JSONString.append(keys[i] as! String)
                JSONString.append(" : ")
                JSONString.append(String(describing: vals[i]))
                JSONString.append("\n")
            }
            JSONString.append("}")
            return JSONString
        /*} else {
            return "Not of Type [String: String], so cannot use FIRJSONString."
        }*/
    }
}

extension Array : DataConvertible, DataRepresentable {
    
    public typealias Result = Array
    
    public static func convertFromData(_ data:Data) -> Result? {
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? Array
    }
    
    public func asData() -> Data! {
        return NSKeyedArchiver.archivedData(withRootObject: self)
    }
    
}
