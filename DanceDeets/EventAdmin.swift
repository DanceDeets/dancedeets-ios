//
//  EventAdmin.swift
//  DanceDeets
//
//  Created by David Xiang on 11/1/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import Foundation

public class EventAdmin{
    var identifier:String
    var name:String
    
    init(name:String, identifier:String){
        self.identifier = identifier
        self.name = name
    }
}