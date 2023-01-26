//
//  AppDelegate.swift
//  Mooskine
//
//  Created by Josh Svatek on 2017-05-29.
//  Copyright © 2017 Udacity. All rights reserved.
//

// MARK: 10. The Existing Model
// 00:00 You should now have the Mooskine project up and running. This Versio of the app does not use core data yet, but it does have a data model. The model consists of two classes: Note and Notebook.

// 00:16 When you first open Mooskine, you see a list of notebooks. That view is in notebooks list view controller. So let's look in here ... move to "NotebooksListViewController.swift" ...

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // continuation from minute 03:54, moving from "DataController.swift" to here ...
    // 03:54 And at the top add a DataController property, and instantiate it right here, passing in the modelName "Mooskine", now move inside to func below i.e. applicationDidFinishlaunchingWithOptions
    let dataController = DataController(modelName: "Mooskine")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // 04:03 Then in applicationDidFinishlaunchingWithOptions we'll call dataController.load and again we can use the trailing closure syntax i.e. adding {}
        // 04:14 The completion block we provide here will get called once the persistent store is loaded. This gives us the space to display a loading interface while we wait for data to load and switch to the main UI only after the data has been loaded. But since we are not going to do that right now we can call the function just like this i.e. load(). And we are done. By writing our "DataController" class, instantiating it, and loading the store we now have a fully functional Core Data stack running in our app. Next we want our view controllers to start using this stack to fetch data. But first we need to get our code in a state where it builds, and runs.
        dataController.load()
        // MARK: 6. Injecting the DataController Dependency
        // 00:59 Here in application did finish launching with options we have a chance to configure the first view although getting out that view is multi-step process, so bear with it.
        // 01:09 To get to it, we'll need to talk to navigation controller, which is the "window?rootViewController" and will force downcast that to a navigation controller.
        let navigationController = window?.rootViewController as! UINavigationController
        // 01:21 That's half way there. The navigation controllers top view is the notebooks list. So we'll set "NotebooksListViewController" equal to navigationController.topViewController and force down cast that to a notebooksListViewController
        let notebooksListViewController = navigationController.topViewController as! NotebooksListViewController
        // 01:41 Finally we can set notebooksListViewController's data controller to the dataController property. This will inject the dataController dependency into notebooksListViewController. So now we can head back to "NotebooksListViewController.swift" and use it to load saved data into our app ... move there ... see line "var dataController: DataController! // newly inserted based on above comment
        notebooksListViewController.dataController = dataController
        return true
        
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

