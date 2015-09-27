//
//  SearchBar.swift
//  DanceDeets
//
//  Created by LambertMike on 2015/09/26.
//  Copyright © 2015年 david.xiang. All rights reserved.
//

import Foundation

class SearchBar : NSObject, UITextFieldDelegate {

    typealias SearchHandler = (String, String) -> Void

    var controller: EventStreamViewController
    var searchHandler: SearchHandler
    var blurOverlay: UIView?

    init(controller: EventStreamViewController, searchHandler: SearchHandler) {
        self.controller = controller
        self.searchHandler = searchHandler
        super.init()

        // auto suggest terms when search text field is tapped
        /*
        searchAutoSuggestTableView.alpha = 0
        searchAutoSuggestTableView.backgroundColor = UIColor.clearColor()
        searchAutoSuggestTableView.delegate = self
        searchAutoSuggestTableView.dataSource = self
        searchAutoSuggestTableView.registerClass(SearchAutoSuggestTableCell.classForCoder(), forCellReuseIdentifier: "autoSuggestCell")
        searchAutoSuggestTableView.contentInset = UIEdgeInsetsMake(CUSTOM_NAVIGATION_BAR_HEIGHT, 0, 300, 0)

        searchTextCancelButton.alpha = 0.0
        searchTextCancelButton.tintColor = ColorFactory.white50()
        */

        // search text field styling
        configureField(controller.locationSearchField, defaultText: "Location", iconName: "pinIcon")
        configureField(controller.keywordSearchField, defaultText: "Keywords", iconName: "searchIconSmall")

        // blur overlay is used for background of auto suggest table
        blurOverlay = controller.view.addDarkBlurOverlay()
        controller.view.insertSubview(blurOverlay!, belowSubview: controller.customNavigationView)
        blurOverlay?.alpha = 0
    }
    
    func configureField(field: UITextField, defaultText: String, iconName: String) {
        let placeholder = NSMutableAttributedString(string: defaultText)
        placeholder.setColor(ColorFactory.white50())
        placeholder.setFont(UIFont(name: "Interstate-Light", size: 12.0)!)
        field.attributedPlaceholder = placeholder

        let imageView:UIImageView = UIImageView(image: UIImage(named: iconName)!)
        imageView.tintColor = ColorFactory.white50()
        imageView.contentMode = UIViewContentMode.Right
        imageView.frame = CGRectMake(0, 0, imageView.image!.size.width + 10, imageView.image!.size.height)
        field.delegate = self
        field.clearButtonMode = UITextFieldViewMode.WhileEditing
        field.leftView = imageView
        field.leftViewMode = UITextFieldViewMode.Always
        field.textAlignment = .Left
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        blurOverlay?.fadeOut(0.5, completion: nil)
        searchHandler(controller.locationSearchField.text!, controller.keywordSearchField.text!)
        return true
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        blurOverlay?.fadeIn(0.5, completion: nil)
    }

    /*
    func textFieldUpdated(){
        let currentText = locationSearchField.text
        if (currentText?.characters.count > 0) {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            GooglePlaceAPI.autoSuggestCity(currentText!, completion: { (autosuggests: [String]!, error: NSError!) -> Void in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if (error == nil) {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.autosuggestedCities = autosuggests
                        self.tableView.reloadData()
                    })
                }
            })
        } else {
            autosuggestedCities = []
            tableView.reloadData()
        }
    }

    // MARK: UITableViewDataSource / UITableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if(tableView == searchAutoSuggestTableView){
            return 1
        } else {
            return 0
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == searchAutoSuggestTableView){
            return SEARCH_AUTOSUGGEST_TERMS.count
        } else {
            return 0
        }
    }

    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.min
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.min
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(tableView == searchAutoSuggestTableView){
            let cell = tableView.dequeueReusableCellWithIdentifier("autoSuggestCell", forIndexPath: indexPath) as! SearchAutoSuggestTableCell
            let term = SEARCH_AUTOSUGGEST_TERMS[indexPath.row]
            cell.titleLabel!.text = term
            return cell
        }else{
            // shouldn't happen
            return tableView.dequeueReusableCellWithIdentifier("autoSuggestCell", forIndexPath: indexPath) as! SearchAutoSuggestTableCell
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(tableView == searchAutoSuggestTableView){
            let term = SEARCH_AUTOSUGGEST_TERMS[indexPath.row] as String
            searchKeyword = term
            hideAutoSuggestTable()

            refreshEvents()
        }
    }

    func showAutoSuggestTable(){
        blurOverlay?.fadeIn(0.5, completion: nil)

        view.layoutIfNeeded()
        UIView.animateWithDuration(0.25, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
            self.searchTextTrailingConstraint.constant = 80
            self.view.layoutIfNeeded()
            }) { (bool:Bool) -> Void in
                return
        }
        UIView.animateWithDuration(0.25, delay: 0.25, options: .CurveEaseInOut, animations: { () -> Void in
            self.searchTextCancelButton.alpha = 1.0
            self.searchAutoSuggestTableView.alpha = 1.0
            }) { (bool:Bool) -> Void in
                return
        }

        searchTextField.text = ""
        searchTextField.becomeFirstResponder()
    }

    func hideAutoSuggestTable(){
        blurOverlay?.fadeOut(0.5, completion: nil)

        view.layoutIfNeeded()
        UIView.animateWithDuration(0.25, delay: 0.25, options: .CurveEaseInOut, animations: { () -> Void in
            self.searchTextTrailingConstraint.constant = 12
            self.view.layoutIfNeeded()
            }) { (bool:Bool) -> Void in
                return
        }
        UIView.animateWithDuration(0.25, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
            self.searchTextCancelButton.alpha = 0
            self.searchAutoSuggestTableView.alpha = 0
            }) { (bool:Bool) -> Void in
                return
        }
        view.endEditing(true)
    }
    */

}