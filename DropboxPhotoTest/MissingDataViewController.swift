//
//  MissingDataViewController.swift
//  DropboxPhotoTest
//
//  Created by Bryton Moeller on 3/17/16.
//  Copyright © 2016 citruscircuits. All rights reserved.
//

import UIKit
import Firebase

class MissingDataViewController : UIViewController {
    @IBOutlet weak var mdTextView: UITextView!
    /// Teams Firebase Snapshot
    var snap : FIRDataSnapshot? = nil {
        didSet {
            self.viewDidLoad()
        }
    }
    
<<<<<<< HEAD
    let firebaseKeys = ["pitNumberOfWheels", "selectedImageUrl", "pitNotes", "pitProgrammingLanguage", "pitAvailableWeight"]
    
    let ignoreKeys = ["pitNotes", "pitProgrammingLanguage", "pitAvailableWeight"]
    
    override func viewWillAppear(_ animated: Bool) {
=======
    let firebaseKeys = ["pitNumberOfWheels", "pitOrganization", "selectedImageUrl", "pitNotes", "pitProgrammingLanguage", "pitAvailableWeight"]
    
    let ignoreKeys = ["pitNotes"]
    
    override func viewWillAppear(animated: Bool) {
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        mdTextView.bounds.size.height = mdTextView.contentSize.height + 100
        self.preferredContentSize.height = mdTextView.bounds.size.height
    }
    
    override func viewDidLoad() {
        if let snap = self.snap {
            for team in snap.children.allObjects {
                let t = (team as! FIRDataSnapshot).value as! [String: AnyObject]
                if t["selectedImageUrl"] == nil {
<<<<<<< HEAD
                    self.updateWithText("\nTeam \(t["number"]!) has no selected image URL.", color: UIColor.blue)
=======
                    self.updateWithText("\nTeam \(t["number"]!) has no selected image URL.", color: UIColor.blueColor())
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
                }
                var dataNils : [String] = []
                for key in self.firebaseKeys {
                    if t[key] == nil && !self.ignoreKeys.contains(key) {
                        dataNils.append(key)
                    }
                }
                for dataNil in dataNils {
<<<<<<< HEAD
                    self.updateWithText("\nTeam \(t["number"]!) is missing datapoint: \(dataNil).", color: UIColor.orange)
=======
                    self.updateWithText("\nTeam \(t["number"]!) is missing datapoint: \(dataNil).", color: UIColor.orangeColor())
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
                }
            }
        }
    }
    
<<<<<<< HEAD
    func updateWithText(_ text : String, color: UIColor) {
        let currentText : NSMutableAttributedString = NSMutableAttributedString(attributedString: self.mdTextView.attributedText)
        currentText.append(NSMutableAttributedString(string: text, attributes: [NSForegroundColorAttributeName: color]))
=======
    func updateWithText(text : String, color: UIColor) {
        let currentText : NSMutableAttributedString = NSMutableAttributedString(attributedString: self.mdTextView.attributedText)
        currentText.appendAttributedString(NSMutableAttributedString(string: text, attributes: [NSForegroundColorAttributeName: color]))
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        self.mdTextView.attributedText = currentText
        mdTextView.bounds.size.height = mdTextView.contentSize.height + 100
        self.preferredContentSize.height = mdTextView.bounds.size.height
    }
    
    
    func adaptivePresentationStyleForPresentationController(
<<<<<<< HEAD
        _ controller: UIPresentationController!) -> UIModalPresentationStyle {
            return .none
    }
}
=======
        controller: UIPresentationController!) -> UIModalPresentationStyle {
            return .None
    }
}
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
