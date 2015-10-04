//
//  ImageEnumeration.swift
//  ZIPFlickr
//
//  Created by Aaron Bratcher on 10/4/15.
//  Copyright © 2015 Aaron Bratcher. All rights reserved.
//

import Foundation
import UIKit

enum ImageAsset:String {
	case EmptyHeart = "emptyHeart"
	case FilledHeart = "filledHeart"
	case Error = "error"
}

extension UIImage {
	class func imageAsset(asset:ImageAsset) -> UIImage {
		return UIImage(named: asset.rawValue)!
	}
}