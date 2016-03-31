//
//  SplashViewController.swift
//  
//
//  Created by LambertMike on 2016/03/31.
//
//

import Foundation

class SplashViewController : UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        self.becomeFirstResponder()
    }
}