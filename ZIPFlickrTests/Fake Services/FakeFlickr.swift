//
//  FakeFlickr.swift
//  ZIPFlickr
//
//  Created by Aaron Bratcher on 10/2/15.
//  Copyright © 2015 Aaron Bratcher. All rights reserved.
//

import Foundation
import CoreData

class FakeFlickr:Flickr {
	
	var goodData = true

	override func getImageList(lat: Double, lon: Double, radius: Int, completed: ListReceived) {
		if goodData {
			storeData(loadGoodData())
		}

		completed(successful: true)
	}

	func loadGoodData() -> [[String:AnyObject]]! {
		let bundle = NSBundle(forClass: self.dynamicType)
		let path = bundle.pathForResource("Valid1", ofType: "txt")!
		let dataValue = NSData(contentsOfFile: path)
		
		guard let dict = try? NSJSONSerialization.JSONObjectWithData(dataValue!, options: NSJSONReadingOptions.MutableContainers) as! [String:AnyObject] else {
			return nil
		}
		
		let photos = dict["photos"] as! [String:AnyObject]
		let photoArray = photos["photo"]! as! [[String:AnyObject]]
		
		return photoArray
	}
}