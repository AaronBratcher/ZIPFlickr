//
//  FullSizeController.swift
//  ZIPFlickr
//
//  Created by Aaron Bratcher on 10/4/15.
//  Copyright © 2015 Aaron Bratcher. All rights reserved.
//

import Foundation
import UIKit

class FullSizeController : UIViewController {
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	var flickrService:FlickrService?
	var photoSource:PhotoSource?
	
	override func viewDidLoad() {
		activityIndicator.hidden = false
		activityIndicator.startAnimating()
		flickrService?.getImageForSource(photoSource!, large: true, completed: { (image) -> () in
			if let imageView = self.imageView {
				dispatch_async(dispatch_get_main_queue(), { () -> Void in
					self.activityIndicator.stopAnimating()
					self.activityIndicator.hidden = true
					imageView.image = image
				})
			}
		})
	}

	
	@IBAction func doneTapped(sender: AnyObject) {
		dismissViewControllerAnimated(true, completion: nil)
	}
}