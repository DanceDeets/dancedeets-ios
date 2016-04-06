//
//  DetailControllerEventList.swift
//  DanceDeets
//
//  Created by LambertMike on 2015/09/26.
//  Copyright © 2015年 david.xiang. All rights reserved.
//

import Foundation

class EventDisplay: NSObject, UITableViewDataSource, UITableViewDelegate {
    // Initialized from Parent
    weak var tableView: UITableView!
    
    typealias EventSelectedHandler = (Event, withImage: UIImage?) -> Void
    typealias OneboxSelectedHandler = (OneboxLink) -> Void
    var oneboxSelectedHandler: OneboxSelectedHandler
    var eventSelectedHandler: EventSelectedHandler

    var results:SearchResults?
    var eventsBySection:[String:[Event]] = [:]
    var sectionNames:[String] = []

    let oneboxTitle = "Special Links"
    
    init(tableView: UITableView, heightOffset: CGFloat, andEventHandler eventHandler: EventSelectedHandler, andOneboxHandler oneboxHandler: OneboxSelectedHandler) {
        self.tableView = tableView
        self.eventSelectedHandler = eventHandler
        self.oneboxSelectedHandler = oneboxHandler

        super.init()

        // event list view styling
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.separatorInset = UIEdgeInsetsMake(0, 12, 0, 12)
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
        tableView.backgroundColor = UIColor.clearColor()
        tableView.contentInset = UIEdgeInsetsMake(heightOffset, 0, 0, 0)
        tableView.delegate = self
        tableView.dataSource = self
    }

    func setup(results: SearchResults?, error: NSError?) {
        // reset event models
        eventsBySection.removeAll()
        sectionNames.removeAll()

        // data source for collection view
        self.results = results

        if results?.oneboxLinks.count > 0 {
            sectionNames.append(oneboxTitle)
            eventsBySection[oneboxTitle] = []
        }

        // check response
        if results?.events.count > 0 {
            // data source for list view -> group events into sections by month (or day?)
            for event in results!.events {
                if event.startTime != nil {
                    // month from event's start time as a string
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "EEE MMM dd"
                    let sectionName = dateFormatter.stringFromDate(event.startTime!)
                    // each section has an array of events
                    if eventsBySection.indexForKey(sectionName) == nil {
                        eventsBySection[sectionName] = []
                    }
                    eventsBySection[sectionName]!.append(event)

                    // keep track of active sections for section headers
                    if sectionNames.indexOf(sectionName) == nil {
                        sectionNames.append(sectionName)
                    }
                }
            }
            // Scroll to top
            tableView.reloadData()
            if (tableView.numberOfSections > 0 && tableView.numberOfRowsInSection(0) > 0) {
                let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
            }
        }

        tableView.reloadData()
    }
    
    // MARK: UITableViewDataSource / UITableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionNames.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionName = sectionNames[section]
        if sectionName == oneboxTitle {
            return results?.oneboxLinks.count ?? 0
        } else {
            let events = eventsBySection[sectionName]
            return events?.count ?? 0
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // headers are the mo/yr for a section of events
        let headerView = UIView(frame: CGRectZero)
        headerView.backgroundColor = UIColor.clearColor()
        headerView.addDarkBlurOverlay()
        let headerLabel = UILabel(frame: CGRectZero)
        let sectionName = sectionNames[section]
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(headerLabel)
        headerLabel.constrainLeftToSuperView(13)
        headerLabel.verticallyCenterToSuperView(0)
        headerLabel.font = UIFont(name:"Interstate-BoldCondensed",size:15)!
        headerLabel.textColor = UIColor.whiteColor()
        headerLabel.text = sectionName
        return headerView
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let sectionName = sectionNames[indexPath.section]
        if sectionName == oneboxTitle {
            let cell = tableView.dequeueReusableCellWithIdentifier("oneboxListTableViewCell", forIndexPath: indexPath) as! OneboxListItemTableViewCell
            cell.updateForOneboxLink(results!.oneboxLinks[indexPath.row])
            return cell
        }

        let sectionEvents = eventsBySection[sectionName]!

        let cell = tableView.dequeueReusableCellWithIdentifier("eventListTableViewCell", forIndexPath: indexPath) as! EventListItemTableViewCell
        if cell.currentEvent?.downloadTask != nil {
            cell.currentEvent?.downloadTask?.cancel()
        }
        let event:Event = sectionEvents[indexPath.row]
        cell.updateForEvent(event)
        
        if let imageUrl = event.eventSmallImageUrl {
            let imageRequest:NSURLRequest = NSURLRequest(URL: imageUrl)
            if let image = ImageCache.sharedInstance.cachedImageForRequest(imageRequest) {
                cell.eventImageView?.image = image
            } else {
                cell.eventImageView?.image = nil
                event.downloadCoverImage({ (image: UIImage!, error: NSError!) -> Void in
                    // guard against cell reuse + async download
                    if (event == cell.currentEvent) {
                        if (image != nil) {
                            cell.eventImageView?.image = image
                        }
                    }
                })
            }
        } else {
            cell.eventImageView?.image = nil
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let sectionName = sectionNames[indexPath.section]
        if sectionName == oneboxTitle {
            if let oneboxLink = results?.oneboxLinks[indexPath.row] {
                oneboxSelectedHandler(oneboxLink)
            }
        } else {
            if let sectionEvents = eventsBySection[sectionName] {
                if (sectionEvents.count > indexPath.row) {
                    let event = sectionEvents[indexPath.row]
                    let eventCell = tableView.cellForRowAtIndexPath(indexPath) as! EventListItemTableViewCell
                    eventSelectedHandler(event, withImage: eventCell.eventImageView.image)
                }
            }
        }
    }
}