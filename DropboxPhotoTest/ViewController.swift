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
import firebase_schema_2016_ios

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var numWheels: UITextField!
    @IBOutlet weak var pitOrgSelect:UISegmentedControl!
    @IBOutlet weak var selectedImageURL: UITextField!
    @IBOutlet weak var otherImageURLs: UITextField!
    @IBOutlet weak var bottomScrollViewConstraint: NSLayoutConstraint!
    var teamNum : Int = -1
    var teamNam : String = "-1"
    var numberOfWheels : Int  = -1
    var pitOrg : String = "-1"
    var origionalBottomScrollViewConstraint : CGFloat = 0.0
    let firebase = Firebase(url: "https://1678-dev-2016.firebaseio.com/")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.scrollEnabled = true
        self.scrollView.contentSize.width = self.scrollView.frame.width
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
        self.origionalBottomScrollViewConstraint = self.bottomScrollViewConstraint.constant
        self.firebase.authUser("jenny@example.com", password: "correcthorsebatterystaple") {
            error, authData in
            if error != nil {
                print("Firebase Login Successful")
            } else {
                // user is logged in, check authData for data
                print("Firebase Login Failed")
            }
        }
    }
    @IBAction func numWheelsEditingEnded(sender: UITextField) {
        if(sender.text != "") { self.numberOfWheels = Int(sender.text!)! }
    }
    
    @IBAction func selectedImageEditingEnded(sender: UITextField) {
        
    }
    
    @IBAction func otherImageEditingEnded(sender: UITextField) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pitOrgValueChanged(sender: UISegmentedControl) {
        let pitOrgValues = ["Terrible", "Bad", "OK", "Good", "Great"]
        self.pitOrg = pitOrgValues[sender.selectedSegmentIndex]
    }

    @IBAction func cameraButtonPressed(sender: AnyObject) {
        
        let picker = UIImagePickerController()
        
        picker.sourceType = .Camera
        picker.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(.Camera)!
        picker.delegate = self
        presentViewController(picker, animated: true, completion: {
            print("picker done")
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
        self.scrollView.scrollRectToVisible(self.textView.frame, animated: true)
    }
    
    func keyboardWillHide(notification:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsetsZero
        self.scrollView.contentInset = contentInset
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        let tempImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let activityViewController = UIActivityViewController(activityItems: [tempImage], applicationActivities: nil)
        presentViewController(activityViewController, animated: true, completion: {})
    }
    
    
}

