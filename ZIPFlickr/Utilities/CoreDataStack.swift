//
//  CoreDataStack.swift
//  Dog Walk
//
//  Created by Aaron Bratcher on 10/3/15.
//  Copyright © 2015 Razeware. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
	let modelName = "ZIPFlickr"
	
	private lazy var applicationDocumentsDirectory: NSURL = {
		let urls = NSFileManager.defaultManager().URLsForDirectory(
			.DocumentDirectory, inDomains: .UserDomainMask)
		return urls[urls.count-1]
		}()
	
	lazy var context: NSManagedObjectContext = {
		var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
		managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
		return managedObjectContext
		}()
	
	lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
		let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
		let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("\(self.modelName).sqlite")
		do {
			let options = [NSMigratePersistentStoresAutomaticallyOption : true]
			try coordinator.addPersistentStoreWithType( NSSQLiteStoreType, configuration: nil, URL: url, options: options)
		} catch {
			print("Error adding persistent store.")
		}
		return coordinator
		}()
	
	lazy var managedObjectModel: NSManagedObjectModel = {
	let modelURL = NSBundle.mainBundle().URLForResource(self.modelName, withExtension: "momd")!
		return NSManagedObjectModel(contentsOfURL: modelURL)!
		}()
		
	func saveContext () {
		if context.hasChanges {
			do {
				try context.save()
			} catch let error as NSError {
				print("Error: \(error.localizedDescription)")
				abort()
			}
		}
	}
}