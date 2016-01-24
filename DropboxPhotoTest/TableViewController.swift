//
//  TableViewController.swift
//  DropboxPhotoTest
//
//  Created by Bryton Moeller on 1/18/16.
//  Copyright © 2016 citruscircuits. All rights reserved.
//
import UIKit
import Foundation

class TableViewController: UITableViewController {
    
    let cellReuseId = "teamCell"
    let data = ["1678-Circus Circus", "254-Chezy Poffs"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
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