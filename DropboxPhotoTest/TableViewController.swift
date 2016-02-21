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

let firebaseKeys = ["pitBumperHeight", "pitDriveBaseWidth", "pitDriveBaseLength", "pitNumberOfWheels", "pitOrganization", "pitPotentialLowBarCapability", "pitPotentialMidlineBallCapability", "pitPotentialShotBlockerCapability", "selectedImageUrl", "pitNotes", "pitHeightOfBallLeavingShooter"]

class TableViewController: UITableViewController {
    
    let cellReuseId = "teamCell"
    var firebase : Firebase?
    var teams : NSMutableArray = []
    var scoutedTeamInfo : [[String: Int]] = [] // ["num": 254, "hasBeenScouted": 0]
    var teamNums = [Int]()
    var timer = NSTimer()
    var photoUploader : PhotoUploader?
    
    @IBOutlet weak var uploadPhotos: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(Dropbox.authorizedClient == nil) {
            Dropbox.authorizeFromController(self)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        

        self.firebase = Firebase(url: "https://1678-scouting-2016.firebaseio.com/Teams")
        self.firebase?.authWithCustomToken(compToken, withCompletionBlock: { (E, A) -> Void in
            self.firebase?.observeEventType(.Value, withBlock: { (snap) -> Void in
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {

                self.teams = NSMutableArray()
                self.scoutedTeamInfo = []
                self.teamNums = []
                var urlsDict : [Int : NSMutableArray] = [Int: NSMutableArray]()
                for t in snap.children.enumerate() {
                    let team = t.element
                    self.teams.addObject(team)
                    if let teamNum = team.childSnapshotForPath("number").value as? Int {
                        let scoutedTeamInfoDict = ["num": teamNum, "hasBeenScouted": -1]
                        self.scoutedTeamInfo.append(scoutedTeamInfoDict)
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
                            self.scoutedTeamInfo[t.index]["hasBeenScouted"] = 1
                        } else {
                            self.scoutedTeamInfo[t.index]["hasBeenScouted"] = 0
                        }
                    }
                    
                }
                
                let tempArray : NSMutableArray = NSMutableArray(array: self.scoutedTeamInfo)
                tempArray.sortedArrayUsingComparator({ (obj1, obj2) -> NSComparisonResult in
                    let o = obj1["num"] as! Int
                    let t = obj2["num"] as! Int
                    /*let so = obj1["hasBeenScouted"] as! Int
                    let st = obj2["hasBeenScouted"] as! Int
                    
                    if(so == 1 && st == 0) {
                    return NSComparisonResult.OrderedDescending
                    } else if(so == 0 && st == 1) {
                    return NSComparisonResult.OrderedAscending
                    }*/
                    
                    if(o > t) {
                        return NSComparisonResult.OrderedAscending
                    }
                    else if(t > o) {
                        return NSComparisonResult.OrderedDescending
                    }
                    else {
                        return NSComparisonResult.OrderedSame
                    }
                })
                self.scoutedTeamInfo = tempArray as [AnyObject] as! [[String: Int]]
                
                self.tableView.reloadData()
                
                self.setupPhotoUploader(urlsDict)
            })
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
    
    func teamHasBeenPitScouted(snap: FDataSnapshot) -> Bool { //For some reason it wasnt working other ways
        for key in firebaseKeys {
            if let _ = (snap.childSnapshotForPath(key).value) as? NSString {
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
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("There are \(self.scoutedTeamInfo.count) teams.")
        
        if section == 0 {
            var numUnscouted = 0
            for teamN in self.scoutedTeamInfo {
                if teamN["hasBeenScouted"] == 0 {
                    numUnscouted++
                }
            }
            return numUnscouted
        } else if section == 1 {
            var numScouted = 0
            for teamN in self.scoutedTeamInfo {
                if teamN["hasBeenScouted"] == 1 {
                    numScouted++
                }
            }
            return numScouted
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.cellReuseId, forIndexPath: indexPath) as UITableViewCell
        var text = "shouldntBeThis"
        //print(indexPath.section)
        if indexPath.section == 1 {
            let scoutedTeamNums = NSMutableArray()
            for team in self.scoutedTeamInfo {
                if team["hasBeenScouted"] == 1 {
                    scoutedTeamNums.addObject(team["num"]!)
                }
            }
            text = "\(scoutedTeamNums[indexPath.row])"
        } else if indexPath.section == 0 {
            
            let notScoutedTeamNums = NSMutableArray()
            for team in self.scoutedTeamInfo {
                if team["hasBeenScouted"] == 0 {
                    notScoutedTeamNums.addObject(team["num"]!)
                }
            }
            text = "\(notScoutedTeamNums[indexPath.row])"
        }
        cell.textLabel?.text = "\(text)"
        if(indexPath.section == 1) {
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
            var number = -1
            let indexPath = self.tableView.indexPathForCell(sender as! UITableViewCell)
            if indexPath!.section == 1 {
                var scoutedTeamNums = NSMutableArray()
                for team in self.scoutedTeamInfo {
                    if team["hasBeenScouted"] == 1 {
                        scoutedTeamNums.addObject(team["num"]!)
                    }
                }
                number = scoutedTeamNums[(indexPath?.row)!] as! Int
            } else if indexPath!.section == 0 {
                
                var notScoutedTeamNums = NSMutableArray()
                for team in self.scoutedTeamInfo {
                    if team["hasBeenScouted"] == 0 {
                        notScoutedTeamNums.addObject(team["num"]!)
                    }
                }
                number = notScoutedTeamNums[(indexPath?.row)!] as! Int
            }
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
    
    
    
    @IBAction func uploadPhotosPressed(sender: UIButton) {
        self.photoUploader?.mayKeepUsingNetwork = true
        self.photoUploader?.uploadAllPhotos()
        self.photoUploader?.fetchPhotosFromDropbox()
    }
    
    override func didReceiveMemoryWarning() {
        print("OH NO, MEM WARNING")
        self.photoUploader!.mayKeepUsingNetwork = false
    }
}