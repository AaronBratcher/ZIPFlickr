//
//  FlickrPhotoCell.swift
//  ZIPFlickr
//
//  Created by Aaron Bratcher on 10/3/15.
//  Copyright © 2015 Aaron Bratcher. All rights reserved.
//

import Foundation
import UIKit

protocol PhotoDelegate {
	func setFavorite(source:PhotoSource, isFavorite:Bool, sourceRect:CGRect, sourceView:UIView)
}

class FlickrPhotoCell:UICollectionViewCell {
	
	@IBOutlet weak var imageView: UIImageView?
	@IBOutlet weak var favorite: UIButton!
	
	var photoDelegate:PhotoDelegate? {
		didSet {
			if let _ = photoSource, _ = flickrService, _ = photoDelegate {
				loadImages()
			}
		}
	}
	
	var flickrService:FlickrService? {
		didSet {
			if let _ = photoSource, _ = flickrService, _ = photoDelegate {
				loadImages()
			}
		}
	}

	var photoSource:PhotoSource? {
		didSet {
			if let _ = photoSource, _ = flickrService, _ = photoDelegate {
				loadImages()
			}
		}
	}
	
	private func loadImages() {
		flickrService?.getImageForSource(photoSource!, large: false, completed: { (image) -> () in
			if let imageView = self.imageView {
				dispatch_async(dispatch_get_main_queue(), { () -> Void in
					imageView.image = image
				})
				self.setFavoriteImage()
			}
		})
	}
	
	private func setFavoriteImage() {
		dispatch_async(dispatch_get_main_queue()) { () -> Void in
			favorite.imageView?.image = UIImage.imageAsset(photoSource!.isfavorite ? ImageAsset.FilledHeart : ImageAsset.EmptyHeart)
		}
	}
	
	@IBAction func toggleFavorite(sender: AnyObject) {
		if let delegate = photoDelegate {
			delegate.setFavorite(photoSource!, isFavorite: !photoSource!.isfavorite, sourceRect: favorite.frame, sourceView: self)
			setFavoriteImage()
		}
	}
}