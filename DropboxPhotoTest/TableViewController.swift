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
import Haneke

let dev3Token = "AEduO6VFlZKD4v10eW81u9j3ZNopr5h2R32SPpeq"
let compToken = "qVIARBnAD93iykeZSGG8mWOwGegminXUUGF2q0ee"

let firebaseKeys = ["pitNumberOfWheels", "pitOrganization", "selectedImageUrl", "pitNotes", "pitProgrammingLanguage", "pitAvailableWeight"]

class TableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
    
    let cellReuseId = "teamCell"
    var firebase : Firebase?
    var teams : NSMutableArray = []
    var scoutedTeamInfo : [[String: Int]] = []   // ["num": 254, "hasBeenScouted": 0]
        
    var teamNums = [Int]()
    var timer = NSTimer()
    var photoManager : PhotoManager?
    var urlsDict : [Int : NSMutableArray] = [Int: NSMutableArray]()
    var dontNeedNotification = false
    let cache = Shared.dataCache
    
    @IBOutlet weak var uploadPhotos: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.allowsSelection = false //You can select once we are done setting up the photo uploader object
        
        if(Dropbox.authorizedClient == nil) {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "setupphotoManager", name: "dropbox_authorized", object: nil)
            Dropbox.authorizeFromController(self)
        } else {
            dontNeedNotification = true
        }
        
        
            
        
        let longPress = UILongPressGestureRecognizer(target: self, action: "didLongPress:")
        self.tableView.addGestureRecognizer(longPress)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        self.firebase = Firebase(url: "https://1678-scouting-2016.firebaseio.com/Teams")
        if self.isConnectedToNetwork() {
            self.firebase?.authWithCustomToken(compToken, withCompletionBlock: { (E, A) -> Void in
                self.firebase?.observeEventType(.Value, withBlock: { (snap) -> Void in
                    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    self.setup(snap)
                })
            })
        } else {
            self.firebase?.observeEventType(.Value, withBlock: { (snap) -> Void in
                //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                self.setup(snap)
            })
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTitle:", name: "titleUpdated", object: nil)
    }
    
    func updateTitle(note : NSNotification) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.title = note.object as? String
        }
    }
    
    func setup(snap: FDataSnapshot) {
        self.teams = NSMutableArray()
        self.scoutedTeamInfo = []
        self.teamNums = []
        let teams = snap.children.allObjects
        for i in 0..<teams.count {
            let team = (teams[i] as! FDataSnapshot).value as! [String: AnyObject]
            //let i = teams.indexOf { (($0 as! FDataSnapshot).value as! [String: AnyObject])["number"] as? Int == team["number"] as? Int }
            self.teams.addObject(team)
            if let teamNum = team["number"] as? Int {
                let scoutedTeamInfoDict = ["num": teamNum, "hasBeenScouted": 0]
                self.scoutedTeamInfo.append(scoutedTeamInfoDict)
                self.teamNums.append(teamNum)
                if let urlsForTeam = team["otherImageUrls"] as? NSMutableDictionary {
                    let urlsArr = NSMutableArray()
                    for (_, value) in urlsForTeam {
                        urlsArr.addObject(value)
                    }
                    urlsDict[teamNum] = urlsArr
                } else {
                    urlsDict[teamNum] = NSMutableArray()
                }
                if(self.scoutedTeamInfo.count > i) {
                    /*if(self.teamHasBeenPitScouted(team)) {
                        self.scoutedTeamInfo[i]["hasBeenScouted"] = 1
                    } else {
                        self.scoutedTeamInfo[i]["hasBeenScouted"] = 0
                    }*/
                } else {
                    print("ERROR")
                   /* let scoutedTeamInfoDict = ["num": teamNum, "hasBeenScouted": -1]
                    self.scoutedTeamInfo.append(scoutedTeamInfoDict)
                    if(self.teamHasBeenPitScouted(team as! FDataSnapshot)) {
                        self.scoutedTeamInfo[t.index]["hasBeenScouted"] = 1
                    } else {
                        self.scoutedTeamInfo[t.index]["hasBeenScouted"] = 0
                    }*/
                }
                
            } else {
                print("No Num")
            }

            
        }
        
        let tempArray : NSMutableArray = NSMutableArray(array: self.scoutedTeamInfo)
        tempArray.sortedArrayUsingComparator({ (obj1, obj2) -> NSComparisonResult in
            let o = obj1["num"] as! Int
            let t = obj2["num"] as! Int
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
        //dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.tableView.reloadData()
        //})
        if dontNeedNotification { self.setupphotoManager() }
        self.cache.fetch(key: "scoutedTeamInfo").onSuccess({ [unowned self] (data) -> () in
            self.scoutedTeamInfo = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [[String: Int]]
            self.tableView.reloadData()
            
            })
        //self.cache.set(value: NSKeyedArchiver.archivedDataWithRootObject(scoutedTeamInfo), key: "scoutedTeamInfo")

        //})

    }
    
    func setupphotoManager() {

        if self.photoManager == nil {
            self.photoManager = PhotoManager(teamsFirebase: self.firebase!, teamNumbers: self.teamNums, syncButton: self.uploadPhotos)
        }
        for (teamNum, urls) in urlsDict {
            self.photoManager?.cache.set(value: NSKeyedArchiver.archivedDataWithRootObject(urls), key: "sharedURLs\(teamNum)")
        }
        self.tableView.allowsSelection = true
    }
    
    func teamHasBeenPitScouted(snap: [String: AnyObject]) -> Bool { //For some reason it wasnt working other ways
        for key in firebaseKeys {
            if let _ = (snap[key]) as? NSString {
            } else {
                if let _ = (snap[key]) as? NSNumber {
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
        cell.textLabel?.text = "Please Wait..."
        if self.scoutedTeamInfo.count == 0 { return cell }
        
        var text = "shouldntBeThis"
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
    
    func didLongPress(recognizer: UIGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.Ended {
            let longPressLocation = recognizer.locationInView(self.tableView)
            if let longPressedIndexPath = tableView.indexPathForRowAtPoint(longPressLocation) {
                if let longPressedCell = self.tableView.cellForRowAtIndexPath(longPressedIndexPath) {
                    if longPressedCell.accessoryType == UITableViewCellAccessoryType.Checkmark {
                        longPressedCell.accessoryType = UITableViewCellAccessoryType.None
                        let scoutedTeamInfoIndex = self.scoutedTeamInfo.indexOf { $0["num"]! == Int((longPressedCell.textLabel?.text)!) }
                        scoutedTeamInfo[scoutedTeamInfoIndex!]["hasBeenScouted"] = 0
                    } else {
                        longPressedCell.accessoryType = UITableViewCellAccessoryType.Checkmark
                        let scoutedTeamInfoIndex = self.scoutedTeamInfo.indexOf { $0["num"]! == Int((longPressedCell.textLabel?.text)!) }
                        scoutedTeamInfo[scoutedTeamInfoIndex!]["hasBeenScouted"] = 1
                    }
                    self.cache.set(value: NSKeyedArchiver.archivedDataWithRootObject(scoutedTeamInfo), key: "scoutedTeamInfo")

                    self.tableView.reloadData()
                }
            }
        }
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
                let scoutedTeamNums = NSMutableArray()
                for team in self.scoutedTeamInfo {
                    if team["hasBeenScouted"] == 1 {
                        scoutedTeamNums.addObject(team["num"]!)
                    }
                }
                number = scoutedTeamNums[(indexPath?.row)!] as! Int
            } else if indexPath!.section == 0 {
                
                let notScoutedTeamNums = NSMutableArray()
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
            teamViewController.photoManager = self.photoManager
            teamViewController.firebaseKeys = firebaseKeys
            teamFB!.observeSingleEventOfType(.Value, withBlock: { (snap) -> Void in
                teamViewController.name = snap.childSnapshotForPath("name").value as! String
            })
        }
        else if segue.identifier == "popoverSegue" {
            let popoverViewController = segue.destinationViewController 
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
            popoverViewController.popoverPresentationController!.delegate = self
            if let missingDataViewController = segue.destinationViewController as? MissingDataViewController {
                self.firebase!.observeSingleEventOfType(.Value, withBlock: { (snap) -> Void in
                    missingDataViewController.snap = snap
                })
            }
        }
    }
    
    @IBAction func uploadPhotosPressed(sender: UIButton) {
        self.photoManager!.checkInternetAndSync(self.timer)
    }
    
    override func didReceiveMemoryWarning() {
        print("OH NO, MEM WARNING")
        
        //self.photoManager?.mayKeepWorking = false
    }
    
    func isConnectedToNetwork() -> Bool  {
        let url = NSURL(string: "https://www.google.com/")
        let data = NSData(contentsOfURL: url!)
        if (data != nil) {
            return(true)
        }
        return(false)
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    
    override func viewWillAppear(animated: Bool) {
        if self.photoManager != nil {
            self.photoManager?.currentlyNotifyingTeamNumber = 0
        }
        UIApplication.sharedApplication().performSelector("_performMemoryWarning")
    }
    
}