//
//  AppDelegate.swift
//  ZIPFlickr
//
//  Created by Aaron Bratcher on 10/1/15.
//  Copyright © 2015 Aaron Bratcher. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	var coreDataStack = CoreDataStack()

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		// Override point for customization after application launch.
		return true
	}

	func applicationDidEnterBackground(application: UIApplication) {
		coreDataStack.saveContext()
	}
	
	func applicationWillTerminate(application: UIApplication) {
		coreDataStack.saveContext()
	}


}

