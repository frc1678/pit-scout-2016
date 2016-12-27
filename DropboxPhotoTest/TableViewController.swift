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
import Haneke

<<<<<<< HEAD
let firebaseKeys = ["pitNumberOfWheels",  "selectedImageUrl"]
=======
let firebaseKeys = ["pitNumberOfWheels", "pitOrganization", "selectedImageUrl", "pitNotes", "pitProgrammingLanguage", "pitAvailableWeight"]
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f

class TableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
    
    let cellReuseId = "teamCell"
    var firebase : FIRDatabaseReference?
    var teams : NSMutableArray = []
    var scoutedTeamInfo : [[String: Int]] = []   // ["num": 254, "hasBeenScouted": 0]
    
    var teamNums = [Int]()
<<<<<<< HEAD
    var timer = Timer()
    var photoManager : PhotoManager?
    var urlsDict : [Int : NSMutableArray] = [Int: NSMutableArray]()
    var dontNeedNotification = true
=======
    var timer = NSTimer()
    var photoManager : PhotoManager?
    var urlsDict : [Int : NSMutableArray] = [Int: NSMutableArray]()
    var dontNeedNotification = false
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
    let cache = Shared.dataCache
    var refHandle = FIRDatabaseHandle()
    var firebaseStorageRef : FIRStorageReference?
    
    @IBOutlet weak var uploadPhotos: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.allowsSelection = false //You can select once we are done setting up the photo uploader object
<<<<<<< HEAD
        firebaseStorageRef = FIRStorage.storage().reference(forURL: "gs://firebase-scouting-2016.appspot.com")
=======
        firebase = FIRDatabase.database().reference()
        firebaseStorageRef = FIRStorage.storage().referenceForURL("gs://firebase-scouting-2016.appspot.com")
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        
        
        
        // Get a reference to the storage service, using the default Firebase App
        // Create a storage reference from our storage service
        
<<<<<<< HEAD
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(TableViewController.didLongPress(_:)))
=======
        let longPress = UILongPressGestureRecognizer(target: self, action: "didLongPress:")
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        self.tableView.addGestureRecognizer(longPress)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.firebase = FIRDatabase.database().reference()
        
<<<<<<< HEAD
        self.firebase!.observe(FIRDataEventType.value, with: { (snapshot) in
            self.setup(snapshot.childSnapshot(forPath: "Teams"))
=======
        self.firebase!.observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
            self.setup(snapshot.childSnapshotForPath("Teams"))
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        })
        
        
        
        
<<<<<<< HEAD
        NotificationCenter.default.addObserver(self, selector: #selector(TableViewController.updateTitle(_:)), name: NSNotification.Name(rawValue: "titleUpdated"), object: nil)
    }
    
    func updateTitle(_ note : Notification) {
        DispatchQueue.main.async { () -> Void in
=======
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTitle:", name: "titleUpdated", object: nil)
    }
    
    func updateTitle(note : NSNotification) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
            self.title = note.object as? String
        }
    }
    
<<<<<<< HEAD
    func setup(_ snap: FIRDataSnapshot) {
=======
    func setup(snap: FIRDataSnapshot) {
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        self.teams = NSMutableArray()
        self.scoutedTeamInfo = []
        self.teamNums = []
        let teams = snap.children.allObjects
        for i in 0..<teams.count {
            let team = (teams[i] as! FIRDataSnapshot).value as! [String: AnyObject]
            //let i = teams.indexOf { (($0 as! FDataSnapshot).value as! [String: AnyObject])["number"] as? Int == team["number"] as? Int }
<<<<<<< HEAD
            self.teams.add(team)
=======
            self.teams.addObject(team)
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
            if let teamNum = team["number"] as? Int {
                let scoutedTeamInfoDict = ["num": teamNum, "hasBeenScouted": 0]
                self.scoutedTeamInfo.append(scoutedTeamInfoDict)
                self.teamNums.append(teamNum)
                if let urlsForTeam = team["otherImageUrls"] as? NSMutableDictionary {
                    let urlsArr = NSMutableArray()
                    for (_, value) in urlsForTeam {
<<<<<<< HEAD
                        urlsArr.add(value)
=======
                        urlsArr.addObject(value)
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
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
<<<<<<< HEAD
        tempArray.sortedArray(comparator: { (obj1, obj2) -> ComparisonResult in
            let o = (obj1 as! [String: Int])["num"]
            let t = (obj2 as! [String: Int])["num"]
            if(o! > t!) {
                return ComparisonResult.orderedAscending
            }
            else if(t! > o!) {
                return ComparisonResult.orderedDescending
            }
            else {
                return ComparisonResult.orderedSame
=======
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
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
            }
        })
        self.scoutedTeamInfo = tempArray as [AnyObject] as! [[String: Int]]
        //dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.tableView.reloadData()
        //})
        if dontNeedNotification { self.setupphotoManager() }
        self.cache.fetch(key: "scoutedTeamInfo").onSuccess({ [unowned self] (data) -> () in
<<<<<<< HEAD
            self.scoutedTeamInfo = NSKeyedUnarchiver.unarchiveObject(with: data) as! [[String: Int]]
=======
            self.scoutedTeamInfo = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [[String: Int]]
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
            self.tableView.reloadData()
            
            })
        //self.cache.set(value: NSKeyedArchiver.archivedDataWithRootObject(scoutedTeamInfo), key: "scoutedTeamInfo")
        
        //})
        
    }
    
    func setupphotoManager() {
        
        if self.photoManager == nil {
<<<<<<< HEAD
            self.photoManager = PhotoManager(teamsFirebase: (self.firebase?.child("Teams"))!, teamNumbers: self.teamNums)
        }
        for (teamNum, urls) in urlsDict {
            self.photoManager?.cache.set(value: NSKeyedArchiver.archivedData(withRootObject: urls), key: "sharedURLs\(teamNum)")
=======
            self.photoManager = PhotoManager(teamsFirebase: self.firebase!, teamNumbers: self.teamNums)
        }
        for (teamNum, urls) in urlsDict {
            self.photoManager?.cache.set(value: NSKeyedArchiver.archivedDataWithRootObject(urls), key: "sharedURLs\(teamNum)")
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        }
        self.tableView.allowsSelection = true
    }
    
<<<<<<< HEAD
    func teamHasBeenPitScouted(_ snap: [String: AnyObject]) -> Bool { //For some reason it wasn't working other ways
=======
    func teamHasBeenPitScouted(snap: [String: AnyObject]) -> Bool { //For some reason it wasn't working other ways
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
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
<<<<<<< HEAD
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2 //One section is for checked cells, the other unchecked
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
=======
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2 //One section is for checked cells, the other unchecked
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        if section == 0 {
            var numUnscouted = 0
            for teamN in self.scoutedTeamInfo {
                if teamN["hasBeenScouted"] == 0 {
<<<<<<< HEAD
                    numUnscouted += 1
=======
                    numUnscouted++
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
                }
            }
            return numUnscouted
        } else if section == 1 {
            var numScouted = 0
            for teamN in self.scoutedTeamInfo {
                if teamN["hasBeenScouted"] == 1 {
<<<<<<< HEAD
                    numScouted += 1
=======
                    numScouted++
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
                }
            }
            return numScouted
        }
        return 0
    }
    
<<<<<<< HEAD
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellReuseId, for: indexPath) as UITableViewCell
=======
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.cellReuseId, forIndexPath: indexPath) as UITableViewCell
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        cell.textLabel?.text = "Please Wait..."
        if self.scoutedTeamInfo.count == 0 { return cell }
        
        var text = "shouldntBeThis"
<<<<<<< HEAD
        if (indexPath as NSIndexPath).section == 1 {
            let scoutedTeamNums = NSMutableArray()
            for team in self.scoutedTeamInfo {
                if team["hasBeenScouted"] == 1 {
                    scoutedTeamNums.add(team["num"]!)
                }
            }
            text = "\(scoutedTeamNums[(indexPath as NSIndexPath).row])"
        } else if (indexPath as NSIndexPath).section == 0 {
            let notScoutedTeamNums = NSMutableArray()
            for team in self.scoutedTeamInfo {
                if team["hasBeenScouted"] == 0 {
                    notScoutedTeamNums.add(team["num"]!)
                }
            }
            text = "\(notScoutedTeamNums[(indexPath as NSIndexPath).row])"
        }
        cell.textLabel?.text = "\(text)"
        if((indexPath as NSIndexPath).section == 1) {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.none
=======
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
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        }
        return cell
    }
    
<<<<<<< HEAD
    func didLongPress(_ recognizer: UIGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.ended {
            let longPressLocation = recognizer.location(in: self.tableView)
            if let longPressedIndexPath = tableView.indexPathForRow(at: longPressLocation) {
                if let longPressedCell = self.tableView.cellForRow(at: longPressedIndexPath) {
                    if longPressedCell.accessoryType == UITableViewCellAccessoryType.checkmark {
                        longPressedCell.accessoryType = UITableViewCellAccessoryType.none
                        let scoutedTeamInfoIndex = self.scoutedTeamInfo.index { $0["num"]! == Int((longPressedCell.textLabel?.text)!) }
                        scoutedTeamInfo[scoutedTeamInfoIndex!]["hasBeenScouted"] = 0
                    } else {
                        longPressedCell.accessoryType = UITableViewCellAccessoryType.checkmark
                        let scoutedTeamInfoIndex = self.scoutedTeamInfo.index { $0["num"]! == Int((longPressedCell.textLabel?.text)!) }
                        scoutedTeamInfo[scoutedTeamInfoIndex!]["hasBeenScouted"] = 1
                    }
                    self.cache.set(value: NSKeyedArchiver.archivedData(withRootObject: scoutedTeamInfo), key: "scoutedTeamInfo")
=======
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
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
                    
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK:  UITableViewDelegate Methods
<<<<<<< HEAD
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Team View Segue" {
            var number = -1
            let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell)
            if (indexPath! as NSIndexPath).section == 1 {
                let scoutedTeamNums = NSMutableArray()
                for team in self.scoutedTeamInfo {
                    if team["hasBeenScouted"] == 1 {
                        scoutedTeamNums.add(team["num"]!)
                    }
                }
                number = scoutedTeamNums[((indexPath as NSIndexPath?)?.row)!] as! Int
            } else if (indexPath! as NSIndexPath).section == 0 {
=======
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
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
                
                let notScoutedTeamNums = NSMutableArray()
                for team in self.scoutedTeamInfo {
                    if team["hasBeenScouted"] == 0 {
<<<<<<< HEAD
                        notScoutedTeamNums.add(team["num"]!)
                    }
                }
                number = notScoutedTeamNums[((indexPath as NSIndexPath?)?.row)!] as! Int
            }
            let teamViewController = segue.destination as! ViewController
=======
                        notScoutedTeamNums.addObject(team["num"]!)
                    }
                }
                number = notScoutedTeamNums[(indexPath?.row)!] as! Int
            }
            let teamViewController = segue.destinationViewController as! ViewController
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
            
            let teamFB = self.firebase!.child("Teams").child("\(number)")
            teamViewController.ourTeam = teamFB
            teamViewController.firebase = self.firebase!
            teamViewController.number = number
            teamViewController.title = "\(number)"
            teamViewController.photoManager = self.photoManager
            teamViewController.firebaseStorageRef = self.firebaseStorageRef
        }
        else if segue.identifier == "popoverSegue" {
<<<<<<< HEAD
            let popoverViewController = segue.destination 
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.popover
            popoverViewController.popoverPresentationController!.delegate = self
            if let missingDataViewController = segue.destination as? MissingDataViewController {
                self.firebase!.child("Teams").observeSingleEvent(of: .value, with: { (snap) -> Void in
=======
            let popoverViewController = segue.destinationViewController 
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
            popoverViewController.popoverPresentationController!.delegate = self
            if let missingDataViewController = segue.destinationViewController as? MissingDataViewController {
                self.firebase!.child("Teams").observeSingleEventOfType(.Value, withBlock: { (snap) -> Void in
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
                    missingDataViewController.snap = snap
                })
            }
        }
    }
    
<<<<<<< HEAD
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    override func viewWillAppear(_ animated: Bool) {
=======
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    override func viewWillAppear(animated: Bool) {
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        if self.photoManager != nil {
            self.photoManager?.currentlyNotifyingTeamNumber = 0
        }
    }
    
<<<<<<< HEAD
}
=======
}
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
