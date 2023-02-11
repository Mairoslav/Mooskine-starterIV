//
//  AppDelegate.swift
//  Mooskine
//
//  Created by Josh Svatek on 2017-05-29.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let dataController = DataController(modelName: "mooskineDataModel")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        dataController.load()
        let navigationController = window?.rootViewController as! UINavigationController
        let notebooksListViewController = navigationController.topViewController as! NotebooksListViewController
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
        saveViewContext() // a)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        saveViewContext() // b)
    }

    // MARK: 17. When Should You Save?
    // 00:45 One place you should always save, is in the AppDelegate, before your app terminates or when it enters the background. This will cover a number of abrupt termination cases, and would have ensured that our note text would have eventually been saved even if we'd forgotten to update NoteDetailsViewController. So let's open our AppDelegate and in both:
        // a) applicationDidEnterBackground, and
        // b) applicationWillTerminate,

    // 01:14 Let's add a call to save our managed object context. We'll create a helper method caled SaveViewContext, that calls save on the data controllers view context and call it from both of these functions: a) and b) as above described.
    func saveViewContext() {
        try? dataController.viewContext.save()
    }
    
    // 01:34 Great, this technique of saving just before the app is backgrounded or terminated will cover a lot of situations. Another option to consider is saving on timer. We can set a function to be called at regular intervals and each time that interval passes, if the context has any changes, we'll try saving it to the store. This can be particularly appropriate in cases where data is entered continuously such as while editing text. Let's implement auto-saving in data controller. ...move to 'DataController.swift'...

}

