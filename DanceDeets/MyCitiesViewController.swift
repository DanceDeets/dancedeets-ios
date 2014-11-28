//
//  MyCitiesViewController.swift
//  DanceDeets
//
//  Created by David Xiang on 11/27/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import UIKit

class MyCitiesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate {
    
    enum Mode{
        case ViewMode
        case EntryMode
    }

    var cities:[String] = []
    var autosuggestedCities:[String] = []
    var mode:Mode = MyCitiesViewController.Mode.ViewMode
    
    // MARK: Outlets
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var addCityButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var myCitiesTableView: UITableView!
    @IBOutlet weak var searchIcon: UIImageView!
    @IBOutlet weak var citySearchTextField: UITextField!
    
    // MARK: Action
    @IBAction func doneButtonTapped(sender: AnyObject) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
        })
    }
    
    @IBAction func addCityButtonTapped(sender: AnyObject) {
        toggleMode(MyCitiesViewController.Mode.EntryMode)
    }
    
    // MARK: UIViewController
    override func viewDidLoad(){
        super.viewDidLoad()
        
        myCitiesTableView.delegate = self
        myCitiesTableView.dataSource = self
        myCitiesTableView.separatorColor = ColorFactory.tableSeparatorColor()
        myCitiesTableView.allowsSelectionDuringEditing = true
        myCitiesTableView.allowsMultipleSelection = false
        citySearchTextField.delegate = self
        citySearchTextField.tintColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        citySearchTextField.font = FontFactory.textFieldFont()
        citySearchTextField.addTarget(self, action: "textFieldUpdated", forControlEvents: UIControlEvents.EditingChanged)
        
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font = FontFactory.navigationTitleFont()
        
        doneButton.titleLabel?.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        doneButton.titleLabel?.font = FontFactory.barButtonFont()
        
        cities = UserSettings.getUserCities()
        myCitiesTableView.reloadData()
        searchIcon.hidden = true
        
        let city = UserSettings.getUserCitySearch()
        var indexPathToHighlight:NSIndexPath?
        if(city == ""){
            indexPathToHighlight = NSIndexPath(forRow: 0, inSection: 0)
        }else{
            var row = 0
            for c in cities{
                if(city == c){
                    indexPathToHighlight = NSIndexPath(forRow: row+1, inSection: 0)
                    break
                }
                row += 1
            }
        }
        if(indexPathToHighlight != nil){
            let cell = myCitiesTableView.cellForRowAtIndexPath(indexPathToHighlight!)
            myCitiesTableView.selectRowAtIndexPath(indexPathToHighlight, animated: false, scrollPosition: UITableViewScrollPosition.None)
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(mode == MyCitiesViewController.Mode.ViewMode){
            return cities.count + 1
        }else if(mode == MyCitiesViewController.Mode.EntryMode){
            return autosuggestedCities.count
        }else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(mode == MyCitiesViewController.Mode.ViewMode){
            if(indexPath.row == 0){
                let cell = tableView.dequeueReusableCellWithIdentifier("currentLocationCell", forIndexPath: indexPath) as CurrentLocationCell
                return cell
            }else{
                let cell = tableView.dequeueReusableCellWithIdentifier("citySearchCell", forIndexPath: indexPath) as CitySearchCell
                cell.cityLabel.text = cities[indexPath.row - 1]
                return cell
            }
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("autosuggestCityCell", forIndexPath: indexPath) as AutosuggestCityCell
            cell.cityLabel.text = autosuggestedCities[indexPath.row]
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44;
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if(mode == MyCitiesViewController.Mode.ViewMode){
            if(indexPath.row != 0){
                return true
            }else{
                return false
            }
        }else{
            return false
        }
    }
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let cityToDelete = cities[indexPath.row - 1]
        UserSettings.deleteUserCity(cityToDelete)
        cities = UserSettings.getUserCities()
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(mode == MyCitiesViewController.Mode.ViewMode){
            var streamVC = AppDelegate.sharedInstance().eventStreamViewController()
            if(indexPath.row == 0){
                UserSettings.setUserCitySearch("")
            }else{
                let newCity = cities[indexPath.row - 1]
                UserSettings.setUserCitySearch(newCity)
            }
            streamVC?.requiresRefresh = true
        }else if(mode == MyCitiesViewController.Mode.EntryMode){
            let newSearchCity = autosuggestedCities[indexPath.row]
            UserSettings.addUserCity(newSearchCity)
            toggleMode(MyCitiesViewController.Mode.ViewMode)
        }
    }
    
    // MARK: Private
    func toggleMode(mode:MyCitiesViewController.Mode){
        if(self.mode != mode){
            self.mode = mode
            if(mode == MyCitiesViewController.Mode.ViewMode){
                searchIcon.hidden = true
                addCityButton.hidden = false
                citySearchTextField.hidden = true
                citySearchTextField.resignFirstResponder()
                titleLabel.hidden = false
                doneButton.hidden = false
                cities = UserSettings.getUserCities()
                myCitiesTableView.reloadData()
            }else if (mode == MyCitiesViewController.Mode.EntryMode){
                searchIcon.hidden = false
                addCityButton.hidden = true
                citySearchTextField.hidden = false
                citySearchTextField.text = ""
                citySearchTextField.becomeFirstResponder()
                titleLabel.hidden = true
                doneButton.hidden = true
                autosuggestedCities = []
                myCitiesTableView.reloadData()
            }
        }
    }
    
    // MARK: UITextFieldDelegate
    func textFieldUpdated(){
        let currentText = citySearchTextField.text
        if(countElements(currentText) > 0){
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            GooglePlaceAPI.autoSuggestCity(currentText, completion: { (autosuggests:[String]!, error:NSError!) -> Void in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if(error == nil){
                    dispatch_async(dispatch_get_main_queue(), {
                        self.autosuggestedCities = autosuggests
                        self.myCitiesTableView.reloadData()
                    })
                }
            })
        }else{
            autosuggestedCities = []
            myCitiesTableView.reloadData()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        toggleMode(MyCitiesViewController.Mode.ViewMode)
        return true
    }
   
}
