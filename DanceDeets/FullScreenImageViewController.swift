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

        // The black offset around the image, so that scrolling/zooming is more obvious
        let outerOffset = CGFloat(30)

        // This centers the image in the scrollview (and the offset addition gives some extra black borders)
        let heightPadding = max(0, (view.frame.height - image!.size.height)/2) + outerOffset
        let widthPadding = max(0, (view.frame.width - image!.size.width)/2) + outerOffset
        scrollView.contentInset = UIEdgeInsets(top: heightPadding, left: widthPadding, bottom: heightPadding, right: widthPadding)

        // This sets the default zoom (and max-zoomed-out zoom) to be the image fullscreen in the display
        let scale = min(view.frame.width / imageView.frame.width, view.frame.height / imageView.frame.height)
        scrollView.minimumZoomScale = scale
        scrollView.zoomScale = scale

        // This undoes the offset black borders, so that they initially appear offscreen (but allow zooming)
        // Note, I believe contentOffset and zoomScale interact, so it needs to be done *after* we set the zoomScale above,
        // or things don't work properly.
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)

        tapGesture = UITapGestureRecognizer(target: self, action: #selector(FullScreenImageViewController.tapped))
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

