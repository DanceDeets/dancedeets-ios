//
//  DanceDeetsTests.swift
//  DanceDeetsTests
//
//  Created by David Xiang on 9/20/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import UIKit
import XCTest
import DanceDeets

class DanceDeetsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testEventRetrieval(){
        let expectation = expectationWithDescription("Event Retrieval Test")
        Event.loadEventsForCity("New York City",  keyword:nil,  completion: {(events:[Event]!, error) in
            expectation.fulfill()
            XCTAssert(events.count > 0)
        })
        waitForExpectationsWithTimeout(10, handler:{ error in
        })
    }
    
    func testEventDetailRetrival(){
        let expectation = expectationWithDescription("Event Detail Test")
        Event.loadEventsForCity("New York City", keyword:nil, completion: {(events:[Event]!, error) in
            XCTAssert(events.count > 0)
            XCTAssert(error == nil)
            expectation.fulfill()
        })
        waitForExpectationsWithTimeout(10, handler:{ error in
        })
    }
    
    func testEventCoverImageDownload(){
        let expectation = expectationWithDescription("Event Detail Test")
        Event.loadEventsForCity("New York City", keyword:nil,  completion: {(events:[Event]!, error) in
            XCTAssert(events.count > 0)
            XCTAssert(error == nil)
            
            let firstEvent:Event? = events.first
            firstEvent?.downloadCoverImage({ (image:UIImage!, error:NSError!) -> Void in
                XCTAssert(error == nil)
                XCTAssert(image != nil)
                expectation.fulfill()
            })
        })
        waitForExpectationsWithTimeout(10, handler:{ error in
        })
    }
    
    func testSimpleAsync(){
        let URL = "http://google.com.com/"
        let expectation = expectationWithDescription("GET \(URL)")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(NSURL(string: URL)!, completionHandler: {(data, response, error) in
            expectation.fulfill()
            
            XCTAssertNotNil(data)
            XCTAssertNil(error)
            
            if let HTTPResponse = response as! NSHTTPURLResponse! {
                XCTAssertEqual(HTTPResponse.statusCode, 200, "HTTP response status code should be 200")
            } else {
                XCTFail("Response was not NSHTTPURLResponse")
            }
        })
        task.resume()
        waitForExpectationsWithTimeout(task.originalRequest!.timeoutInterval, handler:{ error in
            task.cancel()
        })
    }
    

    func testGooglePlaceAutoSuggest(){
        let expectation = expectationWithDescription("GOOGLE PLACE API GET")
        GooglePlaceAPI.autoSuggestCity("N", completion: { (autosuggests:[String]!, error:NSError!) -> Void in
            expectation.fulfill()
            XCTAssertNotNil(autosuggests)
            XCTAssertNil(error)
            XCTAssert(autosuggests.count > 0)
        })
        waitForExpectationsWithTimeout(10, handler:{ error in
        })
    }
    
}
