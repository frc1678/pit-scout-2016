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
import SwiftyDropbox
import SwiftPhotoGallery
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
        
        self.ourTeam.observeSingleEventOfType(.Value, withBlock: { (snap) -> Void in //Updating UI
            
            //Adding the PSUI Elements
            //Buttons
            let screenWidth = Int(self.view.frame.width)
            let addImageButton = PSUIButton(title: "Add Image", width: screenWidth, y: 0, buttonPressed: { (sender) -> () in
                self.notActuallyLeavingViewController = true
                let picker = UIImagePickerController()
                
                picker.sourceType = .Camera
                picker.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(.Camera)!
                picker.delegate = self
                self.presentViewController(picker, animated: true, completion: nil)
            })
            
            var verticalPlacement : CGFloat = addImageButton.frame.origin.y + addImageButton.frame.height
            
            let longPressImageButton = UILongPressGestureRecognizer(target: self, action: "didLongPressImageButton:")
            addImageButton.addGestureRecognizer(longPressImageButton)
            
            self.scrollView.addSubview(addImageButton)
            
            let viewImagesButton = PSUIButton(title: "View Images", width: screenWidth, y: Int(verticalPlacement), buttonPressed: { (sender) -> () in
                self.notActuallyLeavingViewController = true
                self.updateMyPhotos { [unowned self] in
                    let nav = UINavigationController(rootViewController: self.browser)
                    nav.delegate = self
                    self.presentViewController(nav, animated: true, completion: {
                        self.browser.reloadData()
                    })
                }
            })
            
            self.scrollView.addSubview(viewImagesButton)
            
            verticalPlacement = viewImagesButton.frame.origin.y + viewImagesButton.frame.height
            
            //Text Input
            let numberOfWheels = PSUITextInputViewController()
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
            
            for childViewController in self.childViewControllers {
                self.scrollView.addSubview(childViewController.view)
                childViewController.view.frame.origin.y = verticalPlacement
                
                let width = NSLayoutConstraint(item: childViewController.view, attribute: NSLayoutAttribute.Width, relatedBy: .Equal, toItem: self.scrollView, attribute: .Width, multiplier: 1.0, constant: 0)
                let center = NSLayoutConstraint(item: childViewController.view, attribute: NSLayoutAttribute.CenterX, relatedBy: .Equal, toItem: self.scrollView, attribute: .CenterX, multiplier: 1.0, constant: 0)
                
                self.scrollView.addConstraints([width, center])
                
                verticalPlacement = childViewController.view.frame.origin.y + childViewController.view.frame.height
            }
            
        })
        
        scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: scrollPositionBeforeScrollingToTextField), animated: true)
        
        
        self.ourTeam.child("otherImageUrls").observeEventType(.Value, withBlock: { (snap) -> Void in
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
            }
            callback()
        }
    }
    
    func numberOfPhotosInPhotoBrowser(photoBrowser: MWPhotoBrowser!) -> UInt {
        return UInt(self.photos.count)
    }
    
    func photoBrowser(photoBrowser: MWPhotoBrowser!, photoAtIndex index: UInt, selectedChanged selected: Bool) {
        if selected {
            self.photoManager.getSharedURLsForTeam(self.number) { (urls) -> () in
                self.dismissViewControllerAnimated(true, completion: nil)
                self.photoManager.updateUrl(self.number, callback: { i in
                    self.selectedImageURL.set(self.photoManager.makeURLForTeamNumAndImageIndex(self.number, imageIndex: i))
                })
            }
        }
    }
    
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
                    
                    if (error != nil) {
                        print("ERROR: \(error)")
                    } else {
                        // Metadata contains file metadata such as size, content-type, and download URL.
                        let downloadURL = metadata!.downloadURL()?.absoluteString
                        print("UPLOADED: \(downloadURL)")
                    }
                }
                self.canViewPhotos = true
                })
        })
    }
    
    
    
    func galleryDidTapToClose(gallery:SwiftPhotoGallery) {
        self.photoManager.getSharedURLsForTeam(self.number) { (urls) -> () in
            self.dismissViewControllerAnimated(true, completion: nil)
            self.photoManager.updateUrl(self.number, callback: {_ in })
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool { // So that the scroll view can scroll so you can see the text field you are editing
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
        activeField = textField
    }
    
    func keyboardWillHide(notification:NSNotification){
        scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: scrollPositionBeforeScrollingToTextField), animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func isNull(object: AnyObject?) -> Bool {
        if object_getClass(object) == object_getClass(NSNull()) {
            return true
        }
        return false
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func viewDidAppear(animated: Bool) {
        notActuallyLeavingViewController = false
    }
    
}


extension Dictionary {
    var vals : [AnyObject] {
        var v = [AnyObject]()
        for (_, value) in self {
            v.append(value as! AnyObject)
        }
        return v
    }
}
