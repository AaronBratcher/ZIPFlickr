//
//  FlickrProtocol.swift
//  ZIPFlickr
//
//  Created by Aaron Bratcher on 10/2/15.
//  Copyright © 2015 Aaron Bratcher. All rights reserved.
//

import Foundation
import UIKit

typealias ListReceived = (successful:Bool)->()
typealias ImageReceived = (UIImage?)->()

protocol FlickrService {
	func getImageListAtLat(lat:Double, lon:Double, radius:Int, completed:ListReceived)
	
	func imageCount(favoriteOnly:Bool) -> Int
	
	func sourceAtIndex(index:Int) -> PhotoSource
	
	func indexForSource(source:PhotoSource) -> Int?

	func getImageForSource(source:PhotoSource, large:Bool, completed:ImageReceived)
	
	func setFavorite(source:PhotoSource, isFavorite:Bool)
	
	func deleteAll()
	
	func deleteNonFavorites()
}