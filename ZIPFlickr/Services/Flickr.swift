//
//  Flickr.swift
//  ZIPFlickr
//
//  Created by Aaron Bratcher on 10/2/15.
//  Copyright © 2015 Aaron Bratcher. All rights reserved.
//

import Foundation
import CoreData
import Alamofire
import AlamofireImage

class Flickr:FlickrService {
	
	private var managedContext:NSManagedObjectContext!
	private var queuedSources = [NSManagedObject]()
	
	init(context:NSManagedObjectContext) {
		self.managedContext = context
		// TODO: clear non-favorite from context
	}
		
	func getImageListAtLat(lat: Double, lon: Double, radius: Int, completed: ListReceived) {
		
		downloadSourceList(lat, lon: lon, radius: radius) { (results) -> () in
			guard let list = results else {
				completed(successful: false)
				return
			}
			
			self.storeData(list)
			completed(successful: true)
		}
	}
	
	func imageCount(favoriteOnly:Bool) -> Int {
		queuedSources = [NSManagedObject]()
		
		let fetchRequest = NSFetchRequest(entityName: PhotoSource.entityName)
		if favoriteOnly {
			fetchRequest.predicate = NSPredicate(format: "isfavorite==1", argumentArray: nil)
		}
		do {
			let results = try managedContext.executeFetchRequest(fetchRequest)
			queuedSources = results as! [NSManagedObject]
		} catch _ {
			// TODO: handle the error
		}
		
		return queuedSources.count
	}

	func sourceAtIndex(index:Int) -> PhotoSource {
		return queuedSources[index] as! PhotoSource
	}
	
	func indexForSource(source:PhotoSource) -> Int? {
		for index in 0..<queuedSources.count {
			let testSource = queuedSources[index] as! PhotoSource
			if source.id! == testSource.id! {
				return index
			}
		}
		
		return nil
	}
	
	func getImageForSource(source:PhotoSource, large: Bool, completed: ImageReceived) {
		if !large, let pngData = source.smallImage {
			completed(UIImage(data: pngData))
			return
		}
		
		let size = large ? "b" : "m"
		guard let server = source.server, id = source.id, secret = source.secret else {
			completed(nil)
			return
		}
		
		let url = "https://farm\(source.farm).staticflickr.com/\(server)/\(id)_\(secret)_\(size).jpg"
		
		print(url)
		
		Alamofire.request(.GET, url).responseImage { (response) -> Void in
			guard let image = response.result.value else {
				completed(nil)
				return
			}
			
			source.smallImage = UIImagePNGRepresentation(image)
			do {
				try self.managedContext.save()
			} catch _ {
				// TODO: handle the error
			}

			completed(image)
		}
	}
	
	
	func setFavorite(source:PhotoSource, isFavorite:Bool) {
		source.isfavorite = isFavorite
		do {
			try managedContext.save()
		} catch _ {
			// TODO: handle the error
		}
	}

	func deleteAll() {
		let fetchRequest = NSFetchRequest(entityName: PhotoSource.entityName)

		if #available(iOS 9, *) {
			let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
			
			do {
				try managedContext.persistentStoreCoordinator!.executeRequest(deleteRequest, withContext: managedContext)
				try managedContext.save()
			} catch _ {
				// TODO: handle the error
			}
		} else {
			var photos:[NSManagedObject] = []
			do {
				let results = try managedContext.executeFetchRequest(fetchRequest)
				photos = results as! [NSManagedObject]
				for photo in photos {
					managedContext.deleteObject(photo)
				}
				try managedContext.save()
			} catch _ {
				// TODO: handle the error
			}
		}
	}
	
	func deleteNonFavorites() {
		var photos = [NSManagedObject]()
		let fetchRequest = NSFetchRequest(entityName: PhotoSource.entityName)
		fetchRequest.predicate = NSPredicate(format: "isfavorite==0", argumentArray: nil)
		do {
			let results = try managedContext.executeFetchRequest(fetchRequest)
			photos = results as! [NSManagedObject]
			for photo in photos {
				managedContext.deleteObject(photo)
			}
			try managedContext.save()
		} catch _ {
			// TODO: handle the error
		}
	}
	
	// MARK: - Internal
	
	func storeData(data: [[String:AnyObject]]) {
		print("saving \(data.count) photo sources")
		for dict in data {
			guard let ispublic = dict["ispublic"] as? NSNumber, photoID = dict["id"] as? String where ispublic.boolValue else { continue }
			
			// verify it isn't already in the db. Favorites are kept in after refresh. Don't want to load them up again.
			var photos = [NSManagedObject]()
			let fetchRequest = NSFetchRequest(entityName: PhotoSource.entityName)
			fetchRequest.predicate = NSPredicate(format: "id==\(photoID)", argumentArray: nil)
			do {
				let results = try managedContext.executeFetchRequest(fetchRequest)
				photos = results as! [NSManagedObject]
			} catch _ {
				// TODO: handle the error
			}

			if photos.count == 0 {
				let entity = NSEntityDescription.entityForName(PhotoSource.entityName, inManagedObjectContext: managedContext)
				let photo = PhotoSource(entity: entity!, insertIntoManagedObjectContext: managedContext)
				photo.id = photoID
				photo.owner = (dict["owner"] as! String)
				photo.secret = (dict["secret"] as! String)
				photo.server = (dict["server"] as! String)
				let farm = dict["farm"]!
				photo.farm = Int32(farm.integerValue)
				photo.title = (dict["title"] as! String)
			}
		}
		
		do {
			try managedContext.save()
		} catch _ {
			print("error saving data")
		}
	}
}

private extension Flickr {
	typealias SourceDownloaded = ([[String:AnyObject]]?)->()

	func downloadSourceList(lat: Double, lon: Double, radius: Int, downloaded:SourceDownloaded) {
		let key = "4210e25d2a4367fc30587df08a13fe6c"
		
		let urlString = "https://api.flickr.com/services/rest/"
		let parameters:[String:AnyObject] = ["method":"flickr.photos.search", "api_key":key, "lat":lat, "lon":lon, "radius":radius, "radius_units":"mi", "format":"json", "nojsoncallback":1]

		Alamofire.request(.GET, urlString, parameters:parameters).responseJSON { (response) -> Void in
			guard let dataValue = response.data
				, dict = try? NSJSONSerialization.JSONObjectWithData(dataValue, options: NSJSONReadingOptions.MutableContainers) as! [String:AnyObject] else {
				downloaded(nil)
				return
			}
			
			let status = dict["stat"] as! String
			if status == "fail" {
				print("unable to retrieve photo sources.\n\nPerform search at http://www.flickr.com/services/api/explore/?method=flickr.photos.search\n\nCopy key into source.")
				return
			}
			
			let photos = dict["photos"] as! [String:AnyObject]
			let photoArray = photos["photo"]! as! [[String:AnyObject]]
			
			downloaded(photoArray)
		}
	}
}