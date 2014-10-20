//
//  SettingsTableViewController.swift
//  DanceDeets
//
//  Created by David Xiang on 10/4/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, UITextFieldDelegate, BasicSwitchTableCellDelegate {
    
    var showingCustomCityRow:Bool = false
    var locationToggleCell:BasicSwitchTableCell?
    var customCityCell:CustomCityTableViewCell?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    // MARK: - UITableViewDataSource / UITableViewDelegate
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            if(showingCustomCityRow){
                return 2
            }else{
                return 1
            }
        }
        else{
            return 0
        }
    }
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0){
            return "SEARCH OPTIONS"
        }else{
            return ""
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell? = UITableViewCell()
        if(indexPath.section == 0){
            if(indexPath.row == 0){
                locationToggleCell = tableView.dequeueReusableCellWithIdentifier("basicSwitchTableCell", forIndexPath: indexPath) as? BasicSwitchTableCell
                locationToggleCell?.delegate = self
                locationToggleCell?.titleLabel.text = "Use My Location"
                cell = locationToggleCell
            }else if(indexPath.row == 1){
                customCityCell = tableView.dequeueReusableCellWithIdentifier("customCityCell", forIndexPath:indexPath) as? CustomCityTableViewCell
                customCityCell?.inputTextField.delegate = self
                cell = customCityCell
            }
        }
        return cell!
    }
    
    func switchToggled(sender: UISwitch!) {
        if(sender.on){
            showingCustomCityRow = false
            let newIndexPath = NSIndexPath(forRow: 1, inSection: 0)
            tableView.deleteRowsAtIndexPaths([newIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            locationToggleCell?.titleLabel.textColor = UIColor.blackColor()
        }else{
            showingCustomCityRow = true
            let newIndexPath = NSIndexPath(forRow: 1, inSection: 0)
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            locationToggleCell?.titleLabel.textColor = UIColor.lightGrayColor()
            customCityCell?.inputTextField.becomeFirstResponder()
        }
    }
  
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let eventTableVC:EventFeedTableViewController? = appDelegate.eventFeedTableViewController()
        if(countElements(textField.text) == 0){
            locationToggleCell?.locationToggle.setOn(true, animated: true)
            let newIndexPath = NSIndexPath(forRow: 1, inSection: 0)
            showingCustomCityRow = false
            tableView.deleteRowsAtIndexPaths([newIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            locationToggleCell?.titleLabel.textColor = UIColor.blackColor()
            
            // if customCity is set in user defaults, user set a default city to search for events
            NSUserDefaults.standardUserDefaults().setNilValueForKey("customCity")
            NSUserDefaults.standardUserDefaults().synchronize()
            eventTableVC?.searchMode =  EventFeedSearchMode.CurrentLocation
        }else{
            let customCity:String = textField.text
            
            NSUserDefaults.standardUserDefaults().setValue(customCity, forKey: "customCity")
            NSUserDefaults.standardUserDefaults().synchronize()
            eventTableVC?.searchMode =  EventFeedSearchMode.CustomCity
            eventTableVC?.currentCity = customCity
        }
        
        textField.resignFirstResponder()
        return true
    }
    
    

}
