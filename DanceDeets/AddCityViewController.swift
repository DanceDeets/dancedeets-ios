//
//  AddCityViewController.swift
//  DanceDeets
//
//  Created by David Xiang on 12/24/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import Foundation

class AddCityViewController : UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate

{
    @IBOutlet weak var searchIcon: UIImageView!
    @IBOutlet weak var citySearchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var autosuggestedCities:[String] = []
    var backgroundView:UIView?
    var settingsVC:SettingsViewController!
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        searchIcon.tintColor = ColorFactory.white50()
        tableView.dataSource = self
        tableView.delegate = self
        
        // init the text field
        citySearchTextField.delegate = self
        citySearchTextField.tintColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        citySearchTextField.font = FontFactory.textFieldFont()
        citySearchTextField.addTarget(self, action: "textFieldUpdated", forControlEvents: UIControlEvents.EditingChanged)
        var attributedPlaceholder = NSMutableAttributedString(string: "Location Search")
        attributedPlaceholder.setColor(ColorFactory.white50())
        attributedPlaceholder.setFont(FontFactory.textFieldFont())
        citySearchTextField.attributedPlaceholder = attributedPlaceholder
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        citySearchTextField.becomeFirstResponder()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // MARK: Private
    func textFieldUpdated(){
        let currentText = citySearchTextField.text
        if(count(currentText) > 0){
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            GooglePlaceAPI.autoSuggestCity(currentText, completion: { (autosuggests:[String]!, error:NSError!) -> Void in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if(error == nil){
                    dispatch_async(dispatch_get_main_queue(), {
                        self.autosuggestedCities = autosuggests
                        self.tableView.reloadData()
                    })
                }
            })
        }else{
            autosuggestedCities = []
            tableView.reloadData()
        }
    }

    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autosuggestedCities.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("autosuggestCityCell", forIndexPath: indexPath) as! AutosuggestCityCell
        cell.cityLabel.text = autosuggestedCities[indexPath.row]
        
        let userCities = UserSettings.getUserCities()
        if(find(userCities,autosuggestedCities[indexPath.row]) != nil){
            let checkImage = UIImage(named: "checkIcon")
            cell.addLogoButton.setImage(checkImage, forState: UIControlState.Normal)
            cell.addLogoButton.tintColor = UIColor.whiteColor()
        }else{
            let checkImage = UIImage(named: "addIcon")
            cell.addLogoButton.setImage(checkImage, forState: UIControlState.Normal)
            cell.addLogoButton.tintColor = ColorFactory.white50()
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let newSearchCity = autosuggestedCities[indexPath.row]
        UserSettings.addUserCity(newSearchCity)
        UserSettings.setUserCitySearch(newSearchCity)
        AppDelegate.sharedInstance().eventStreamViewController()?.requiresRefresh = true
        settingsVC.presentingViewController?.dismissViewControllerAnimated(false, completion: nil)
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        presentingViewController?.dismissViewControllerAnimated(false, completion: nil)
        return true
    }
    
}