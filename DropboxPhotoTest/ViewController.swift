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

//import PitTeamDataSource


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIScrollViewDelegate, SwiftPhotoGalleryDataSource, SwiftPhotoGalleryDelegate {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var numWheels: UITextField!
    @IBOutlet weak var pitOrgSelect:UISegmentedControl!
    @IBOutlet weak var selectedImageURL: UITextField!
    @IBOutlet weak var bottomScrollViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var baseWidth: UITextField!
    @IBOutlet weak var baseLength: UITextField!
    @IBOutlet weak var bumperHeight: UITextField!
    @IBOutlet weak var midlineBallCheesecakePotential: UISegmentedControl!
    @IBOutlet weak var shotBlockerPotential: UISegmentedControl!
    @IBOutlet weak var lowBarPotential: UISegmentedControl!
    @IBOutlet weak var lowBarSwitch: UISwitch!
    @IBOutlet weak var pitNotes: UITextField!
    
    var photoUploader : PhotoUploader!
    //let dCache = Shared.dataCache //Storing to disk
    var teamNam : String = "-1"
    var numberOfWheels : Int  = -1
    var pitOrg : Int = -1 {
        didSet {
            self.pitOrgSelect.selectedSegmentIndex = self.pitOrg
        }
    }
    var teamNum : Int!
    //let pitOrgValues = ["Terrible", "Bad", "OK", "Good", "Great"]
    //let numberSelectorValues = ["1", "2", "3", "4", "5"]
    var filesToUpload : [[String : AnyObject]] = []
    var sharedURLs : [[Int: String]] = []
    var origionalBottomScrollViewConstraint : CGFloat = 0.0
    var firebase : Firebase!
    var ourTeam : Firebase!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pitNotes.delegate = self
        self.ourTeam.observeSingleEventOfType(.Value, withBlock: { (snap) -> Void in
            //Updating UI
            
            self.selectedImageURL.text = snap.childSnapshotForPath("selectedImageUrl").value as? String
            self.pitNotes.text = snap.childSnapshotForPath("pitNotes").value as? String
            self.bumperHeight.text = "\(snap.childSnapshotForPath("pitBumperHeight").value as! Float)"
            self.baseLength.text = "\(snap.childSnapshotForPath("pitDriveBaseLength").value as! Float)"
            self.baseWidth.text = "\(snap.childSnapshotForPath("pitDriveBaseWidth").value as! Float)"
            self.numWheels.text = "\(snap.childSnapshotForPath("pitNumberOfWheels").value as! Int)"
            if let po = snap.childSnapshotForPath("pitOrganization").value as? Int {
                if po != -1 {
                    self.pitOrgSelect.selectedSegmentIndex = po
                    self.pitOrgSelect.selected = true
                }
            }
            if let po = snap.childSnapshotForPath("pitPotentialShotBlockerCapability").value as? Int {
                if po != -1 {
                    self.shotBlockerPotential.selectedSegmentIndex = po
                }
            }
            if let po = snap.childSnapshotForPath("pitPotentialMidlineBallCapability").value as? Int {
                if po != -1 {
                    self.midlineBallCheesecakePotential.selectedSegmentIndex = po
                }
            }
            if let po = snap.childSnapshotForPath("pitPotentialLowBarCapability").value as? Int {
                if po != -1 {
                    self.lowBarPotential.selectedSegmentIndex = po
                }
            }
            if let passedLowBarTesting = snap.childSnapshotForPath("pitLowBarCapability").value {
                let passedLowBar = Bool(passedLowBarTesting as! NSNumber)
                self.lowBarSwitch.setOn(passedLowBar, animated: true)
            }
        })
        
        self.scrollView.scrollEnabled = true
        self.scrollView.contentSize.width = self.scrollView.frame.width
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
        self.origionalBottomScrollViewConstraint = self.bottomScrollViewConstraint.constant
        
        
    }
    
    @IBAction func pitNotesEditingEnded(sender: UITextField) {
        self.ourTeam?.childByAppendingPath("pitNotes").setValue(self.pitNotes.text)
    }
    
    
    @IBAction func numWheelsEditingEnded(sender: UITextField) {
        if(sender.text != "") {
            self.numberOfWheels = Int(sender.text!)!
            self.ourTeam?.childByAppendingPath("pitNumberOfWheels").setValue(self.numberOfWheels)
        }
    }
    
    @IBAction func bumperHeightDidChange(sender: UITextField) {
        if let num = Float(self.bumperHeight.text!)  {
            self.ourTeam?.childByAppendingPath("pitBumperHeight").setValue(Float(num))
        } else {
            self.bumperHeight.backgroundColor = UIColor.redColor()
        }
    }
    
    
    @IBAction func selectedImageEditingEnded(sender: UITextField) {
        self.ourTeam?.childByAppendingPath("selectedImageUrl").setValue(self.selectedImageURL.text)
    }
    
    @IBAction func baseWidthDidChange(sender: UITextField) {
        if let num = Float(self.baseWidth.text!)  {
            self.ourTeam?.childByAppendingPath("pitDriveBaseWidth").setValue(Float(num))
        } else {
            self.baseWidth.backgroundColor = UIColor.redColor()
        }
    }
    @IBAction func baseLengthDidChange(sender: UITextField) {
        if let num = Float(self.baseLength.text!)  {
            self.ourTeam?.childByAppendingPath("pitDriveBaseLength").setValue(Float(num))
        } else {
            self.baseLength.backgroundColor = UIColor.redColor()
        }
    }
    @IBAction func shotBlockerPotentialDidChange(sender: UISegmentedControl) {
        self.ourTeam?.childByAppendingPath("pitPotentialShotBlockerCapability").setValue(sender.selectedSegmentIndex)
    }
    
    @IBAction func lowBarPotentialDidChange(sender: UISegmentedControl) {
        self.ourTeam?.childByAppendingPath("pitPotentialLowBarCapability").setValue(sender.selectedSegmentIndex)
    }
    
    @IBAction func midlineBallCheesecakePotentialDidChange(sender: UISegmentedControl) {
        self.ourTeam?.childByAppendingPath("pitPotentialMidlineBallCapability").setValue(sender.selectedSegmentIndex)
    }
    
    @IBAction func lowBarTestResultChanged(sender: UISwitch) {
        self.ourTeam.childByAppendingPath("pitLowBarCapability").setValue(sender.on)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pitOrgValueChanged(sender: UISegmentedControl) {
        if self.pitOrg != sender.selectedSegmentIndex {
            self.pitOrg = sender.selectedSegmentIndex
            self.ourTeam?.childByAppendingPath("pitOrganization").setValue(sender.selectedSegmentIndex)
        }
    }
    
    @IBAction func cameraButtonPressed(sender: AnyObject) {
        
        let picker = UIImagePickerController()
        
        picker.sourceType = .Camera
        picker.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(.Camera)!
        picker.delegate = self
        presentViewController(picker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        //self.imageButton.imageView?.image = image
        picker.dismissViewControllerAnimated(true, completion: nil)
        //let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        //presentViewController(activityViewController, animated: true, completion: {})
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            let fileName = "\(self.teamNum)_\(self.photoUploader.getImagesForTeamNum(self.teamNum).count).png"
            if let _ = self.photoUploader.sharedURLs[self.teamNum] {
                self.photoUploader.sharedURLs[self.teamNum]!.addObject("https://dl.dropboxusercontent.com/u/63662632/\(fileName)")
            } else {
                self.photoUploader.sharedURLs[self.teamNum] = ["https://dl.dropboxusercontent.com/u/63662632/\(fileName)"]
            }
            self.photoUploader.addFileToLineup(UIImagePNGRepresentation(image)!, fileName: fileName, teamNumber: self.teamNum)
        })
        
    }
    
    /*func keyboardWillShow(notification: NSNotification) {
    var info = notification.userInfo!
    let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
    
    UIView.animateWithDuration(0.1, animations: { () -> Void in
    self.bottomScrollViewConstraint.constant = keyboardFrame.size.height + 20
    })
    }
    func keyboardWillHide(notification: NSNotification) {
    UIView.animateWithDuration(0.1, animations: { () -> Void in
    self.bottomScrollViewConstraint.constant = self.origionalBottomScrollViewConstraint
    })
    }
    */
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
        let contentInset:UIEdgeInsets = UIEdgeInsetsZero
        self.scrollView.contentInset = contentInset
    }
    /*
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    picker.dismissViewControllerAnimated(true, completion: nil)
    let tempImage = info[UIImagePickerControllerOriginalImage] as! UIImage
    let activityViewController = UIActivityViewController(activityItems: [tempImage], applicationActivities: nil)
    presentViewController(activityViewController, animated: true, completion: {})
    }*/
    
    
    
    
    
    
    
    
    
    
    
    
    @IBAction func didPressShowMeButton(sender:AnyObject) {
        if self.photoUploader.getImagesForTeamNum(self.teamNum).count > 0 {
            let gallery = SwiftPhotoGallery(delegate: self, dataSource: self)
            presentViewController(gallery, animated: true, completion: nil)
        }
    }
    
    // MARK: SwiftPhotoGalleryDataSource Methods
    
    func numberOfImagesInGallery(gallery:SwiftPhotoGallery) -> Int {
        return self.photoUploader.getImagesForTeamNum(self.teamNum).count
    }
    
    func imageInGallery(gallery:SwiftPhotoGallery, forIndex:Int) -> UIImage? {
        return UIImage(data: self.photoUploader.getImagesForTeamNum(self.teamNum)[forIndex]["data"] as! NSData)
    }
    
    // MARK: SwiftPhotoGalleryDelegate Methods
    
    func galleryDidTapToClose(gallery:SwiftPhotoGallery) {
        
        let urls = self.photoUploader.getSharedURLsForTeamNum(self.teamNum)
        self.selectedImageURL.text = urls[gallery.currentPage] as? String
        self.selectedImageEditingEnded(self.selectedImageURL)
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

