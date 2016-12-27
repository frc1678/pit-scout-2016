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
<<<<<<< HEAD
//import SwiftyDropbox
//import SwiftPhotoGallery
=======
import SwiftyDropbox
import SwiftPhotoGallery
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
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
    
    var activeField : UITextField? {
        didSet {
            scrollPositionBeforeScrollingToTextField = scrollView.contentOffset.y
            self.scrollView.scrollRectToVisible((activeField?.frame)!, animated: true)
        }
    }
    var scrollPositionBeforeScrollingToTextField : CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
<<<<<<< HEAD
        self.ourTeam.observeSingleEvent(of: .value, with: { (snap) -> Void in //Updating UI
=======
        self.ourTeam.observeSingleEventOfType(.Value, withBlock: { (snap) -> Void in //Updating UI
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
            
            //Adding the PSUI Elements
            //Buttons
            let screenWidth = Int(self.view.frame.width)
            let addImageButton = PSUIButton(title: "Add Image", width: screenWidth, y: 0, buttonPressed: { (sender) -> () in
                self.notActuallyLeavingViewController = true
                let picker = UIImagePickerController()
                
<<<<<<< HEAD
                picker.sourceType = .camera
                picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)!
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
=======
                picker.sourceType = .Camera
                picker.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(.Camera)!
                picker.delegate = self
                self.presentViewController(picker, animated: true, completion: nil)
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
            })
            
            var verticalPlacement : CGFloat = addImageButton.frame.origin.y + addImageButton.frame.height
            
<<<<<<< HEAD
            let longPressImageButton = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.didLongPressImageButton(_:)))
=======
            let longPressImageButton = UILongPressGestureRecognizer(target: self, action: "didLongPressImageButton:")
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
            addImageButton.addGestureRecognizer(longPressImageButton)
            
            self.scrollView.addSubview(addImageButton)
            
            let viewImagesButton = PSUIButton(title: "View Images", width: screenWidth, y: Int(verticalPlacement), buttonPressed: { (sender) -> () in
                self.notActuallyLeavingViewController = true
                self.updateMyPhotos { [unowned self] in
                    let nav = UINavigationController(rootViewController: self.browser)
                    nav.delegate = self
<<<<<<< HEAD
                    self.present(nav, animated: true, completion: {
=======
                    self.presentViewController(nav, animated: true, completion: {
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
                        self.browser.reloadData()
                    })
                }
            })
            
            self.scrollView.addSubview(viewImagesButton)
            
            verticalPlacement = viewImagesButton.frame.origin.y + viewImagesButton.frame.height
            
            //Text Input
            let numberOfWheels = PSUITextInputViewController()
<<<<<<< HEAD
            numberOfWheels.setup("Num. Wheels", firebaseRef: self.ourTeam.child("pitNumberOfWheels"), initialValue: snap.childSnapshot(forPath: "pitNumberOfWheels").value)
            numberOfWheels.neededType = .int
            
            /*let availWeight = PSUITextInputViewController()
            availWeight.setup("Avail. Weight", firebaseRef: self.ourTeam.child("pitAvailableWeight"), initialValue: snap.childSnapshot(forPath: "pitAvailableWeight").value)
            availWeight.neededType = .float
            */
            self.selectedImageURL.setup("Selected Image", firebaseRef: self.ourTeam.child("selectedImageUrl"), initialValue: snap.childSnapshot(forPath: "selectedImageUrl").value)
            self.selectedImageURL.neededType = .string
            
            //Segmented Control
           /* let programmingLanguage = PSUISegmentedViewController()
            programmingLanguage.setup("Prog. Lang.", firebaseRef: self.ourTeam.child("pitProgrammingLanguage"), initialValue: snap.childSnapshot(forPath: "pitProgrammingLanguage").value)
            programmingLanguage.segments = ["Java", "C++", "Labview", "Other"]            //Switch
            let willCheesecake = PSUISwitchViewController()
            willCheesecake.setup("Will Cheesecake", firebaseRef: self.ourTeam.child("pitWillCheesecake"), initialValue: snap.childSnapshot(forPath: "pitWillCheesecake").value)
            */
            
            self.addChildViewController(numberOfWheels)
            //self.addChildViewController(availWeight)
            self.addChildViewController(self.selectedImageURL)
            //self.addChildViewController(programmingLanguage)
            //self.addChildViewController(willCheesecake)
=======
            numberOfWheels.setup("Num. Wheels", firebaseRef: self.ourTeam.child("pitNumberOfWheels"), initialValue: snap.childSnapshotForPath("pitNumberOfWheels").value as? Int ?? -2)
            numberOfWheels.neededType = .Int
            
            let availWeight = PSUITextInputViewController()
            availWeight.setup("Avail. Weight", firebaseRef: self.ourTeam.child("pitAvailableWeight"), initialValue: snap.childSnapshotForPath("pitAvailableWeight").value as? Double ?? -2)
            availWeight.neededType = .Float
            
            self.selectedImageURL.setup("Selected Image", firebaseRef: self.ourTeam.child("selectedImageUrl"), initialValue: snap.childSnapshotForPath("selectedImageUrl").value as? String ?? "-2")
            self.selectedImageURL.neededType = .String
            
            //Segmented Control
            let programmingLanguage = PSUISegmentedViewController()
            programmingLanguage.setup("Prog. Lang.", firebaseRef: self.ourTeam.child("pitProgrammingLanguage"), initialValue: snap.childSnapshotForPath("pitProgrammingLanguage").value as? Int ?? -2)
            //Switch
            let willCheesecake = PSUISwitchViewController()
            willCheesecake.setup("Will Cheesecake", firebaseRef: self.ourTeam.child("pitWillCheesecake"), initialValue: snap.childSnapshotForPath("pitWillCheesecake").value as? Bool ?? false)
            
            
            self.addChildViewController(numberOfWheels)
            self.addChildViewController(availWeight)
            self.addChildViewController(self.selectedImageURL)
            self.addChildViewController(programmingLanguage)
            self.addChildViewController(willCheesecake)
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
            
            for childViewController in self.childViewControllers {
                self.scrollView.addSubview(childViewController.view)
                childViewController.view.frame.origin.y = verticalPlacement
                
<<<<<<< HEAD
                let width = NSLayoutConstraint(item: childViewController.view, attribute: NSLayoutAttribute.width, relatedBy: .equal, toItem: self.scrollView, attribute: .width, multiplier: 1.0, constant: 0)
                let center = NSLayoutConstraint(item: childViewController.view, attribute: NSLayoutAttribute.centerX, relatedBy: .equal, toItem: self.scrollView, attribute: .centerX, multiplier: 1.0, constant: 0)
=======
                let width = NSLayoutConstraint(item: childViewController.view, attribute: NSLayoutAttribute.Width, relatedBy: .Equal, toItem: self.scrollView, attribute: .Width, multiplier: 1.0, constant: 0)
                let center = NSLayoutConstraint(item: childViewController.view, attribute: NSLayoutAttribute.CenterX, relatedBy: .Equal, toItem: self.scrollView, attribute: .CenterX, multiplier: 1.0, constant: 0)
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
                
                self.scrollView.addConstraints([width, center])
                
                verticalPlacement = childViewController.view.frame.origin.y + childViewController.view.frame.height
            }
            
        })
        
        scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: scrollPositionBeforeScrollingToTextField), animated: true)
        
        
<<<<<<< HEAD
        self.ourTeam.child("otherImageUrls").observe(.value, with: { (snap) -> Void in
=======
        self.ourTeam.child("otherImageUrls").observeEventType(.Value, withBlock: { (snap) -> Void in
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
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
        
<<<<<<< HEAD
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
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
=======
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
    }
    
    func didLongPressImageButton(recognizer: UIGestureRecognizer) {
        notActuallyLeavingViewController = true
        if recognizer.state == UIGestureRecognizerState.Ended {
            let picker = UIImagePickerController()
            
            picker.sourceType = .PhotoLibrary
            picker.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(.PhotoLibrary)!
            picker.delegate = self
            presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    func updateMyPhotos(callback: ()->()) {
        self.photoManager.getSharedURLsForTeam(self.number) { (urls) -> () in
            self.photos.removeAll()
            for url in urls! {
                self.photos.append(MWPhoto(URL: NSURL(string: url as! String)))
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
            }
            callback()
        }
    }
    
<<<<<<< HEAD
    func numberOfPhotos(in photoBrowser: MWPhotoBrowser!) -> UInt {
        return UInt(self.photos.count)
    }
    
    func photoBrowser(_ photoBrowser: MWPhotoBrowser!, photoAt index: UInt, selectedChanged selected: Bool) {
        if selected {
            self.photoManager.getSharedURLsForTeam(self.number) { (urls) -> () in
                self.dismiss(animated: true, completion: nil)
                self.photoManager.updateUrl(self.number, callback: { i in
                    self.selectedImageURL.set(self.photoManager.makeURLForTeamNumAndImageIndex(self.number, imageIndex: i) as AnyObject)
=======
    func numberOfPhotosInPhotoBrowser(photoBrowser: MWPhotoBrowser!) -> UInt {
        return UInt(self.photos.count)
    }
    
    func photoBrowser(photoBrowser: MWPhotoBrowser!, photoAtIndex index: UInt, selectedChanged selected: Bool) {
        if selected {
            self.photoManager.getSharedURLsForTeam(self.number) { (urls) -> () in
                self.dismissViewControllerAnimated(true, completion: nil)
                self.photoManager.updateUrl(self.number, callback: { i in
                    self.selectedImageURL.set(self.photoManager.makeURLForTeamNumAndImageIndex(self.number, imageIndex: i))
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
                })
            }
        }
    }
    
<<<<<<< HEAD
    func photoBrowser(_ photoBrowser: MWPhotoBrowser!, photoAt index: UInt) -> MWPhotoProtocol! {
        return self.photos[Int(index)]
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        notActuallyLeavingViewController = false
        canViewPhotos = false
        picker.dismiss(animated: true, completion: nil)
        self.photos.append(MWPhoto(image: image))
        photoManager.photoSaver.saveImage(image)
        
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            self.photoManager.updateUrl(self.number, callback: { [unowned self] i in
                let name = self.photoManager.makeFilenameForTeamNumAndIndex(self.number, imageIndex: i)

                self.firebaseStorageRef.child(name).put(UIImagePNGRepresentation(image)!, metadata: nil) { metadata, error in
=======
    func photoBrowser(photoBrowser: MWPhotoBrowser!, photoAtIndex index: UInt) -> MWPhotoProtocol! {
        return self.photos[Int(index)]
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        notActuallyLeavingViewController = false
        canViewPhotos = false
        picker.dismissViewControllerAnimated(true, completion: nil)
        self.photos.append(MWPhoto(image: image))
        photoManager.photoSaver.saveImage(image)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            self.photoManager.updateUrl(self.number, callback: { [unowned self] i in
                
                self.firebaseStorageRef.child(self.photoManager.makeFilenameForTeamNumAndIndex(self.number, imageIndex: i)).putData(UIImagePNGRepresentation(image)!, metadata: nil) { metadata, error in
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
                    
                    if (error != nil) {
                        print("ERROR: \(error)")
                    } else {
                        // Metadata contains file metadata such as size, content-type, and download URL.
                        let downloadURL = metadata!.downloadURL()?.absoluteString
<<<<<<< HEAD
                        self.photoManager.putPhotoLinkToFirebase(downloadURL!, teamNumber: self.number, selectedImage: false)

=======
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
                        print("UPLOADED: \(downloadURL)")
                    }
                }
                self.canViewPhotos = true
                })
        })
    }
    
    
    
<<<<<<< HEAD
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { // So that the scroll view can scroll so you can see the text field you are editing
=======
    func galleryDidTapToClose(gallery:SwiftPhotoGallery) {
        self.photoManager.getSharedURLsForTeam(self.number) { (urls) -> () in
            self.dismissViewControllerAnimated(true, completion: nil)
            self.photoManager.updateUrl(self.number, callback: {_ in })
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool { // So that the scroll view can scroll so you can see the text field you are editing
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        textField.resignFirstResponder()
        return true
    }
    
<<<<<<< HEAD
    func textFieldDidBeginEditing(_ textField: UITextField)
=======
    func textFieldDidBeginEditing(textField: UITextField)
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
    {
        activeField = textField
    }
    
<<<<<<< HEAD
    func keyboardWillHide(_ notification:Notification){
=======
    func keyboardWillHide(notification:NSNotification){
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: scrollPositionBeforeScrollingToTextField), animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
<<<<<<< HEAD
    func isNull(_ object: AnyObject?) -> Bool {
=======
    func isNull(object: AnyObject?) -> Bool {
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        if object_getClass(object) == object_getClass(NSNull()) {
            return true
        }
        return false
    }
    
<<<<<<< HEAD
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
=======
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func viewDidAppear(animated: Bool) {
        notActuallyLeavingViewController = false
    }
    
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
}


extension Dictionary {
    var vals : [AnyObject] {
        var v = [AnyObject]()
        for (_, value) in self {
<<<<<<< HEAD
            v.append(value as AnyObject)
=======
            v.append(value as! AnyObject)
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        }
        return v
    }
}
