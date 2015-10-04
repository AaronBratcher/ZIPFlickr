//
//  PhotoSource+CoreDataProperties.swift
//  ZIPFlickr
//
//  Created by Aaron Bratcher on 10/3/15.
//  Copyright © 2015 Aaron Bratcher. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension PhotoSource {

    @NSManaged var id: String?
    @NSManaged var owner: String?
    @NSManaged var secret: String?
    @NSManaged var server: String?
    @NSManaged var farm: Int32
    @NSManaged var title: String?
    @NSManaged var isfavorite: Bool
    @NSManaged var smallImage: NSData?
	@NSManaged var page: Int32

}
