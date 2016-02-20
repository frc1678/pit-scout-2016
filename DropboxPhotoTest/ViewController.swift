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
import Haneke
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
    
    var photoUploader : PhotoUploader!
    var name : String = "-1"
    var numberOfWheels : Int  = -1
    var pitOrg : Int = -1
    var number : Int!
    var numberOfPhotos : Int = 0
    var firebase : Firebase!
    var ourTeam : Firebase!
    var photos = [UIImage]()
    var canViewPhotos : Bool = true //This is for that little time in between when the photo is taken and when it has been passed over to the uploader controller.
    var firebaseKeys = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ourTeam.observeSingleEventOfType(.Value, withBlock: { (snap) -> Void in //Updating UI
            self.title?.appendContentsOf(" - \(snap.childSnapshotForPath("name").value)")
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
        
        self.updatePhotoButtonText()
    }
    
    func updatePhotoButtonText() {
        self.viewImagesButton.setTitle("View Images: (\(self.photoUploader.getThumbsForTeamNum(self.number).count)/5)", forState: UIControlState.Normal)
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
        } else {
            self.pitDriveBaseWidth.backgroundColor = UIColor.redColor()
        }
    }
    
    @IBAction func baseLengthDidChange(sender: UITextField) {
        if let num = Float(self.pitDriveBaseLength.text!)  {
            self.ourTeam?.childByAppendingPath("pitDriveBaseLength").setValue(Float(num))
        } else {
            self.pitDriveBaseLength.backgroundColor = UIColor.redColor()
        }
    }
    
    @IBAction func releaseHeightEditingEnded(sender: UITextField) {
        if let num = Float(self.pitHeightOfBallLeavingShooter.text!)  {
            self.ourTeam?.childByAppendingPath("pitHeightOfBallLeavingShooter").setValue(Float(num))
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
        if self.photoUploader.getThumbsForTeamNum(self.number).count > 0 && self.canViewPhotos  {
            let gallery = SwiftPhotoGallery(delegate: self, dataSource: self)
            presentViewController(gallery, animated: true, completion: nil)
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
    
    // MARK: SwiftPhotoGalleryDataSource Methods
    
    func numberOfImagesInGallery(gallery:SwiftPhotoGallery) -> Int {
        return self.photoUploader.getThumbsForTeamNum(self.number).count
    }
    
    func imageInGallery(gallery:SwiftPhotoGallery, forIndex:Int) -> UIImage? {
        let image = UIImage(data: self.photoUploader.getThumbsForTeamNum(self.number)[forIndex]["data"] as! NSData)
        let rotatedImage : UIImage = UIImage(CGImage: image!.CGImage! ,
            scale: 1.0 ,
            orientation: UIImageOrientation.Right)
        return rotatedImage
    }
    
    // MARK: Swift Photo Gallery Methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.canViewPhotos = false
        //self.imageButton.imageView?.image = image
        picker.dismissViewControllerAnimated(true, completion: nil)
        //let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        //presentViewController(activityViewController, animated: true, completion: {})
        
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            let fileName = "\(self.number)_\(self.photoUploader.getThumbsForTeamNum(self.number).count).png"
            if let _ = self.photoUploader.sharedURLs[self.number] {
                self.photoUploader.sharedURLs[self.number]!.addObject("https://dl.dropboxusercontent.com/u/63662632/\(fileName)")
            } else {
                self.photoUploader.sharedURLs[self.number] = ["https://dl.dropboxusercontent.com/u/63662632/\(fileName)"]
            }
            self.photoUploader.addFileToLineup(UIImagePNGRepresentation(image)!, fileName: fileName, teamNumber: self.number, shouldUpload: true)
            self.canViewPhotos = true
            //dispatch_async(dispatch_get_main_queue(), {
                self.updatePhotoButtonText()
            //})
        //})
        
    }
    
    func galleryDidTapToClose(gallery:SwiftPhotoGallery) {
        let urls = self.photoUploader.getSharedURLsForTeamNum(self.number)
        if urls.count  > gallery.currentPage   { // the -1 is because of the initial "-1" url
            self.selectedImageUrl.text = urls[gallery.currentPage] as? String
            self.selectedImageEditingEnded(self.selectedImageUrl)
            
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Image Not Uploaded", message: "Please wait for the image to be uploaded, before trying to set it as the selected image. If we set the selected image url before the image exists on Dropbox, then the viewers might get confused.", preferredStyle: UIAlertControllerStyle.Alert)
                // Do something when message is tapped
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            dismissViewControllerAnimated(true, completion: nil)
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("Oh No, Mem warning!")
        self.photoUploader.mayKeepUsingNetwork = false
        // Dispose of any resources that can be recreated.
    }
    
    func isNull(object: AnyObject?) -> Bool {
        if object_getClass(object) == object_getClass(NSNull()) {
            return true
        }
        return false
    }
}

