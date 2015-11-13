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

    // MARK: UICollectionViewDataSource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return events.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("eventCollectionViewCell", forIndexPath: indexPath) as! EventDetailCell
        cell.event = events[indexPath.row]
        cell.viewDidLoad()
        return cell
    }

    func currentEventCell() -> EventDetailCell? {
        if let cells = collectionView?.visibleCells() {
            if let cell = cells[0] as? EventDetailCell {
                return cell
            }
        }
        return nil
    }

    // MARK: UIViewController
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "fullScreenImageSegue") {
            if let cell = currentEventCell() {
                let destinationController = segue.destinationViewController as! FullScreenImageViewController
                if let image = cell.eventCoverImageView.image {
                    destinationController.image = image
                }
                destinationController.event = cell.event
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Use the toolbars from the toolbar we set up in Interface Builder
        self.toolbarItems = bottomToolbarItems.items
        navigationController?.toolbar.barTintColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.8)

        // collection view
        let flowLayout:UICollectionViewFlowLayout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.sectionInset = UIEdgeInsetsZero
        flowLayout.itemSize = CGSizeMake(view.frame.size.width,view.frame.size.height)
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        //automaticallyAdjustsScrollViewInsets = false
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

    @IBAction func facebookTapped(sender: AnyObject) {
        currentEventCell()?.facebookTapped(sender)
    }
    @IBAction func mapTapped(sender: AnyObject) {
        currentEventCell()?.mapTapped(sender)
    }
    @IBAction func calendarTapped(sender: AnyObject) {
        currentEventCell()?.calendarTapped(sender)
    }
    @IBAction func rsvpTapped(sender: AnyObject) {
        currentEventCell()?.rsvpTapped(sender)
    }
    @IBAction func shareButtonTapped(sender: AnyObject) {
        currentEventCell()?.shareButtonTapped(sender)
    }

}
