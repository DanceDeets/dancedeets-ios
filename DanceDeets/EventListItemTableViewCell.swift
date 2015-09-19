//
//  EventListItemTableViewCell.swift
//  DanceDeets
//
//  Created by David Xiang on 4/5/15.
//  Copyright (c) 2015 david.xiang. All rights reserved.
//

import UIKit

class EventListItemTableViewCell: UITableViewCell {
    
    let SEPARATOR_HORIZONTAL_INSETS:CGFloat = 12.0
    var eventImageView:UIImageView!
    var eventTitleLabel:UILabel!
    var currentEvent:Event?
    var clockIconImageView:UIImageView!
    var pinIconImageView:UIImageView!
    var eventTimeLabel:UILabel!
    var eventVenueLabel:UILabel!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func updateForEvent(event:Event){
        currentEvent = event
        eventTitleLabel.text = event.title
        eventTimeLabel.text = event.displayTime
        if let venueDisplay = event.venue{
            if(event.attendingCount != nil){
                eventVenueLabel.text = venueDisplay + "  |  \(event.attendingCount!) attending"
            }else{
                eventVenueLabel.text = venueDisplay
            }
        }
        contentView.layoutIfNeeded()
    }
    
    func commonInit(){
        // init
        backgroundColor = UIColor.clearColor()
        layoutMargins = UIEdgeInsetsZero
        separatorInset = UIEdgeInsetsMake(0, SEPARATOR_HORIZONTAL_INSETS, 0, SEPARATOR_HORIZONTAL_INSETS)
        userInteractionEnabled = true
        selectionStyle = .None
        
        // all layout for this cell in code.
        
        // cover image
        eventImageView = UIImageView(frame: CGRectZero)
        eventImageView.backgroundColor = UIColor.blackColor()
        eventImageView.clipsToBounds = true
        eventImageView.contentMode = .ScaleAspectFill
        contentView.addSubview(eventImageView)
        let heightConstraint = NSLayoutConstraint(item: eventImageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: 112)
        heightConstraint.priority = 999
        let widthConstraint = NSLayoutConstraint(item: eventImageView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: 112)
        widthConstraint.priority = 999
        eventImageView.addConstraint(heightConstraint)
        eventImageView.addConstraint(widthConstraint)
        
        eventImageView.constrainLeftToSuperView(12)
        eventImageView.constrainTopToSuperView(15)
        eventImageView.constrainBottomToSuperView(15)
        
        // title label
        eventTitleLabel = UILabel(frame:CGRectZero)
        eventTitleLabel.numberOfLines = 2
        eventTitleLabel.textColor = UIColor.whiteColor()
        eventTitleLabel.font = UIFont(name:"Interstate-ExtraLight",size:18)!
        
        contentView.addSubview(eventTitleLabel)
        eventTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(item: eventTitleLabel, attribute: .Left, relatedBy: .Equal, toItem: eventImageView, attribute: .Right, multiplier: 1.0, constant: 10))
        contentView.addConstraint(NSLayoutConstraint(item: eventTitleLabel, attribute: .Right, relatedBy: .Equal, toItem: contentView, attribute: .Right, multiplier: 1.0, constant: -12))
        contentView.addConstraint(NSLayoutConstraint(item: eventTitleLabel, attribute: .Top, relatedBy: .Equal, toItem: eventImageView, attribute: .Top, multiplier: 1.0, constant: 5))
        
        // clock
        clockIconImageView = UIImageView(image: UIImage(named: "clockIcon"))
        clockIconImageView.tintColor = ColorFactory.lightBlue()
        contentView.addSubview(clockIconImageView)
        clockIconImageView.constrainWidth(14, height: 14)
        clockIconImageView.alignLeftToView(eventTitleLabel)
        contentView.addConstraint(NSLayoutConstraint(item: clockIconImageView, attribute: .Top, relatedBy: .Equal, toItem: eventTitleLabel, attribute: .Bottom, multiplier: 1.0, constant: 10))
        
        // pin
        pinIconImageView = UIImageView(image: UIImage(named: "pinIcon"))
        pinIconImageView.tintColor = UIColor.whiteColor()
        contentView.addSubview(pinIconImageView)
        pinIconImageView.constrainWidth(10, height: 12)
        pinIconImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(item: pinIconImageView, attribute: .CenterX, relatedBy: .Equal, toItem: clockIconImageView, attribute: .CenterX, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: pinIconImageView, attribute: .Top, relatedBy: .Equal, toItem: clockIconImageView, attribute: .Bottom, multiplier: 1.0, constant: 8))
        
        // time label
        eventTimeLabel = UILabel(frame: CGRectZero)
        eventTimeLabel.font = FontFactory.eventDateFont()
        eventTimeLabel.textColor =  ColorFactory.lightBlue()
        contentView.addSubview(eventTimeLabel)
        eventTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(item: eventTimeLabel, attribute: .CenterY, relatedBy: .Equal, toItem: clockIconImageView, attribute: .CenterY, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: eventTimeLabel, attribute: .Left, relatedBy: .Equal, toItem: clockIconImageView, attribute: .Right, multiplier: 1.0, constant: 9))
        contentView.addConstraint(NSLayoutConstraint(item: eventTimeLabel, attribute: .Right, relatedBy: .Equal, toItem: contentView, attribute: .Right, multiplier: 1.0, constant: -12))
        
        // venue label
        eventVenueLabel = UILabel(frame: CGRectZero)
        eventVenueLabel.font = FontFactory.eventVenueFont()
        eventVenueLabel.textColor =  UIColor.whiteColor()
        eventVenueLabel.numberOfLines = 2
        contentView.addSubview(eventVenueLabel)
        eventVenueLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(item: eventVenueLabel, attribute: .Top, relatedBy: .Equal, toItem: pinIconImageView, attribute: .Top, multiplier: 1.0, constant: -2))
        contentView.addConstraint(NSLayoutConstraint(item: eventVenueLabel, attribute: .Left, relatedBy: .Equal, toItem: pinIconImageView, attribute: .Right, multiplier: 1.0, constant: 11))
        contentView.addConstraint(NSLayoutConstraint(item: eventVenueLabel, attribute: .Right, relatedBy: .Equal, toItem: contentView, attribute: .Right, multiplier: 1.0, constant: -12))
        
    }
}
