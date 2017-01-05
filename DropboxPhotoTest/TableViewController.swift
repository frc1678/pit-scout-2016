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

let firebaseKeys = ["pitNumberOfWheels",  "selectedImageUrl"]

class TableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
    
    let cellReuseId = "teamCell"
    var firebase : FIRDatabaseReference?
    var teams : NSMutableArray = []
    var scoutedTeamInfo : [[String: Int]] = []   // ["num": 254, "hasBeenScouted": 0]
    
    var teamNums = [Int]()
    var timer = Timer()
    var photoManager : PhotoManager?
    var urlsDict : [Int : NSMutableArray] = [Int: NSMutableArray]()
    var dontNeedNotification = true
    let cache = Shared.dataCache
    var refHandle = FIRDatabaseHandle()
    var firebaseStorageRef : FIRStorageReference?
    
    @IBOutlet weak var uploadPhotos: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.allowsSelection = false //You can select once we are done setting up the photo uploader object
        firebaseStorageRef = FIRStorage.storage().reference(forURL: "gs://firebase-scouting-2016.appspot.com")
        
        
        
        // Get a reference to the storage service, using the default Firebase App
        // Create a storage reference from our storage service
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(TableViewController.didLongPress(_:)))
        self.tableView.addGestureRecognizer(longPress)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.firebase = FIRDatabase.database().reference()
        
        self.firebase!.observe(FIRDataEventType.value, with: { (snapshot) in
            self.setup(snapshot.childSnapshot(forPath: "Teams"))
        })
        
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(TableViewController.updateTitle(_:)), name: NSNotification.Name(rawValue: "titleUpdated"), object: nil)
    }
    
    func updateTitle(_ note : Notification) {
        DispatchQueue.main.async { () -> Void in
            self.title = note.object as? String
        }
    }
    
    func setup(_ snap: FIRDataSnapshot) {
        self.teams = NSMutableArray()
        self.scoutedTeamInfo = []
        self.teamNums = []
        let teams = snap.children.allObjects
        for i in 0..<teams.count {
            let team = (teams[i] as! FIRDataSnapshot).value as! [String: AnyObject]
            //let i = teams.indexOf { (($0 as! FDataSnapshot).value as! [String: AnyObject])["number"] as? Int == team["number"] as? Int }
            self.teams.add(team)
            if let teamNum = team["number"] as? Int {
                let scoutedTeamInfoDict = ["num": teamNum, "hasBeenScouted": 0]
                self.scoutedTeamInfo.append(scoutedTeamInfoDict)
                self.teamNums.append(teamNum)
                if let urlsForTeam = team["otherImageUrls"] as? NSMutableDictionary {
                    let urlsArr = NSMutableArray()
                    for (_, value) in urlsForTeam {
                        urlsArr.add(value)
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
            }
        })
        self.scoutedTeamInfo = tempArray as [AnyObject] as! [[String: Int]]
        //dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.tableView.reloadData()
        //})
        if dontNeedNotification { self.setupphotoManager() }
        self.cache.fetch(key: "scoutedTeamInfo").onSuccess({ [unowned self] (data) -> () in
            self.scoutedTeamInfo = NSKeyedUnarchiver.unarchiveObject(with: data) as! [[String: Int]]
            self.tableView.reloadData()
            
            })
        //self.cache.set(value: NSKeyedArchiver.archivedDataWithRootObject(scoutedTeamInfo), key: "scoutedTeamInfo")
        
        //})
        self.tableView.reloadData()
        
    }
    
    func setupphotoManager() {
        
        if self.photoManager == nil {
            self.photoManager = PhotoManager(teamsFirebase: (self.firebase?.child("Teams"))!, teamNumbers: self.teamNums)
        }
        for (teamNum, urls) in urlsDict {
            self.photoManager?.cache.set(value: NSKeyedArchiver.archivedData(withRootObject: urls), key: "sharedURLs\(teamNum)")
        }
        self.tableView.allowsSelection = true
    }
    
    func teamHasBeenPitScouted(_ snap: [String: AnyObject]) -> Bool { //For some reason it wasn't working other ways
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
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2 //One section is for checked cells, the other unchecked
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            var numUnscouted = 0
            for teamN in self.scoutedTeamInfo {
                if teamN["hasBeenScouted"] == 0 {
                    numUnscouted += 1
                }
            }
            return numUnscouted
        } else if section == 1 {
            var numScouted = 0
            for teamN in self.scoutedTeamInfo {
                if teamN["hasBeenScouted"] == 1 {
                    numScouted += 1
                }
            }
            return numScouted
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellReuseId, for: indexPath) as UITableViewCell
        cell.textLabel?.text = "Please Wait..."
        if self.scoutedTeamInfo.count == 0 { return cell }
        
        var text = "shouldntBeThis"
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
        }
        return cell
    }
    
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
                    
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK:  UITableViewDelegate Methods
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
                
                let notScoutedTeamNums = NSMutableArray()
                for team in self.scoutedTeamInfo {
                    if team["hasBeenScouted"] == 0 {
                        notScoutedTeamNums.add(team["num"]!)
                    }
                }
                number = notScoutedTeamNums[((indexPath as NSIndexPath?)?.row)!] as! Int
            }
            let teamViewController = segue.destination as! ViewController
            
            let teamFB = self.firebase!.child("Teams").child("\(number)")
            teamViewController.ourTeam = teamFB
            teamViewController.firebase = self.firebase!
            teamViewController.number = number
            teamViewController.title = "\(number)"
            teamViewController.photoManager = self.photoManager
            teamViewController.firebaseStorageRef = self.firebaseStorageRef
        }
        else if segue.identifier == "popoverSegue" {
            let popoverViewController = segue.destination 
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.popover
            popoverViewController.popoverPresentationController!.delegate = self
            if let missingDataViewController = segue.destination as? MissingDataViewController {
                self.firebase!.child("Teams").observeSingleEvent(of: .value, with: { (snap) -> Void in
                    missingDataViewController.snap = snap
                })
            }
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.photoManager != nil {
            self.photoManager?.currentlyNotifyingTeamNumber = 0
        }
    }
    
    @IBAction func myShareButton(sender: UIBarButtonItem) {
        self.firebase?.observeSingleEvent(of: FIRDataEventType.value, with: { (snap) -> Void in
            do {
                let theJSONData = try JSONSerialization.data(
                    withJSONObject: self.teams ,
                    options: JSONSerialization.WritingOptions())
                let theJSONText = NSString(data: theJSONData,
                                           encoding: String.Encoding.ascii.rawValue)
                let activityViewController = UIActivityViewController(activityItems: [theJSONText], applicationActivities: nil)
                self.present(activityViewController, animated: true, completion: {})
            } catch {
                print(error.localizedDescription)
            }
        })
        
    }}
