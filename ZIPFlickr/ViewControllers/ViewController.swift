//
//  ViewController.swift
//  ZIPFlickr
//
//  Created by Aaron Bratcher on 10/1/15.
//  Copyright © 2015 Aaron Bratcher. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	enum Segues:String {
		case ShowFullsize = "ShowFullsize"
	}
	
	@IBOutlet weak var segments: UISegmentedControl!
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var distance: UISlider!
	@IBOutlet weak var refresh: UIButton!
	@IBOutlet weak var progressWheel: UIActivityIndicatorView!
	
	lazy var coreDataStack = CoreDataStack()
	lazy var flickrService:FlickrService = Flickr(context: self.coreDataStack.context)
	
	override func prefersStatusBarHidden() -> Bool {
		return true;
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		loadImages()
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier != nil, let segueName = Segues(rawValue: segue.identifier!) {
			switch segueName {
			case .ShowFullsize:
				let navController = segue.destinationViewController as! UINavigationController
				let controller = navController.viewControllers[0] as! FullSizeController
				controller.flickrService = flickrService
				let indexPath = sender as! NSIndexPath
				controller.photoSource = flickrService.sourceAtIndex(indexPath.row)
			}
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	private func favoritesOnly() -> Bool {
		return segments.selectedSegmentIndex == 1
	}
	
	private func loadImages() {
		refresh.hidden = true
		progressWheel.hidden = false
		progressWheel.startAnimating()
		
		flickrService.deleteNonFavorites()
		
		CurrentLocation.currentLocation { (location) -> Void in
			if location == nil {
				print("Unable to determine location")
				// TODO: Show Alert
				return
			}
			
			self.flickrService.getImageListAtLat(location.lat, lon: location.lon, radius: Int(self.distance.value)) { (successful) -> () in
				dispatch_async(dispatch_get_main_queue(), { () -> Void in
					self.progressWheel.stopAnimating()
					self.progressWheel.hidden = true
					self.refresh.hidden = false
					
					self.collectionView.reloadData()
				})
			}
		}
	}
	
	@IBAction func segmentChanged(sender: AnyObject) {
		collectionView.reloadData()
	}

	@IBAction func refreshTapped(sender: AnyObject) {
		loadImages()
	}
	
	@IBAction func distanceChanged(sender: AnyObject) {
		loadImages()
	}
}

// MARK: - Collection View Data Source
private let reuseIdentifier = "FlickrCell"
extension ViewController : UICollectionViewDataSource {
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return flickrService.imageCount(favoritesOnly())
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FlickrPhotoCell
		cell.backgroundColor = UIColor.whiteColor()
		cell.photoDelegate = self
		cell.flickrService = flickrService
		cell.photoSource = flickrService.sourceAtIndex(indexPath.row)
		
		return cell
	}
}

// MARK: - Collection View Delegate
extension ViewController : UICollectionViewDelegate {
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		performSegueWithIdentifier(Segues.ShowFullsize.rawValue, sender: indexPath)
	}
}

// MARK: - Photo Delegate
extension ViewController : PhotoDelegate {
	func setFavorite(source:PhotoSource, isFavorite:Bool, sourceRect:CGRect, sourceView:UIView) {
		flickrService.setFavorite(source, isFavorite: isFavorite)
		if isFavorite {
			animateFavorite(sourceRect: sourceRect, sourceView: sourceView)
		} else {
			removeFavorite(source)
		}
	}
	
	func animateFavorite(sourceRect sourceRect:CGRect, sourceView:UIView) {
		// translate frame of original heart
		let imageRect = sourceView.convertRect(sourceRect, toView: self.view)
		
		// place image
		let imageView = UIImageView(image: UIImage.imageAsset(.FilledHeart))
		imageView.frame = imageRect
		self.view.addSubview(imageView)
		
		// amimate
		
		// get center of segment
		var segmentRect = segments.frame
		segmentRect.origin.x = segmentRect.origin.x + (segmentRect.size.width / 2)
		segmentRect.size.width = (segmentRect.size.width / 2)
		
		let x = segmentRect.origin.x + (segmentRect.size.width / 2) - imageRect.width / 2
		let y = segmentRect.origin.y + (segmentRect.size.height / 2) - imageRect.height / 2
		
		// create rect around that center
		let destRect = CGRect(x: x, y: y, width: imageRect.width, height: imageRect.height)
		
		UIView.animateWithDuration(0.5, animations: { () -> Void in
			imageView.frame = destRect
			imageView.alpha = 0.1
			}) { (_) -> Void in
			imageView.removeFromSuperview()
		}
	}
	
	func removeFavorite(source:PhotoSource) {
		guard favoritesOnly(), let index = flickrService.indexForSource(source) else { return }
		
		flickrService.imageCount(true)
		let indexPath = NSIndexPath(forRow: index, inSection: 0)
		collectionView.deleteItemsAtIndexPaths([indexPath])
	}
}

// MARK: - FlowLayout Delegate
extension ViewController : UICollectionViewDelegateFlowLayout {
	//1
	func collectionView(collectionView: UICollectionView,
		layout collectionViewLayout: UICollectionViewLayout,
		sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
			return CGSize(width: 200, height: 200)
	}
 }