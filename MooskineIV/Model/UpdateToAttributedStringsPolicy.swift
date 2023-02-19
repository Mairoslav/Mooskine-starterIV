//
//  UpdateToAttributedStringsPolicy.swift
//  MooskineIV
//
//  Created by mairo on 17/02/2023.
//  Copyright © 2023 Udacity. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class UpdateToAttributedStringsPolicy: NSEntityMigrationPolicy {

    override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        // Call super
        // First, we call the superclass version of this method, passing all the parameters up. We have the source instance sInstance (i.e. the existing record), the mapping file we just created, and a migration manager
        try super.createDestinationInstances(forSource: sInstance, in: mapping, manager: manager)

        // Get the (updated) destination Note instance we're modifying
        // In addition to the source record, we need a reference to the destination record. We can get this using the manager’s destinationInstances method, passing in the mapping and sInstance.
        guard let destination = manager.destinationInstances(forEntityMappingName: mapping.name, sourceInstances: [sInstance]).first else { return }

        // Use the (original) source Note instance, and instantiate a new
        // NSAttributedString using the original string
        // Once we have both, we can read the text property from sInstance, and use it to set the attributedText property on destination.
        if let text = sInstance.value(forKey: "text") as? String {
            destination.setValue(NSAttributedString(string: text), forKey: "attributedText")
        }
    }
}
