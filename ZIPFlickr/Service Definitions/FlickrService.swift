//
//  FlickrProtocol.swift
//  ZIPFlickr
//
//  Created by Aaron Bratcher on 10/2/15.
//  Copyright © 2015 Aaron Bratcher. All rights reserved.
//

import Foundation
import UIKit


protocol FlickrService {
	func getImageListAtLat(lat:Double, lon:Double, radius:Int, completed:ListReceived)
	
	func imageCount(favoriteOnly:Bool) -> Int

	func getImageAtIndex(index:Int, large:Bool, completed:ImageReceived)
	
	func setFavorite(source:PhotoSource, isFavorite:Bool)
	
	func deleteAll()
	
	func deleteNonFavorites()
}