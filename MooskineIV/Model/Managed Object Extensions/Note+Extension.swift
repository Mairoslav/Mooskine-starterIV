//
//  Note+Extension.swift
//  MooskineII
//
//  Created by mairo on 01/02/2023.
//  Copyright © 2023 Udacity. All rights reserved.
//

import Foundation

// MARK: 21. Customizing Note Initialization
// Note also has a creationDate property, so let's override awakeFromInsert in an extension on Note as well.

// a) Add another extension file named 'Note+Extension.swift'
// b) Import Core Data
import CoreData
// c) Extend Note
extension Note {
    // d) Override 'awakeFromInsert'
    public override func awakeFromInsert() {
        // e) Call 'super.awakeFromInsert'
        super.awakeFromInsert()
        // f) Set 'creationDate' to the current date.
        creationDate = Date() 
    }
}
