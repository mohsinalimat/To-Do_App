//
//  AppDelegate.swift
//  To-Do App
//
//  Created by Wismin Effendi on 6/12/17.
//  Copyright © 2017 iShinobi. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?

    lazy var coreDataStack = CoreDataStack(modelName: "To_Do_App")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Case of SplitView controller
        let splitViewController = window?.rootViewController as? UISplitViewController
        let navController = splitViewController?.viewControllers.first as? UINavigationController
        let taskTableViewController = navController?.topViewController as? TaskTableViewController
            
        splitViewController?.delegate = self
        
        taskTableViewController?.coreDataStack = coreDataStack
        
        if let detailNavController = splitViewController?.viewControllers.last as? UINavigationController,
            let taskViewController = detailNavController.topViewController as? TaskViewController {
            
            taskViewController.managedContext = coreDataStack.managedContext
        }
        
        return true
        
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        coreDataStack.saveContext()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        coreDataStack.saveContext()
    }


    // MARK: UISplitViewControllerDelegate 
    
    // always show MasterView first in Compact width
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        
        return true
    }
    

}

