//
//  SearchBar.swift
//  DanceDeets
//
//  Created by LambertMike on 2015/09/26.
//  Copyright © 2015年 david.xiang. All rights reserved.
//

import CoreLocation
import Foundation

class SearchBar : NSObject, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    typealias SearchHandler = (String, String) -> Void

    var controller: EventStreamViewController
    var searchHandler: SearchHandler
    var blurOverlay: UIView?
    var autosuggestedLocations:[String] = []
    var autosuggestedKeywords:[String] = [
        "Bboy",
        "Breaking",
        "Hip-Hop",
        "House",
        "Popping",
        "Locking",
        "Waacking",
        "Dancehall",
        "Vogue",
        "Krumping",
        "Turfing",
        "Litefeet",
        "Flexing",
        "Bebop",
        "All-Styles"
    ]

    var currentGeooder:CurrentGeocode?

    weak var activeTextField: UITextField?

    init(controller: EventStreamViewController, searchHandler: SearchHandler) {
        self.controller = controller
        self.searchHandler = searchHandler
        super.init()

        // auto suggest terms when search text field is tapped
        controller.autosuggestTable.alpha = 0
        controller.autosuggestTable.backgroundColor = UIColor.clearColor()
        controller.autosuggestTable.delegate = self
        controller.autosuggestTable.dataSource = self
        controller.autosuggestTable.tintColor = ColorFactory.white50()

        controller.searchTextCancelButton.alpha = 0
        controller.searchTextCancelButton.addTarget(self, action: "endEditing", forControlEvents: .TouchUpInside)
        controller.locationSearchField.addTarget(self, action: "locationFieldUpdated", forControlEvents: UIControlEvents.EditingChanged)

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

    func textFieldDidEndEditing(textField: UITextField) {
        self.autosuggestedLocations = []
        activeTextField = nil
        self.controller.autosuggestTable.reloadData()
    }

    func endEditing() {
        UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
            self.blurOverlay?.alpha = 0.0
            self.controller.autosuggestTable?.alpha = 0.0
            self.controller.searchTextCancelButton.alpha = 0.0
            self.controller.settingsButton.alpha = 1.0
            self.controller.textFieldsEqualWidthConstraint.priority = 900
            self.controller.locationMaxWidthConstraint.priority = 500
            self.controller.keywordMaxWidthConstraint.priority = 500

            self.controller.navigationTitle.alpha = 1

            self.controller.view.layoutIfNeeded()
            }) {(Bool)->Void in
                controller.view.endEditing(true)
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        endEditing()
        searchHandler(controller.locationSearchField.text!, controller.keywordSearchField.text!)
        return true
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        activeTextField = textField
        controller.autosuggestTable.reloadData()

        // Fade in the overlay, table, and new textfield constraints
        UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
            self.blurOverlay?.alpha = 1.0
            self.controller.autosuggestTable?.alpha = 1.0
            self.controller.textFieldsEqualWidthConstraint.priority = 500
            self.controller.settingsButton.alpha = 0.0
            if (textField == self.controller.locationSearchField) {
                self.controller.locationMaxWidthConstraint.priority = 900
                self.controller.keywordMaxWidthConstraint.priority = 500
            } else {
                self.controller.keywordMaxWidthConstraint.priority = 900
                self.controller.locationMaxWidthConstraint.priority = 500
            }
            self.controller.view.layoutIfNeeded()
            }) {(Bool)->Void in
        }
        // Fade in/out the title with the cancel button (at the same overall speed as the above fade)
        UIView.animateWithDuration(0.25, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
                self.controller.navigationTitle.alpha = 0
            }) {(Bool)->Void in
                UIView.animateWithDuration(0.25, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
                    self.controller.searchTextCancelButton.alpha = 1.0
                    }) {(Bool)->Void in }
        }
    }

    func locationFieldUpdated() {
        let currentText = controller.locationSearchField.text
        if (currentText?.characters.count > 0) {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            GooglePlaceAPI.autoSuggestCity(currentText!, completion: { (autosuggests: [String]!, error: NSError!) -> Void in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if (error == nil) {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.autosuggestedLocations = autosuggests
                        self.controller.autosuggestTable.reloadData()
                    })
                }
            })
        } else {
            autosuggestedLocations = []
            controller.autosuggestTable.reloadData()
        }
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (activeTextField == controller.locationSearchField) {
            return 2
        } else {
            return 1
        }
    }

    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (activeTextField == controller.locationSearchField) {
            if section == 0 {
                return 1
            } else {
                return autosuggestedLocations.count
            }
        } else {
            return autosuggestedKeywords.count
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (activeTextField == controller.locationSearchField) {
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("autosuggestCell", forIndexPath: indexPath) as! SettingsCell
                cell.icon.image = UIImage(named: "gpsIcon")
                cell.label.text = "Current Location"
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("autosuggestCell", forIndexPath: indexPath) as! SettingsCell
                cell.icon.image = UIImage(named: "pinIcon")
                cell.label.text = autosuggestedLocations[indexPath.row]
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("autosuggestCell", forIndexPath: indexPath) as! SettingsCell
            cell.icon.image = UIImage(named: "danceIcon")
            cell.label.text = autosuggestedKeywords[indexPath.row]
            return cell
        }
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
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
        if (activeTextField == controller.locationSearchField) {
            if indexPath.section == 0 {
                controller.locationSearchField.text = "Finding location..." //TODO: look up location!!!
                currentGeooder = CurrentGeocode(completionHandler: geocodeCompletionHandler)
            } else {
                controller.locationSearchField.text = autosuggestedLocations[indexPath.row]
                textFieldShouldReturn(controller.locationSearchField)
            }
        } else {
            controller.keywordSearchField.text = autosuggestedKeywords[indexPath.row]
            textFieldShouldReturn(controller.keywordSearchField)
        }
    }

    func geocodeCompletionHandler(optionalPlacemark: CLPlacemark?) {
        if let placemark = optionalPlacemark {
            let fullText = "\(placemark.locality!), \(placemark.administrativeArea!), \(placemark.country!)"
            self.controller.locationSearchField.text = fullText
            textFieldShouldReturn(controller.locationSearchField)
        } else {
            self.controller.locationSearchField.text = ""
            controller.locationFailureAlert.show()
        }
    }
}