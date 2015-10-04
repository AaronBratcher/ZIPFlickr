//
//  FlickrServiceTests.swift
//  ZIPFlickr
//
//  Created by Aaron Bratcher on 10/3/15.
//  Copyright © 2015 Aaron Bratcher. All rights reserved.
//

import Foundation
import CoreData
import XCTest

@testable import ZIPFlickr

class FlickrServiceTests: XCTestCase {
	lazy var coreDataStack = FakeCoreDataStack()
	lazy var flickrService:FlickrService = FakeFlickr(context: self.coreDataStack.context)
	
	override func setUp() {
		super.setUp()
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
	

	func testDataInserts() {
		let expectation = self.expectationWithDescription("Load Data")
		flickrService.getImageList(0, lon: 0, radius: 5) { (successful) -> () in
			expectation.fulfill()
		}
		
		waitForExpectationsWithTimeout(2) { (error) -> Void in
			let fetchRequest = NSFetchRequest(entityName: PhotoSource.entityName)
			var photos:[NSManagedObject] = []
			do {
				let results = try self.coreDataStack.context.executeFetchRequest(fetchRequest)
				photos = results as! [NSManagedObject]
			} catch _ {
			}
			
			XCTAssert(photos.count == 100, "Error loading photos")
		}
		
	}
	
	
}
