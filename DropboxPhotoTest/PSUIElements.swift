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
    var neededType : NeededType?
    var firebaseRef : FIRDatabaseReference! {
        didSet {
            self.connectWithFirebase()
        }
    }
    
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        self.textField.delegate = self
    }
    
    func setup(titleLabel : String, firebaseLocation : String, initialValue : String) {
        self.label.text = titleLabel
        self.textField.text = initialValue
    }
    
    private func connectWithFirebase() {
        _ = self.firebaseRef.observeEventType(.Value) { (snapshot) -> Void in
            self.firebaseRef.setValue(snapshot.value)
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

class PSUILayoutController : UIViewController {
    
}
