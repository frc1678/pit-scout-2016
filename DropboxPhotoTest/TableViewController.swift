//
//  TableViewController.swift
//  DropboxPhotoTest
//
//  Created by Bryton Moeller on 1/18/16.
//  Copyright © 2016 citruscircuits. All rights reserved.
//
import UIKit
import Foundation
import Firebase
import firebase_schema_2016_ios
import SwiftyDropbox

let dev3Token = "AEduO6VFlZKD4v10eW81u9j3ZNopr5h2R32SPpeq"
let compToken = "qVIARBnAD93iykeZSGG8mWOwGegminXUUGF2q0ee"

let firebaseKeys = ["pitBumperHeight", "pitDriveBaseWidth", "pitDriveBaseLength", "pitNumberOfWheels", "pitOrganization", "pitPotentialLowBarCapability", "pitPotentialMidlineBallCapability", "pitPotentialShotBlockerCapability", "selectedImageUrl"]

class TableViewController: UITableViewController {
    
    let cellReuseId = "teamCell"
    var firebase : Firebase?
    var teams : NSMutableArray = []
    var teamNums : [Int] = []
    var donePitscouting : NSMutableArray = []
    var timer = NSTimer()
    var photoUploader : PhotoUploader?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(Dropbox.authorizedClient == nil) {
            Dropbox.authorizeFromController(self)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.firebase = Firebase(url: "https://1678-scouting-2016.firebaseio.com/Teams")
        firebase?.authWithCustomToken(compToken, withCompletionBlock: { (E, A) -> Void in
            self.firebase?.observeEventType(.Value, withBlock: { (snap) -> Void in
                self.teams = NSMutableArray()
                self.teamNums = []
                var urlsDict : [Int : NSMutableArray] = [Int: NSMutableArray]()
                for t in snap.children.enumerate() {
                    let team = t.element
                    self.teams.addObject(team)
                    if let teamNum = team.childSnapshotForPath("number").value as? Int {
                        self.teamNums.append(teamNum)
                        
                        if let urlsForTeam = team.childSnapshotForPath("otherImageUrls").value as? NSMutableDictionary {
                            let urlsArr = NSMutableArray()
                            for (_, value) in urlsForTeam {
                                urlsArr.addObject(value)
                            }
                            urlsDict[teamNum] = urlsArr
                        } else {
                            urlsDict[teamNum] = NSMutableArray()
                        }
                        
                        if(self.teamHasBeenPitScouted(team as! FDataSnapshot)) {
                            self.donePitscouting[t.index] = true
                        } else {
                            self.donePitscouting[t.index] = false
                        }
                    }
                    
                }
                
                let tempArray : NSMutableArray = NSMutableArray(array: self.teamNums)
                tempArray.sortedArrayUsingComparator({ (obj1, obj2) -> NSComparisonResult in
                    let o = obj1 as! Int
                    let t = obj2 as! Int
                    
                    if(o > t) { return NSComparisonResult.OrderedAscending }
                    else if(t > o) { return NSComparisonResult.OrderedDescending }
                    else { return NSComparisonResult.OrderedSame }
                })
                self.teamNums = tempArray as [AnyObject] as! [Int]
                
                self.tableView.reloadData()
                
                self.setupPhotoUploader(urlsDict)
            })
        })
        
    }
    
    func setupPhotoUploader(urlsDict: [Int : NSMutableArray]) {
        if self.photoUploader == nil {
            self.photoUploader = PhotoUploader(teamsFirebase: self.firebase!, teamNumbers: self.teamNums)
            self.photoUploader?.sharedURLs = urlsDict
        } else {
            self.photoUploader?.sharedURLs = urlsDict
        }
    }
    
    func teamHasBeenPitScouted(snap: FDataSnapshot) -> Bool {
        for key in firebaseKeys {
            if let o = (snap.childSnapshotForPath(key).value) as? NSString {
                print(o)
            } else {
                if let _ = (snap.childSnapshotForPath(key).value) as? NSNumber {
                    
                } else {
                    return false
                }
            }
        }
        return true
    }
    
    // MARK:  UITextFieldDelegate Methods
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("There are \(self.teamNums.count) teams.")
        return self.teamNums.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.cellReuseId, forIndexPath: indexPath) as UITableViewCell
        let text  = self.teamNums[indexPath.row]
        cell.textLabel?.text = "\(text)"
        if(self.donePitscouting[indexPath.row] as! Bool == true) {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        return cell
    }
    
    // MARK:  UITableViewDelegate Methods
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Team View Segue" {
            let indexPath = self.tableView.indexPathForCell(sender as! UITableViewCell)
            
            if let number : Int = self.teamNums[(indexPath?.row)!] {
                let teamViewController = segue.destinationViewController as! ViewController
                
                let teamFB = self.firebase?.childByAppendingPath("\(number)")
                teamViewController.ourTeam = teamFB
                teamViewController.firebase = self.firebase
                teamViewController.number = number
                teamViewController.title = "\(number)"
                teamViewController.photoUploader = self.photoUploader
                teamViewController.firebaseKeys = firebaseKeys
                teamFB!.observeSingleEventOfType(.Value, withBlock: { (snap) -> Void in
                    teamViewController.name = snap.childSnapshotForPath("name").value as! String
                })
            }
        }
    }
}