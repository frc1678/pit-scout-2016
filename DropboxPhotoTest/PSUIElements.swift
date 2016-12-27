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
<<<<<<< HEAD
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
    
    func setup(_ titleText : String, firebaseRef : FIRDatabaseReference, initialValue : Any) {
=======
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
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        self.titleText = titleText
        self.initialValue = initialValue
        self.firebaseRef = firebaseRef
    }
    
    
<<<<<<< HEAD
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
                    self.view.backgroundColor = UIColor.red
                } else {
                    self.view.backgroundColor = UIColor.white
                    self.firebaseRef?.setValue(Int(String(describing: value)))
                    UIResponse!(value)
                }
            } else if neededType == .float {
                if Float(String(describing: value)) == nil {
                    self.view.backgroundColor = UIColor.red
                } else {
                    self.view.backgroundColor = UIColor.white
                    self.firebaseRef?.setValue(Float(String(describing: value)))
                    UIResponse!(value)
                }
            } else if neededType == .string {
                if value as? String == nil {
                    self.view.backgroundColor = UIColor.red
                } else {
                    self.view.backgroundColor = UIColor.white
                    self.firebaseRef?.setValue(String(describing: value))
                    UIResponse!(value)
                }
            } else if neededType == .bool {
                if value as? Bool == nil {
                    self.view.backgroundColor = UIColor.red
                } else {
                    self.view.backgroundColor = UIColor.white
=======
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
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
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
<<<<<<< HEAD
        self.firebaseRef!.observe(FIRDataEventType.value) { (snapshot : FIRDataSnapshot) -> Void in
            if String(describing: snapshot.value) != String(describing: self.previousValue) {
                self.set(snapshot.value! as Any)
            }
            self.previousValue = snapshot.value as Any?
=======
        self.firebaseRef!.observeEventType(FIRDataEventType.Value) { (snapshot : FIRDataSnapshot) -> Void in
            self.set(snapshot.value!)
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        }
    }
    
}

/// Just a few customizations of the text input view for the pit scout. See the `PSUIFirebaseViewController`.
class PSUITextInputViewController : PSUIFirebaseViewController, UITextFieldDelegate {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
<<<<<<< HEAD
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
=======
    
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
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        super.set(sender.text!)
    }
}

class PSUISwitchViewController : PSUIFirebaseViewController {
    @IBOutlet weak var toggleSwitch: UISwitch!
    @IBOutlet weak var label: UILabel!
    
<<<<<<< HEAD
    @IBAction func switchSwitched(_ sender: UISwitch) {
        super.set(sender.isOn as AnyObject)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.neededType = .bool
        self.toggleSwitch.setOn(super.initialValue as? Bool ?? false, animated: true)
=======
    @IBAction func switchSwitched(sender: UISwitch) {
        super.set(sender.on)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.neededType = .Bool
        self.toggleSwitch.setOn(super.initialValue as! Bool, animated: true)
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        super.UIResponse = { value in
            self.toggleSwitch.setOn(value as! Bool, animated: true)
        }
        self.label.text = super.titleText
<<<<<<< HEAD
        
=======

>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
    }
}

class PSUISegmentedViewController : PSUIFirebaseViewController {
    @IBOutlet weak var segmentedController: UISegmentedControl!
    @IBOutlet weak var label: UILabel!
<<<<<<< HEAD
    var segments : [String] = []
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.segmentedController.numberOfSegments = segments.count
        for i in 0..<segments.count {
            self.segmentedController.setTitle(segments[i], forSegmentAt: i)
        }
        self.neededType = .int
        self.segmentedController.selectedSegmentIndex = super.initialValue as? Int ?? 0
=======
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.neededType = .Int
        self.segmentedController.selectedSegmentIndex = super.initialValue as! Int
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        super.UIResponse = { value in
            self.segmentedController.selectedSegmentIndex = value as! Int
        }
        self.label.text = super.titleText
<<<<<<< HEAD
        
        
    }
    
    @IBAction func selectedSegmentChanged(_ sender: UISegmentedControl) {
        super.set(segmentedController.selectedSegmentIndex as AnyObject)
=======

    }
    
    @IBAction func selectedSegmentChanged(sender: UISegmentedControl) {
        super.set(segmentedController.selectedSegmentIndex)
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
    }
}

class PSUIButton : UIButton {
<<<<<<< HEAD
    var press : (_ sender : UIButton)->() = {_ in } //This is an empty function of the type (sender : UIButton)->().
    convenience init(title : String, width : Int, y: Int, buttonPressed : @escaping (_ sender : UIButton)->()) {
        //Adding the Add Image Button to the UI
        self.init(frame: CGRect(x: 0, y: y, width: width, height: 45))
        self.press = buttonPressed
        self.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        self.setTitle(title, for: UIControlState())
        self.setTitleColor(UIColor.green, for: UIControlState())
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
=======
    var press : (sender : UIButton)->() = {_ in } //This is an empty function of the type (sender : UIButton)->(). 
    convenience init(title : String, width : Int, y: Int, buttonPressed : (sender : UIButton)->()) {
        //Adding the Add Image Button to the UI
        self.init(frame: CGRect(x: 0, y: y, width: width, height: 45))
        self.press = buttonPressed
        self.setTitle(title, forState: .Normal)
        self.setTitleColor(UIColor.greenColor(), forState: .Normal)
        self.userInteractionEnabled = true
        let tapAddImageButton = UITapGestureRecognizer(target: self, action: "buttonPressed:")
        self.addGestureRecognizer(tapAddImageButton)
    }
    
    func buttonPressed(button : UIButton) {
        self.press(sender: button)
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
    }
<<<<<<< HEAD
    
=======

>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
