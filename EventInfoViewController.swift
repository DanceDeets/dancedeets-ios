//
//  EventInfoViewController.swift
//  DanceDeets
//
//  Created by David Xiang on 10/28/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import UIKit
import QuartzCore
import MapKit

class EventInfoViewController: UICollectionViewController, UIGestureRecognizerDelegate {

    var events:[Event]!

    @IBOutlet var bottomToolbarItems: UIToolbar!


    // MARK: UICollectionViewDelegate
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let event = events[indexPath.row]
        collectionView.userInteractionEnabled = false
    }

    // MARK: UICollectionViewDataSource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return events.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("eventCollectionViewCell", forIndexPath: indexPath) as! EventDetailCell
        cell.event = events[indexPath.row]
        cell.viewDidLoad()
        return cell
    }

    // MARK: UIViewController
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "fullScreenImageSegue") {

            let destinationController = segue.destinationViewController as! FullScreenImageViewController
            /*
            if let image = eventCoverImageView.image {
                destinationController.image = image
            }
            destinationController.event = event
            */
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Use the toolbars from the toolbar we set up in Interface Builder
 //       self.toolbarItems = bottomToolbarItems.items
        navigationController?.toolbar.barTintColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.8)


        // collection view
        let flowLayout:UICollectionViewFlowLayout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.sectionInset = UIEdgeInsetsZero
        flowLayout.itemSize = CGSizeMake(view.frame.size.width,view.frame.size.height)
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
    }


    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.setToolbarHidden(false, animated: false)

    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.setToolbarHidden(true, animated: false)
    }
}
