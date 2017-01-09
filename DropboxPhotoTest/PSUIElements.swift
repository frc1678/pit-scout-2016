//
//  PSUIElement.swift
//  DropboxPhotoTest
//
//  Created by Bryton Moeller on 5/12/16.
//  Copyright © 2016 citruscircuits. All rights reserved.
//

import Foundation
import Firebase

/// PSUI (Pit Scout User Interface) elements will subclass from this. These Elements will handle the updating of their content on firebase when the user changes the UI, they will also handle keeping themselves up to date with changes on Firebase.
class PSUIFirebaseViewController : UIViewController {
    let red = UIColor(colorLiteralRed: 243/255, green: 32/255, blue: 5/255, alpha: 1)
    var initialValue : Any?
    var titleText = ""
    var neededType : NeededType? {
        didSet {
            firebaseRef?.observeSingleEvent(of: .value, with: { (snap) -> Void in
                self.set(snap.value!)
            })
        }
    }
    var previousValue : Any? = ""
    var hasOverriddenUIResponse = false
    var UIResponse : ((Any)->())? = {_ in } {
        didSet {
            self.connectWithFirebase()
            hasOverriddenUIResponse = true
        }
    }
    var firebaseRef : FIRDatabaseReference?
    
    func setup(_ titleText : String, firebaseRef : FIRDatabaseReference, initialValue : Any?) {
        self.titleText = titleText
        self.initialValue = initialValue
        self.firebaseRef = firebaseRef
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.translatesAutoresizingMaskIntoConstraints = true
    }
    
    enum NeededType {
        case int
        case float
        case bool
        case string
    }
    
    func set(_ value: Any) {
        if neededType != nil {
            if neededType == .int {
                if Int(String(describing: value)) == nil {
                    self.view.backgroundColor = red
                } else {
                    self.view.backgroundColor = UIColor.white
                    self.firebaseRef?.setValue(Int(String(describing: value)))
                    UIResponse!(value)
                }
            } else if neededType == .float {
                if Float(String(describing: value)) == nil {
                    self.view.backgroundColor = red
                } else {
                    self.view.backgroundColor = UIColor.white
                    self.firebaseRef?.setValue(Float(String(describing: value)))
                    UIResponse!(value)
                }
            } else if neededType == .string {
                if value as? String == nil {
                    self.view.backgroundColor = red
                } else {
                    self.view.backgroundColor = UIColor.white
                    self.firebaseRef?.setValue(String(describing: value))
                    UIResponse!(value)
                }
            } else if neededType == .bool {
                if value as? Bool == nil {
                    self.view.backgroundColor = red
                } else {
                    self.view.backgroundColor = UIColor.white
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
        self.firebaseRef!.observe(FIRDataEventType.value) { (snapshot : FIRDataSnapshot) -> Void in
            if String(describing: snapshot.value) != String(describing: self.previousValue) {
                self.set(snapshot.value! as Any)
            }
            self.previousValue = snapshot.value as Any?
        }
    }
    
}

/// Just a few customizations of the text input view for the pit scout. See the `PSUIFirebaseViewController`.
class PSUITextInputViewController : PSUIFirebaseViewController, UITextFieldDelegate {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    override func viewDidLoad() {
        let currentResponse = self.UIResponse
        if !hasOverriddenUIResponse {
            self.UIResponse = { value in
                currentResponse!(value)
                //print(String(value))
                    self.textField.text = value as? String ?? (value as? NSNumber)?.stringValue ?? ""
               

            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.textField.delegate = self
        self.label.text = super.titleText
        self.textField.text = super.initialValue as? String ?? (super.initialValue as? NSNumber)?.stringValue ?? ""
        print(self.textField.text)
        print("a \(super.initialValue as? String ?? (super.initialValue as? NSNumber)?.stringValue ?? "")")
        //self.neededType = .String
        
    }
    
    @IBAction func textFieldEditingDidEnd(_ sender: UITextField) {
        super.set(sender.text!)
    }
}

class PSUISwitchViewController : PSUIFirebaseViewController {
    @IBOutlet weak var toggleSwitch: UISwitch!
    @IBOutlet weak var label: UILabel!
    
    @IBAction func switchSwitched(_ sender: UISwitch) {
        super.set(sender.isOn as AnyObject)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.neededType = .bool
        self.toggleSwitch.setOn(super.initialValue as? Bool ?? false, animated: true)
        super.UIResponse = { value in
            self.toggleSwitch.setOn(value as! Bool, animated: true)
        }
        self.label.text = super.titleText
        
    }
}

class PSUISegmentedViewController : PSUIFirebaseViewController {
    @IBOutlet weak var segmentedController: UISegmentedControl!
    @IBOutlet weak var label: UILabel!
    var segments : [String] = []
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.segmentedController.numberOfSegments = segments.count
        segmentedController.removeAllSegments()
        for i in 0..<segments.count {
            self.segmentedController.insertSegment(withTitle: segments[i], at: i, animated: true)
        }
        self.neededType = .int
        self.segmentedController.selectedSegmentIndex = super.initialValue as? Int ?? 0
        super.UIResponse = { value in
            self.segmentedController.selectedSegmentIndex = value as! Int
        }
        self.label.text = super.titleText
        
        
    }
    
    @IBAction func selectedSegmentChanged(_ sender: UISegmentedControl) {
        super.set(segmentedController.selectedSegmentIndex as AnyObject)
    }
}

class PSUIButton : UIButton {
    let green = UIColor(colorLiteralRed: 91/255, green: 227/255, blue: 0/255, alpha: 1)
    var press : (_ sender : UIButton)->() = {_ in } //This is an empty function of the type (sender : UIButton)->().
    convenience init(title : String, width : Int, y: Int, buttonPressed : @escaping (_ sender : UIButton)->()) {
        //Adding the Add Image Button to the UI
        self.init(frame: CGRect(x: 0, y: y, width: width, height: 45))
        self.press = buttonPressed
        self.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        self.setTitle(title, for: UIControlState())
        self.setTitleColor(green, for: UIControlState())
        self.isUserInteractionEnabled = true
        let tapAddImageButton = UITapGestureRecognizer(target: self, action: #selector(PSUIButton.buttonPressed(_:)))
        self.addGestureRecognizer(tapAddImageButton)
    }
    
    func redrawWithWidth(_ w: CGFloat) {
        self.frame.size.width = w
        self.setNeedsLayout()
    }
    
    func buttonPressed(_ button : UIButton) {
        self.press(button)
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
