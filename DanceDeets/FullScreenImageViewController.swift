//
//  FullScreenImageViewController.swift
//  DanceDeets
//
//  Created by David Xiang on 12/23/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import Foundation


class FullScreenImageViewController : UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    var event:Event?
    var image:UIImage?
    var tapGesture:UITapGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        imageView.image = image
        if event != nil {
            AnalyticsUtil.track("View Flyer", withEvent: event!)
        }

        let heightPadding = max(0, (view.frame.height - image!.size.height)/2)
        let widthPadding = max(0, (view.frame.width - image!.size.width)/2)
        scrollView.contentInset = UIEdgeInsets(top: heightPadding, left: widthPadding, bottom: heightPadding, right: widthPadding)

        let scale = min(view.frame.width / imageView.frame.width, view.frame.height / imageView.frame.height)
        scrollView.minimumZoomScale = scale
        scrollView.zoomScale = scale

        tapGesture = UITapGestureRecognizer(target: self, action: "tapped")
        scrollView.addGestureRecognizer(tapGesture!)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func tapped() {
        AppDelegate.sharedInstance().allowLandscape = false
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

