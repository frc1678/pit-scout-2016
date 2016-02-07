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
//import PitTeamDataSource


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIScrollViewDelegate {
    
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
    
    var teamNam : String = "-1"
    var numberOfWheels : Int  = -1
    var pitOrg : String = "-1" {
        didSet {
            self.pitOrgSelect.selectedSegmentIndex = self.pitOrgValues.indexOf(self.pitOrg)!
        }
    }
    var teamNum : Int = -1
    let pitOrgValues = ["Terrible", "Bad", "OK", "Good", "Great"]
    let numberSelectorValues = ["1", "2", "3", "4", "5"]
    var filesToUpload : [[String : AnyObject]] = []
    var sharedURLs : [[Int: String]] = []
    var timer = NSTimer()
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
            if let po = snap.childSnapshotForPath("pitOrganization").value as? String {
                if po != "-1" {
                    self.pitOrgSelect.selectedSegmentIndex = self.pitOrgValues.indexOf(po)!
                }
            }
            if let po = snap.childSnapshotForPath("pitPotentialShotBlockerCapability").value as? String {
                if po != "-1" {
                    self.shotBlockerPotential.selectedSegmentIndex = self.numberSelectorValues.indexOf(po)!
                }
            }
            if let po = snap.childSnapshotForPath("pitPotentialMidlineBallCapability").value as? String {
                if po != "-1" {
                    self.midlineBallCheesecakePotential.selectedSegmentIndex = self.numberSelectorValues.indexOf(po)!
                }
            }
            if let po = snap.childSnapshotForPath("pitPotentialLowBarCapability").value as? String {
                if po != "-1" {
                    self.lowBarPotential.selectedSegmentIndex = self.numberSelectorValues.indexOf(po)!
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
        self.ourTeam?.childByAppendingPath("pitBumperHeight").setValue(Float(self.bumperHeight.text!))
    }
    
    
    @IBAction func selectedImageEditingEnded(sender: UITextField) {
        self.ourTeam?.childByAppendingPath("selectedImageUrl").setValue(self.selectedImageURL.text)
    }
    @IBAction func baseWidthDidChange(sender: UITextField) {
        self.ourTeam?.childByAppendingPath("pitDriveBaseWidth").setValue(Float(self.baseWidth.text!))
    }
    @IBAction func baseLengthDidChange(sender: UITextField) {
        self.ourTeam?.childByAppendingPath("pitDriveBaseLength").setValue(Float(self.baseLength.text!))
    }
    @IBAction func shotBlockerPotentialDidChange(sender: UISegmentedControl) {
        self.ourTeam?.childByAppendingPath("pitPotentialShotBlockerCapability").setValue(self.numberSelectorValues[sender.selectedSegmentIndex])
    }
    
    @IBAction func lowBarPotentialDidChange(sender: UISegmentedControl) {
        self.ourTeam?.childByAppendingPath("pitPotentialLowBarCapability").setValue(self.numberSelectorValues[sender.selectedSegmentIndex])
    }
    
    @IBAction func midlineBallCheesecakePotentialDidChange(sender: UISegmentedControl) {
        self.ourTeam?.childByAppendingPath("pitPotentialMidlineBallCapability").setValue(self.numberSelectorValues[sender.selectedSegmentIndex])
    }
    
    @IBAction func lowBarTestResultChanged(sender: UISwitch) {
        self.ourTeam.childByAppendingPath("pitLowBarCapability").setValue(sender.on)
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pitOrgValueChanged(sender: UISegmentedControl) {
        if self.pitOrg != self.pitOrgValues[sender.selectedSegmentIndex] {
            self.pitOrg = self.pitOrgValues[sender.selectedSegmentIndex]
            print(self.ourTeam?.childByAppendingPath("pitOrganization"))
            self.ourTeam?.childByAppendingPath("pitOrganization").setValue(self.pitOrgValues[sender.selectedSegmentIndex])
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
        self.imageButton.imageView?.image = image
        picker.dismissViewControllerAnimated(true, completion: nil)
        //let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        //presentViewController(activityViewController, animated: true, completion: {})
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            self.addFileToLineup(UIImagePNGRepresentation(image)!, fileName: "\(self.teamNum)--\(NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)).png", teamNumber: self.teamNum) //The file name has a timestamp
            self.uploadFilesToDropbox()
            
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
    
    func addFileToLineup(fileData : NSData, fileName : String, teamNumber : Int) {
        self.filesToUpload.append(["name"  : fileName, "data" : fileData, "teamNumber" : teamNumber])
    }
    
    func uploadFilesToDropbox() {
        if(self.isConnectedToNetwork()) {
            if let client = Dropbox.authorizedClient {
                for file in self.filesToUpload {
                    let name = file["name"] as! String
                    let data = file["data"] as! NSData
                    let number = file["teamNumber"] as! Int
                    var sharedURL = [number: "File Not Uploaded: \(name)"]
                    client.files.upload(path: "/Public/\(name)", body: data).response { response, error in
                        if let metaData = response {
                            self.filesToUpload = self.filesToUpload.filter({ $0["data"] as! NSData != file["data"] as! NSData }) //Removing the uploaded file from files to upload, this actually works in swift!
                            print("*** Upload file: \(metaData) ****")
                            let url = "https://dl.dropboxusercontent.com/u/63662632/"
                            sharedURL = [number: url]
                            self.putPhotoLinkToFirebase(url, teamNumber: number, selectedImage: true)
                        }
                    }
                    self.sharedURLs.append(sharedURL)
                }
            }
        } else {
            checkInternet(self.timer)
        }
    }
    
    func isConnectedToNetwork() -> Bool  {
        let url = NSURL(string: "https://www.google.com/")
        
        let data = NSData(contentsOfURL: url!)
        
        if (data != nil) {
            return(true)
        }
        return(false)
    }
    
    func checkInternet(timer: NSTimer) {
        self.timer.invalidate()
        if(!self.isConnectedToNetwork()) {
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkInternet:", userInfo: nil, repeats: false)
        } else {
            self.uploadFilesToDropbox()
        }
    }
    
    
    
    func putPhotoLinkToFirebase(link: String, teamNumber: Int, selectedImage: Bool) {
        let teamFirebase = self.firebase?.childByAppendingPath("\(teamNumber)")
        let currentURLs = teamFirebase?.childByAppendingPath("otherImageUrls")
        print(currentURLs)
        currentURLs!.childByAutoId().setValue(link)
        if(selectedImage) {
            teamFirebase?.childByAppendingPath("selectedImageUrl").setValue(link)
            self.selectedImageURL.text = link
        }
    }
    
}

