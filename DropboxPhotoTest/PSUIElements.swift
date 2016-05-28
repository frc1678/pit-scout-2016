//
//  PSUIElement.swift
//  DropboxPhotoTest
//
//  Created by Bryton Moeller on 5/12/16.
//  Copyright © 2016 citruscircuits. All rights reserved.
//

import Foundation
import Firebase




class PSUITextInputViewController : UIViewController, UITextFieldDelegate {
    @IBOutlet weak var label: UILabel!
    var titleText = ""
    var initialValue = ""
    
    var neededType : NeededType?
    var firebaseRef : FIRDatabaseReference? {
        didSet {
            self.connectWithFirebase()
        }
    }
    
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        self.textField.delegate = self
        self.label.text = titleText
        self.textField.text = initialValue
    }
    
    func setup(titleText : String, firebaseRef : FIRDatabaseReference, initialValue : String) {
        self.titleText = titleText
        self.initialValue = initialValue
        self.firebaseRef = firebaseRef
    }
    
    private func connectWithFirebase() {
        self.firebaseRef!.observeEventType(.Value) { (snapshot) -> Void in
            self.firebaseRef!.setValue(snapshot.value)
        }
    }
    
    @IBAction func textFieldEditingDidEnd(sender: UITextField) {
        self.setValue(sender.text ?? "")
    }
    
    private func setValue(value: AnyObject) {
        if let v = value as? String {
            self.textField.text = v
            if neededType != nil {
                if neededType == .Int {
                    if value as? Int == nil {
                        self.textField.backgroundColor = UIColor.redColor()
                    }
                } else if neededType == .Float {
                    if value as? Float == nil {
                        self.textField.backgroundColor = UIColor.redColor()
                    }
                }
            }
        } else {
            self.textField.backgroundColor = UIColor.redColor()
        }
    }
    
    enum NeededType {
        case Int
        case Float
    }
    
}


