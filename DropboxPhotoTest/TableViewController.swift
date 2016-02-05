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
import SwiftyJSON
import FirebaseUI

class TableViewController: UITableViewController {
    
    let cellReuseId = "teamCell"
    let data = ["1678-Circus Circus", "254-Chezy Poffs"]
    var comp : Competition?
    var firebase : Firebase?
    var teams : [NSDictionary] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.firebase = Firebase(url: "https://1678-dev-2016.firebaseio.com/Teams")

        tableView.delegate = self
        tableView.dataSource = self
        self.firebase!.authUser("jenny@example.com", password: "correcthorsebatterystaple") {
            error, authData in
            if error != nil {
                print("Firebase Login Successful")
                self.firebase?.observeEventType(.ChildChanged, withBlock: { (snapshot) -> Void in
                    self.teams.append(snapshot.value as! [String: AnyObject])
                })
                self.firebase?.observeEventType(.Value, withBlock: { (snapshot) -> Void in
                    self.tableView.reloadData()
                })
            } else {
                // user is logged in, check authData for data
                print("Firebase Login Failed")
            }
        }
    }
    
    // MARK:  UITextFieldDelegate Methods
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.cellReuseId, forIndexPath: indexPath) as UITableViewCell
        
        let row = indexPath.row
        cell.textLabel?.text = data[row]
        
        return cell
    }
    
    // MARK:  UITableViewDelegate Methods
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Team View Segue" {
            
            let teamViewController = segue.destinationViewController as! ViewController
            let indexPath = self.tableView.indexPathForCell(sender as! UITableViewCell)
            let numNameArray = data[indexPath!.row].characters.split("-")
            print(String(numNameArray[1]))
            teamViewController.teamNum = Int(String(numNameArray[0]))!
            teamViewController.teamNam = String(numNameArray[1])
            teamViewController.title = data[indexPath!.row]
        }
    }
}