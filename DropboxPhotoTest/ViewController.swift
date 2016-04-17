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


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIScrollViewDelegate, SwiftPhotoGalleryDataSource, SwiftPhotoGalleryDelegate, MWPhotoBrowserDelegate {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var viewImagesButton: UIButton!
    @IBOutlet weak var pitNumberOfWheels: UITextField!
    @IBOutlet weak var pitOrganization:UISegmentedControl!
    @IBOutlet weak var selectedImageUrl: UITextField!
    @IBOutlet weak var bottomScrollViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var pitBumperHeight: UITextField!
    
    @IBOutlet weak var pitNotes: UITextField!
    @IBOutlet weak var pitProgrammingLanguage: UISegmentedControl!
    @IBOutlet weak var pitAvailableWeight: UITextField!
    
    var browser = MWPhotoBrowser()
    var photoManager : PhotoManager!
    var name = String()
    var numberOfWheels = Int()
    var pitOrg  = Int()
    var number : Int!
    var firebase : Firebase!
    var ourTeam : Firebase!
    var photos = [MWPhoto]()
    var tempPhotos = [UIImage]() //So that the photos dataset cant change while we are viewing them
    var canViewPhotos : Bool = true //This is for that little time in between when the photo is taken and when it has been passed over to the uploader controller.
    var firebaseKeys = [String]()
    var numberOfImagesOnFirebase = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageButton.setTitle("WAIT", forState: UIControlState.Disabled)
        self.imageButton.setTitleColor(UIColor.redColor(), forState: UIControlState.Disabled)
        //self.scrollView.scrollEnabled = false //THIS IS FOR WHEN THERE IS NOT MUCH DATA ON THE SCREEN, FOR CVR WE ACTUALLY NEEDED SCROLLING
        //self.imageButton.setTitle(self.imageButton.titleLabel?.text, forState: UIControlState.Normal)
        //self.imageButton.setTitleColor(, forState: UIControlState.Normal)
        
        
        self.photoManager.currentlyNotifyingTeamNumber = self.number
        
        self.photoManager.callbackForPhotoCasheUpdated = { () in
            self.updateMyPhotos(false)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.imageButton.enabled = true
            })
        }
        
        let longPress = UILongPressGestureRecognizer(target: self, action: "didLongPress:")
        self.imageButton.addGestureRecognizer(longPress)
        
        self.ourTeam.observeSingleEventOfType(.Value, withBlock: { (snap) -> Void in //Updating UI
            //self.title?.appendContentsOf(" - \(snap.childSnapshotForPath("name").value)") //Sometimes it is too long to fit
            for key in self.firebaseKeys {
                if let value = snap.childSnapshotForPath(key).value {
                    if !self.isNull(value) {
                        let myObj = self.valueForKey(key)
                        if object_getClass(myObj) == object_getClass(UITextField()) {
                            myObj?.setValue("\(value)", forKey: "text")
                        } else if object_getClass(myObj) == object_getClass(UISegmentedControl()) {
                            myObj?.setValue(value as! Int, forKey: "selectedSegmentIndex")
                            myObj?.setValue(true, forKey: "selected")
                        } else if object_getClass(myObj) == object_getClass(UISwitch()) {
                            (myObj as! UISwitch).setOn(Bool(value as! NSNumber), animated: true)
                        } else {
                            print("This should not happen")
                        }
                    }
                }
            }
        })
        
        self.ourTeam.childByAppendingPath("otherImageUrls").observeEventType(.Value, withBlock: { (snap) -> Void in
            if self.numberOfImagesOnFirebase == -1 { //This is the first time that the firebase event gets called, it gets called once nomatter what when you first get here in code.
                self.numberOfImagesOnFirebase = Int(snap.childrenCount)
                self.updateMyPhotos(true)
            } else {
                self.numberOfImagesOnFirebase = Int(snap.childrenCount)
                self.updateMyPhotos(false)
            }
        })
        
        
        
        
        browser = MWPhotoBrowser.init(delegate: self)
        
        // Set options
        browser.displayActionButton = false; // Show action button to allow sharing, copying, etc (defaults to YES)
        browser.displayNavArrows = true; // Whether to display left and right nav arrows on toolbar (defaults to NO)
        browser.displaySelectionButtons = true; // Whether selection buttons are shown on each image (defaults to NO)
        browser.zoomPhotosToFill = true; // Images that almost fill the screen will be initially zoomed to fill (defaults to YES)
        browser.alwaysShowControls = false; // Allows to control whether the bars and controls are always visible or whether they fade away to show the photo full (defaults to NO)
        browser.enableGrid = false; // Whether to allow the viewing of all the photo thumbnails on a grid (defaults to YES)
        browser.startOnGrid = false; // Whether to start on the grid of thumbnails instead of the first photo (defaults to NO)
        browser.autoPlayOnAppear = false; // Auto-play first video
        
        
               // Present
        
 
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
        
        self.updatePhotoButtonText()
    }
    
    func updateMyPhotos(download: Bool) {
        self.photos = []
        self.tempPhotos = []
        if self.photos.count < self.numberOfImagesOnFirebase {
            /*self.photoManager.getPhotosForTeamNum(self.number, download: download, success: { [weak self] in
                if let weakSelf = self {
                    for photo : [String: AnyObject] in weakSelf.photoManager.activeImages {
                        if photo.keys.count > 0 {
                            weakSelf.photos.append(UIImage(data: photo["data"] as! NSData)!)
                        }
                    }
                    weakSelf.updatePhotoButtonText()
                }
                })
                
                
               */
            self.photoManager.getSharedURLsForTeam(self.number) { (urls) -> () in
                self.photos.removeAll()
                self.browser.releaseAllUnderlyingPhotos(false)
                for url in urls! {
                    self.photos.append(MWPhoto(URL: NSURL(string: url as! String)))
                }
            }
            
            self.updatePhotoButtonText()

        }
    }
    
    func updatePhotoButtonText() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            //let photosCount : Int = self.photos.count
            self.viewImagesButton.setTitle("View Images: (\(self.numberOfImagesOnFirebase))", forState: UIControlState.Normal)
        }
        
    }
    
    //MARK: Responding To UI Actions:
    //MARK: --> Text Fields
    @IBAction func pitNotesEditingEnded(sender: UITextField) {
        self.ourTeam?.childByAppendingPath("pitNotes").setValue(self.pitNotes.text)
    }
    
    @IBAction func numWheelsEditingEnded(sender: UITextField) {
        if(sender.text != "") {
            if let numWheels = Int(sender.text!) {
                self.numberOfWheels = numWheels
                self.ourTeam?.childByAppendingPath("pitNumberOfWheels").setValue(self.numberOfWheels)
            }
        }
    }
    
    @IBAction func bumperHeightDidChange(sender: UITextField) {
        if let num = Float(self.pitBumperHeight.text!)  {
            self.ourTeam?.childByAppendingPath("pitBumperHeight").setValue(Float(num))
            self.pitBumperHeight.backgroundColor = UIColor.whiteColor()
        } else {
            self.pitBumperHeight.backgroundColor = UIColor.redColor()
        }
    }
    
    @IBAction func selectedImageEditingEnded(sender: UITextField) {
        self.ourTeam?.childByAppendingPath("selectedImageUrl").setValue(self.selectedImageUrl.text)
    }
    
    @IBAction func pitAvailableWeightDidChange(sender: AnyObject) {
        if let num = Float(self.pitAvailableWeight.text!)  {
            self.ourTeam?.childByAppendingPath("pitAvailableWeight").setValue(Float(num))
            self.pitAvailableWeight.backgroundColor = UIColor.whiteColor()
        } else {
            self.pitAvailableWeight.backgroundColor = UIColor.redColor()
        }
    }
    
    
    //MARK: --> Segmented Controls
    @IBAction func pitProgrammingLanguageDidChange(sender: UISegmentedControl) {
        self.ourTeam?.childByAppendingPath("pitProgrammingLanguage").setValue(sender.selectedSegmentIndex)
    }
    
    @IBAction func lowBarPotentialDidChange(sender: UISegmentedControl) {
        self.ourTeam?.childByAppendingPath("pitPotentialLowBarCapability").setValue(sender.selectedSegmentIndex)
    }
    
    @IBAction func pitOrgValueChanged(sender: UISegmentedControl) {
        if self.pitOrg != sender.selectedSegmentIndex {
            self.pitOrg = sender.selectedSegmentIndex
            self.ourTeam?.childByAppendingPath("pitOrganization").setValue(sender.selectedSegmentIndex)
        }
        
    }
    
    @IBAction func midlineBallCheesecakePotentialDidChange(sender: UISegmentedControl) {
        self.ourTeam?.childByAppendingPath("pitPotentialMidlineBallCapability").setValue(sender.selectedSegmentIndex)
    }
    
    //MARK: --> Switches
    @IBAction func lowBarTestResultChanged(sender: UISwitch) {
        self.ourTeam.childByAppendingPath("pitLowBarCapability").setValue(sender.on)
    }
    
    //MARK: --> Buttons
    @IBAction func cameraButtonPressed(sender: UIButton) {
        
        let picker = UIImagePickerController()
        
        picker.sourceType = .Camera
        picker.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(.Camera)!
        picker.delegate = self
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func didLongPress(recognizer: UIGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.Ended {
            let picker = UIImagePickerController()
            
            picker.sourceType = .PhotoLibrary
            picker.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(.PhotoLibrary)!
            picker.delegate = self
            presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    @IBAction func didPressShowMeButton(sender: UIButton) {
        self.updateMyPhotos(false)
        let nav = UINavigationController(rootViewController: browser)
        nav.delegate = self
        self.presentViewController(nav, animated: true, completion: nil)

        /*if self.photos.count > 0 && self.canViewPhotos {
            self.tempPhotos = self.photos
            let gallery = SwiftPhotoGallery(delegate: self, dataSource: self)
            presentViewController(gallery, animated: true, completion: nil)
        }*/
    }
    
    
    
    // MARK: SwiftPhotoGalleryDataSource Methods
    
    func numberOfImagesInGallery(gallery:SwiftPhotoGallery) -> Int {
        return self.tempPhotos.count //Actually counting the available ones
    }
    
    func numberOfPhotosInPhotoBrowser(photoBrowser: MWPhotoBrowser!) -> UInt {
        return UInt(self.photos.count)
    }
    
    func imageInGallery(gallery:SwiftPhotoGallery, forIndex:Int) -> UIImage? {
        var rotatedImage = UIImage(named: "notAvail")
        if self.tempPhotos.count > forIndex {
            let image = self.tempPhotos[forIndex]
            rotatedImage = UIImage(CGImage: image.CGImage!,
                scale: 1.0,
                orientation: UIImageOrientation.Right)
        }
        return rotatedImage
    }
    
    func photoBrowser(photoBrowser: MWPhotoBrowser!, photoAtIndex index: UInt, selectedChanged selected: Bool) {
        if selected {
            let i = Int(index)
            self.photoManager.getSharedURLsForTeam(self.number) { (urls) -> () in
                let url = self.photoManager.makeURLForTeamNumAndImageIndex(self.number, imageIndex: i)
                self.selectedImageUrl.text = url
                self.selectedImageEditingEnded(self.selectedImageUrl)
                
                self.dismissViewControllerAnimated(true, completion: nil)
                self.photoManager.updateUrl(self.number, callback: {_ in })
                
                /*
                let alert = UIAlertController(title: "Image Not Uploaded", message: "Please wait for the image to be uploaded, before trying to set it as the selected image. If we set the selected image url before the image exists on Dropbox, then the viewers might get confused.", preferredStyle: UIAlertControllerStyle.Alert)
                // Do something when message is tapped
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.dismissViewControllerAnimated(true, completion: nil)
                self.presentViewController(alert, animated: true, completion: nil)*/
                
                
            }
        }
    }
    
    func photoBrowser(photoBrowser: MWPhotoBrowser!, photoAtIndex index: UInt) -> MWPhotoProtocol! {
        return self.photos[Int(index)]
    }
    
    // MARK: Swift Photo Gallery Methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.canViewPhotos = false
        self.imageButton.enabled = false
        //self.imageButton.imageView?.image = image
        picker.dismissViewControllerAnimated(true, completion: nil)
        //let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        //presentViewController(activityViewController, animated: true, completion: {})
        self.photoManager.photoSaver.saveImage(image)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            self.photoManager.updateUrl(self.number, callback: { [unowned self] i in
                self.photoManager.addFileToLineup(UIImagePNGRepresentation(image)!, fileName: self.photoManager.makeFilenameForTeamNumAndIndex(self.number, imageIndex: i), teamNumber: self.number, shouldUpload: true)
                self.canViewPhotos = true
                })
        })
        
    }
    
    
    
    func galleryDidTapToClose(gallery:SwiftPhotoGallery) {
        self.photoManager.getSharedURLsForTeam(self.number) { (urls) -> () in
            let url = self.photoManager.makeURLForTeamNumAndImageIndex(self.number, imageIndex: gallery.currentPage)
            self.selectedImageUrl.text = url
            self.selectedImageEditingEnded(self.selectedImageUrl)
            
            self.dismissViewControllerAnimated(true, completion: nil)
            self.photoManager.updateUrl(self.number, callback: {_ in })
            
            /*
            let alert = UIAlertController(title: "Image Not Uploaded", message: "Please wait for the image to be uploaded, before trying to set it as the selected image. If we set the selected image url before the image exists on Dropbox, then the viewers might get confused.", preferredStyle: UIAlertControllerStyle.Alert)
            // Do something when message is tapped
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.dismissViewControllerAnimated(true, completion: nil)
            self.presentViewController(alert, animated: true, completion: nil)*/
            
            
        }
    }
    
    //MARK: Keyboard UI Methods
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func keyboardWillShow(notification:NSNotification){
        
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        keyboardFrame = self.view.convertRect(keyboardFrame, fromView: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.scrollView.contentInset = contentInset
        self.scrollView.scrollRectToVisible(self.pitNotes.frame, animated: true)
    }
    
    func keyboardWillHide(notification:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsetsMake(50.0, 0, 0, 0) // Terrible and sketchy, but works.
        self.scrollView.contentInset = contentInset
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("Oh No, Mem warning!")
        //self.photoManager.mayKeepWorking = false
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
    
   
}

