//
//  PSUIElement.swift
//  DropboxPhotoTest
//
//  Created by Bryton Moeller on 5/12/16.
//  Copyright © 2016 citruscircuits. All rights reserved.
//

import Foundation
import Firebase


class PSUIFirebaseViewController : UIViewController {
    var initialValue : AnyObject?
    var titleText = ""
    var neededType : NeededType?
    var UIResponse : ((AnyObject)->())? = {_ in }
    var firebaseRef : FIRDatabaseReference? {
        didSet {
            self.connectWithFirebase()
        }
    }
    
    func setup(titleText : String, firebaseRef : FIRDatabaseReference, initialValue : AnyObject) {
        self.titleText = titleText
        self.initialValue = initialValue
        self.firebaseRef = firebaseRef
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    enum NeededType {
        case Int
        case Float
        case Bool
        case String
    }
    
    func set(value: AnyObject) {
        if neededType != nil {
            if neededType == .Int {
                if Int(String(value)) == nil {
                    self.view.backgroundColor = UIColor.redColor()
                } else {
                    self.view.backgroundColor = UIColor.whiteColor()
                    self.firebaseRef?.setValue(Int(String(value)))
                    UIResponse!(value)
                }
            } else if neededType == .Float {
                if Float(String(value)) == nil {
                    self.view.backgroundColor = UIColor.redColor()
                } else {
                    self.view.backgroundColor = UIColor.whiteColor()
                    self.firebaseRef?.setValue(Float(String(value)))
                    UIResponse!(value)
                }
            } else if neededType == .String {
                if value as? String == nil {
                    self.view.backgroundColor = UIColor.redColor()
                } else {
                    self.view.backgroundColor = UIColor.whiteColor()
                    self.firebaseRef?.setValue(String(value))
                    UIResponse!(value)
                }
            } else if neededType == .Bool {
                if value as? Bool == nil {
                    self.view.backgroundColor = UIColor.redColor()
                } else {
                    self.view.backgroundColor = UIColor.whiteColor()
                    self.firebaseRef?.setValue(value as! Bool)
                    UIResponse!(value)
                }
            }
        } else {
            self.firebaseRef?.setValue(value)
            UIResponse!(value)
        }
        
    }
    
    func connectWithFirebase() {
        self.firebaseRef!.observeEventType(FIRDataEventType.Value) { (snapshot : FIRDataSnapshot) -> Void in
            self.set(snapshot.value!)
        }
    }
    
}

class PSUITextInputViewController : PSUIFirebaseViewController, UITextFieldDelegate {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.textField.delegate = self
        self.label.text = super.titleText
        self.textField.text = super.initialValue as? String ?? ""
        self.neededType = .String
        super.UIResponse = { value in
            self.textField.text = String(value)
        }
    }
    
    @IBAction func textFieldEditingDidEnd(sender: UITextField) {
        super.set(sender.text!)
    }
}

class PSUISwitchViewController : PSUIFirebaseViewController {
    @IBOutlet weak var toggleSwitch: UISwitch!
    @IBOutlet weak var label: UILabel!
    
    @IBAction func switchSwitched(sender: UISwitch) {
        super.set(sender.on)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.neededType = .Bool
        self.toggleSwitch.setOn(super.initialValue as! Bool, animated: true)
        super.UIResponse = { value in
            self.toggleSwitch.setOn(value as! Bool, animated: true)
        }
        self.label.text = super.titleText

    }
}

class PSUISegmentedViewController : PSUIFirebaseViewController {
    @IBOutlet weak var segmentedController: UISegmentedControl!
    @IBOutlet weak var label: UILabel!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.neededType = .Int
        self.segmentedController.selectedSegmentIndex = super.initialValue as! Int
        super.UIResponse = { value in
            self.segmentedController.selectedSegmentIndex = value as! Int
        }
        self.label.text = super.titleText

    }
    
    @IBAction func selectedSegmentChanged(sender: UISegmentedControl) {
        super.set(segmentedController.selectedSegmentIndex)
    }
}
