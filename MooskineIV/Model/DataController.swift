//
//  DataController.swift
//  Mooskine
//
//  Created by mairo on 24/01/2023.
//  Copyright © 2023 Udacity. All rights reserved.
//

import Foundation

import CoreData

class DataController {

    let persistentContainer: NSPersistentContainer
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
        
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            // 03:52 Finally, we need to kick off the initial autosave, and we can do that once the persistent stores have been loaded up here in 'func load'. I am setting a short interval so that we can test it easily, and let's ***add a print statement (to the 'func autoSaveViewContext') so that we can see the function running.
            // 04:22 Let's run and test. And in the console output, we see the autosave is happening. I'll stop the app running, and set the interval back to the default by removing the argument up here:
            self.autoSaveViewContext(/*interval: 3*/) // removing the argument up here
            completion?()
            // 04:35 In Mooskine, adding and deleting notes and notebooks are natural places to explicitly save. Auto-save help if the app were to crash in between those explicit saves. In your future apps, you'll need to consider the content and user interactions and decide whether it makes sense to add auto saving. Now that we have a handle on how early and often to save, let's review some core data concepts. 
        }
    }
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

}


// 01:34 Great, this technique of saving just before the app is backgrounded or terminated will cover a lot of situations. Another option to consider is saving on timer. We can set a function to be called at regular intervals and each time that interval passes, if the context has any changes, we'll try saving it to the store. This can be particularly appropriate in cases where data is entered continuously such as while editing text. Let's implement auto-saving in data controller.
// 02:00 To keep our code tidy, let's add this as an extention at the bottom of the file.

extension DataController {
    // 02:07 Our strategy here will be to write a method that saves the view context and then recursively calls itself again every so often. We'll call it autoSaveViewContext and it will accept an interval parameter with a default value of 30 seconds. The interval only makes sense if it's a positive number so let's use a guard statement to catch incorrect usage.
    func autoSaveViewContext(interval: TimeInterval = 30) {
        print("autosaving")// ***add a print statement so that we can see the function running
        guard interval > 0 else {
            print("cannot set negative auto-save interval")
            return
        }
        // 02:31 Next, we'll call save on the viewContext. The save method can throw but we'll discard the error using try question mark. Note that we should be careful not to take drastic action such as showing an alert to the user if, let's say, fails. We'll just try again at the next interval.
        // try? viewContext.save() // commented out and passed inside 'if viewContext.hasChanges' ... see below ...
        // 02:51 This looks reasonable but there is a little problem. Imagine we call autosave with an interval of 3 seconds. Our app will try to save the view context every 3 seconds even when nothing has changed. We can improve this by first, checking whether there were any changes and only saving if there are. NSManagedObjectContext provides a hasChanges property exactly for this purspose. We'll use it to check that the view context has changes, and only save if it does.
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        // 03:26 Finally, we'll use Grand Central Dispatch to call autosave again after the specific interval has elapsed. I set the interval to now plus the interval and change the rest of tnis to a trailing closure that calls the function.
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
        // 03:42 If we wanted more control, we could use an NS timer instead. That would let us, for example, pause the autosave behaviour.
        // 03:52 Finally, we need to kick off the initial autosave, and we can do that once the persistent stores have been loaded up here in 'func load' ... move up there ...
    }
    
}



