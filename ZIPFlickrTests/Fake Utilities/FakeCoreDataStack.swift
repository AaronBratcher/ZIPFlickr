//
//  FakeCoreDataStack.swift
//  ZIPFlickr
//
//  Created by Aaron Bratcher on 10/3/15.
//  Copyright © 2015 Aaron Bratcher. All rights reserved.
//

import Foundation
import CoreData

class FakeCoreDataStack:CoreDataStack {
	override init() {
		super.init()
		let coordinator:NSPersistentStoreCoordinator = {
			let psc = NSPersistentStoreCoordinator( managedObjectModel: self.managedObjectModel)
			do {
			try psc.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil) }
			catch {
			fatalError()
			}
			
			return psc
			}()

		self.persistentStoreCoordinator = coordinator
	}
}