//
//  ViewController.swift
//  DropboxPhotoTest
//
//  Created by Bryton Moeller on 12/30/15.
//  Copyright © 2015 citruscircuits. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIScrollViewDelegate {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var teamName: UILabel!
    @IBOutlet weak var teamNumber: UILabel!
    @IBOutlet weak var numWheels: UITextField!
    @IBOutlet weak var pitOrgSelect: UISegmentedControl!
    @IBOutlet weak var bottomScrollViewConstraint: NSLayoutConstraint!
    var teamNum : Int = -1
    var teamNam : String = "-1"
    var numberOfWheels : Int  = -1
    var pitOrg : String = "-1"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        teamNumber.text = String(teamNum)
        teamName.text = teamNam
        self.scrollView.scrollEnabled = true
        self.scrollView.contentSize.width = self.scrollView.frame.width
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
    }
    @IBAction func numWheelsEditingEnded(sender: UITextField) {
        if(sender.text != "") { self.numberOfWheels = Int(sender.text!)! }
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
    
    func keyboardWasShown(notification: NSNotification) {
        var info = notification.userInfo!
        var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.bottomScrollViewConstraint.constant = keyboardFrame.size.height + 20
        })
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        let activityViewController = UIActivityViewController(activityItems: [info[UIImagePickerControllerOriginalImage] as! UIImage], applicationActivities: nil)
        presentViewController(activityViewController, animated: true, completion: {})
    }

}

