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
//import SwiftyJSON
import FirebaseUI
import SwiftyDropbox

class TableViewController: UITableViewController {
    
    let cellReuseId = "teamCell"
    let data = ["1678-Circus Circus", "254-Chezy Poffs"]
    var comp : Competition?
    var firebase : Firebase?
    var teams : NSMutableArray = []
    var teamNums : NSMutableArray = []
    var timer  = NSTimer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(Dropbox.authorizedClient == nil) {
            Dropbox.authorizeFromController(self)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        self.firebase = Firebase(url: "https://1678-dev-2016.firebaseio.com/Teams")
        firebase?.observeEventType(.Value, withBlock: { (snap) -> Void in
            for team in snap.children {
                self.teams.addObject(team)
                self.teamNums.addObject(team.childSnapshotForPath("number").value)
            }
            self.tableView.reloadData()
        })
        
        
    }
    
    // MARK:  UITextFieldDelegate Methods
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.teamNums.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.cellReuseId, forIndexPath: indexPath) as UITableViewCell
        if let text  = self.teamNums[indexPath.row] as? Int {
            cell.textLabel?.text = "\(text)"
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
            
            if let number : Int = self.teamNums[(indexPath?.row)!] as? Int {
                let teamViewController = segue.destinationViewController as! ViewController
                
                
                self.firebase?.childByAppendingPath("\(number)").observeSingleEventOfType(.Value, withBlock: { (snap) -> Void in
                    teamViewController.teamNum = number 
                    teamViewController.teamNam = snap.childSnapshotForPath("name").value as! String
                    teamViewController.title = "\(number)"
                })
            }
        }
    }
    
    
    
    
    
}