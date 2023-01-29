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
            completion?()
        }
    }
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

}
    
    



