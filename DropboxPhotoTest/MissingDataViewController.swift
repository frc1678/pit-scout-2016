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
    
    let firebaseKeys = ["pitNumberOfWheels", "pitOrganization", "selectedImageUrl", "pitNotes", "pitProgrammingLanguage", "pitAvailableWeight"]
    
    let ignoreKeys = ["pitNotes"]
    
    override func viewWillAppear(animated: Bool) {
        mdTextView.bounds.size.height = mdTextView.contentSize.height + 100
        self.preferredContentSize.height = mdTextView.bounds.size.height
    }
    
    override func viewDidLoad() {
        if let snap = self.snap {
            for team in snap.children.allObjects {
                let t = (team as! FIRDataSnapshot).value as! [String: AnyObject]
                if t["selectedImageUrl"] == nil {
                    self.updateWithText("\nTeam \(t["number"]!) has no selected image URL.", color: UIColor.blueColor())
                }
                var dataNils : [String] = []
                for key in self.firebaseKeys {
                    if t[key] == nil && !self.ignoreKeys.contains(key) {
                        dataNils.append(key)
                    }
                }
                for dataNil in dataNils {
                    self.updateWithText("\nTeam \(t["number"]!) is missing datapoint: \(dataNil).", color: UIColor.orangeColor())
                }
            }
        }
    }
    
    func updateWithText(text : String, color: UIColor) {
        let currentText : NSMutableAttributedString = NSMutableAttributedString(attributedString: self.mdTextView.attributedText)
        currentText.appendAttributedString(NSMutableAttributedString(string: text, attributes: [NSForegroundColorAttributeName: color]))
        self.mdTextView.attributedText = currentText
        mdTextView.bounds.size.height = mdTextView.contentSize.height + 100
        self.preferredContentSize.height = mdTextView.bounds.size.height
    }
    
    
    func adaptivePresentationStyleForPresentationController(
        controller: UIPresentationController!) -> UIModalPresentationStyle {
            return .None
    }
}