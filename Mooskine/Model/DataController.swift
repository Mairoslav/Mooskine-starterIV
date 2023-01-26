//
//  DataController.swift
//  Mooskine
//
//  Created by mairo on 24/01/2023.
//  Copyright © 2023 Udacity. All rights reserved.
//

import Foundation

// MARK: 4. Setting Up the Stack in Mooskine
// 00:00 Ok let's set up the Core Data stack in Mooskine, so that we can interact with Note and Notebook instances. We'll continue working with our Mooskine project from where we left off.

// 00:22 First we need to decide where to put our stack setup code. We want to set up this stack when our application first starts up, but it's better if we do not clutter (overfill) the App Delegate. So let's create a class to encapsulate the stack setup, and its functionality. We'll call it DataController. So let's do it:

// 0:42 Right click on the folder Model Group / Choose New File / Swift File / Next / name file 'DataController.swift' / click create

// 01:01 First we need to import Core Data:

import CoreData

// 01:04 Now let's declare our DataController class. Note that we are making it a class instead of struct, because we are going to pass it between ViewControllers, and we do not want to create multiple copies when doing so.
// 01:18 Now to fill out our class. We want this class to do 3 things:
    // 1. to hold a persistant container instance,
    // 2. to help us load the persistent store,
    // 3. and to help us access the context.

class DataController {
    // MARK: 1. to hold a persistant container instance
    // 01:33 So let's set that up starting from the 1. persistant container. The 1. persistant container should not change over the life of the DataController, so let's make it immutable, of type NSPersistantContainer.
    let persistentContainer: NSPersistentContainer
    // 01:47 And we'll add an initializer that configures it. To make an instance of a persistentContainer, we'll need the name of the data model file. So let's accept modelName as a String parameter.
    init(modelName: String) {
        // 01:59 Now we can instantiate the persistentContainer and pass the modelName into its initializer.
        persistentContainer = NSPersistentContainer(name: modelName)
    }
        // MARK: 2. to help us load the persistent store
        // 02:08 So we have created a persistentContainer. Now let's use it to load the persistent store. We'll make a convenience func load() that mostly just calls the persistentContainers' 'loadPersistentStores' function
        // 02:26 Notice that 'loadPersistentStores' function accepts a completionHandler as its only parameter. So let's write this as a trailing closure, with the 'storeDescription' and an Error parameters comming in.
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            // 02:36 If there is an error loading the store, we want our app to stop execution and log the problem. So we'll guard that the error is nil. Else, if its not we'll throw a fatalError()
            // 02:51 We may also want to pass in a function to get called after loading the store. So let's accept that as a parameter for 'func load()' above. So we'll call it completion and give it type closure. Although let's make it optional and default it to nil.
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            // 03:06 And we'll call it just after guard block.
            completion?()
            // 03:10 Allright, now we can load the store, so step 2 is completed.
        }
    }
    
    // MARK: 3. and to help us access the context
    // 03:17 Finally, let's add a convenience property to access the context. We'll make a computed property that returns the persistentContainer's viewContext.
    // 03:28 The viewContext is associated with the Main Queue. We'll explore exactly what that means in a later lesson. And that's it, that's all we need in our "DataController" class.
    // 03:39 Now to use it. I mentined already, we want to alert/launch the persitent data as early as possible when our app starts up. A good place to do this is an App Delegate. Let's head over there .... move to "AppDelegate.swift" ... // 03:54 ...
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

}
    
    



