//
//  MyCitiesViewController.swift
//  DanceDeets
//
//  Created by David Xiang on 11/27/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import UIKit

class MyCitiesViewController: UIViewController {

    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var addCityButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: Action
    @IBAction func doneButtonTapped(sender: AnyObject) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            println("dismiss view controller")
        })
    }
    
    @IBAction func addCityButtonTapped(sender: AnyObject) {
    }
    
    // MARK: UIViewController
    override func viewDidLoad(){
        super.viewDidLoad()
        
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font = FontFactory.navigationTitleFont()
        
        doneButton.titleLabel?.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        doneButton.titleLabel?.font = FontFactory.barButtonFont()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}
