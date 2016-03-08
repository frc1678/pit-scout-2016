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


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIScrollViewDelegate, SwiftPhotoGalleryDataSource, SwiftPhotoGalleryDelegate {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var viewImagesButton: UIButton!
    @IBOutlet weak var pitNumberOfWheels: UITextField!
    @IBOutlet weak var pitOrganization:UISegmentedControl!
    @IBOutlet weak var selectedImageUrl: UITextField!
    @IBOutlet weak var bottomScrollViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var pitDriveBaseWidth: UITextField!
    @IBOutlet weak var pitDriveBaseLength: UITextField!
    @IBOutlet weak var pitBumperHeight: UITextField!
    @IBOutlet weak var pitPotentialMidlineBallCapability: UISegmentedControl!
    @IBOutlet weak var pitPotentialShotBlockerCapability: UISegmentedControl!
    @IBOutlet weak var pitPotentialLowBarCapability: UISegmentedControl!
    @IBOutlet weak var pitLowBarCapability: UISwitch!
    @IBOutlet weak var pitNotes: UITextField!
    @IBOutlet weak var pitHeightOfBallLeavingShooter: UITextField!
    
    var photoManager : PhotoManager!
    var name = String()
    var numberOfWheels = Int()
    var pitOrg  = Int()
    var number : Int!
    var firebase : Firebase!
    var ourTeam : Firebase!
    var photos = [UIImage]()
    var tempPhotos = [UIImage]() //So that the photos dataset cant change while we are viewing them
    var canViewPhotos : Bool = true //This is for that little time in between when the photo is taken and when it has been passed over to the uploader controller.
    var firebaseKeys = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageButton.setTitle("WAIT", forState: UIControlState.Disabled)
        self.imageButton.setTitleColor(UIColor.redColor(), forState: UIControlState.Disabled)
        //self.imageButton.setTitle(self.imageButton.titleLabel?.text, forState: UIControlState.Normal)
        //self.imageButton.setTitleColor(, forState: UIControlState.Normal)

        
        self.photoManager.currentlyNotifyingTeamNumber = self.number

        self.photoManager.callbackForPhotoCasheUpdated = { [unowned self] () in
            self.updateMyPhotos()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.imageButton.enabled = true
            })
        }
        
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
        
        
        self.updateMyPhotos()
        
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
        
        self.updatePhotoButtonText()
    }
    
    func updateMyPhotos() {
        self.photos = []
        self.tempPhotos = []
        self.photoManager.getPhotosForTeamNum(self.number, success: { [unowned self] in
            for photo : [String: AnyObject] in self.photoManager.activeImages {
                if photo.keys.count > 0 {
                    self.photos.append(UIImage(data: photo["data"] as! NSData)!)
                }
            }
            self.updatePhotoButtonText()
        })
    }
    
    func updatePhotoButtonText() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let photosCount : Int = self.photos.count
            self.viewImagesButton.setTitle("View Images: (\(photosCount)/3)", forState: UIControlState.Normal)
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
    
    @IBAction func baseWidthDidChange(sender: UITextField) {
        if let num = Float(self.pitDriveBaseWidth.text!)  {
            self.ourTeam?.childByAppendingPath("pitDriveBaseWidth").setValue(Float(num))
            self.pitDriveBaseWidth.backgroundColor = UIColor.whiteColor()
        } else {
            self.pitDriveBaseWidth.backgroundColor = UIColor.redColor()
        }
    }
    
    @IBAction func baseLengthDidChange(sender: UITextField) {
        if let num = Float(self.pitDriveBaseLength.text!)  {
            self.ourTeam?.childByAppendingPath("pitDriveBaseLength").setValue(Float(num))
            self.pitDriveBaseLength.backgroundColor = UIColor.whiteColor()
        } else {
            self.pitDriveBaseLength.backgroundColor = UIColor.redColor()
        }
    }
    
    @IBAction func releaseHeightEditingEnded(sender: UITextField) {
        if let num = Float(self.pitHeightOfBallLeavingShooter.text!)  {
            self.ourTeam?.childByAppendingPath("pitHeightOfBallLeavingShooter").setValue(Float(num))
            self.pitHeightOfBallLeavingShooter.backgroundColor = UIColor.whiteColor()
        } else {
            self.pitHeightOfBallLeavingShooter.backgroundColor = UIColor.redColor()
        }
    }
    
    //MARK: --> Segmented Controls
    @IBAction func shotBlockerPotentialDidChange(sender: UISegmentedControl) {
        self.ourTeam?.childByAppendingPath("pitPotentialShotBlockerCapability").setValue(sender.selectedSegmentIndex)
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
    
    @IBAction func didPressShowMeButton(sender: UIButton) {
        if self.photos.count > 0 && self.canViewPhotos {
            self.tempPhotos = self.photos
            let gallery = SwiftPhotoGallery(delegate: self, dataSource: self)
            presentViewController(gallery, animated: true, completion: nil)
        }
    }
    
    
    
    // MARK: SwiftPhotoGalleryDataSource Methods
    
    func numberOfImagesInGallery(gallery:SwiftPhotoGallery) -> Int {
        return self.tempPhotos.count //Actually counting the available ones
    }
    
    func imageInGallery(gallery:SwiftPhotoGallery, forIndex:Int) -> UIImage? {
        let image = self.tempPhotos[forIndex]
        let rotatedImage : UIImage = UIImage(CGImage: image.CGImage!,
            scale: 1.0,
            orientation: UIImageOrientation.Right)
        return rotatedImage
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
    
    override func viewDidDisappear(animated: Bool) {
        self.ourTeam.childByAppendingPath("pitLowBarCapability").setValue(self.pitLowBarCapability.on) //Because you might not want to change it
    }
}

