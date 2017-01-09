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
    
    let firebaseKeys = ["pitNumberOfWheels", "selectedImageUrl", "pitNotes", "pitProgrammingLanguage", "pitAvailableWeight", "pitTankTread", "pitOrganization"]
    
    let ignoreKeys = ["pitNotes", "pitProgrammingLanguage", "pitAvailableWeight"]
    
    override func viewWillAppear(_ animated: Bool) {
        mdTextView.bounds.size.height = mdTextView.contentSize.height + 100
        self.preferredContentSize.height = mdTextView.bounds.size.height
    }
    
    override func viewDidLoad() {
        if let snap = self.snap {
            for team in snap.children.allObjects {
                let t = (team as! FIRDataSnapshot).value as! [String: AnyObject]
                if t["selectedImageUrl"] == nil {
                    self.updateWithText("\nTeam \(t["number"]!) has no selected image URL.", color: UIColor.blue)
                }
                var dataNils : [String] = []
                for key in self.firebaseKeys {
                    if t[key] == nil && !self.ignoreKeys.contains(key) {
                        dataNils.append(key)
                    }
                }
                for dataNil in dataNils {
                    self.updateWithText("\nTeam \(t["number"]!) is missing datapoint: \(dataNil).", color: UIColor.orange)
                }
            }
        }
    }
    
    func updateWithText(_ text : String, color: UIColor) {
        let currentText : NSMutableAttributedString = NSMutableAttributedString(attributedString: self.mdTextView.attributedText)
        currentText.append(NSMutableAttributedString(string: text, attributes: [NSForegroundColorAttributeName: color]))
        self.mdTextView.attributedText = currentText
        mdTextView.bounds.size.height = mdTextView.contentSize.height + 100
        self.preferredContentSize.height = mdTextView.bounds.size.height
    }
    
    
    func adaptivePresentationStyleForPresentationController(
        _ controller: UIPresentationController!) -> UIModalPresentationStyle {
            return .none
    }
}
