//
//  UrlUtil.swift
//  DanceDeets
//
//  Created by LambertMike on 2015/09/27.
//  Copyright © 2015年 david.xiang. All rights reserved.
//

import Foundation

class UrlUtil {
    // MARK: Static URL Construction Methods
    static let urlArgCharacterSet = UrlUtil.getUrlArgCharacterSet()

    class func getUrlArgCharacterSet() -> NSCharacterSet {
        let characterSet:NSMutableCharacterSet = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy() as! NSMutableCharacterSet
        characterSet.addCharactersInString("&=")
        let realCharacterSet:NSCharacterSet = characterSet.copy() as! NSCharacterSet
        return realCharacterSet
    }

    class func getUrl(baseUrl: String, withArgs args: [String: String]=[:]) -> NSURL {
        // Parameters passed on every request
        let stringArgs = args.map(
            {(key: String, value: String) -> String in
                return key.stringByAddingPercentEncodingWithAllowedCharacters(UrlUtil.urlArgCharacterSet)!
                    + "="
                    + value.stringByAddingPercentEncodingWithAllowedCharacters(UrlUtil.urlArgCharacterSet)!
            }
        )
        let url = baseUrl + "?" + stringArgs.joinWithSeparator("&")
        return NSURL(string: url)!
    }
}