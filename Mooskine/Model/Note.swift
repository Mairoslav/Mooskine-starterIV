//
//  Note.swift
//  Mooskine
//
//  Created by Josh Svatek on 2017-05-31.
//  Copyright © 2017 Udacity. All rights reserved.
//

import Foundation

// 00:45 Now let's look at Note, it has also two properties: (let) creationDate and (var) text that holds the notes content.
// 00:56 Now let's consider the relationship between these classes:
    // Notebook: Notebook can have any number of notes in its notes array.
    // Note: but a Note can only belong to a single Notebook.

// This is what we call 'One-to-many' relationship between Notebook and Note.
// 01:18 Together Notebook and Note comprise Mooskine's data model. The are both simple classes with no persistence, and when the app terminates, the data will be lost. So let's change our data model to a Core Data model that we can persist.

// MARK: 11. Adding a Core Data Model
// 00:00 We need to replace our apps non-core data model with a Core Data model. To start off, let's delete some code. Note though that this is going to break the build for a while. So if you start seeing errors, don't worry, we'll be fixing them soon enough.
// 00:19 Select 'Note.swift' and 'Notebook.swift' and delete them (here I just comment them out so can see how it was before). Excellent, deleting code when refactoring can be very satisfying.
// 00:35 Next, let's add a Core Data Model file to your project. This signle file will be used to design the entire Core Data model for Mooskine. In our 'Model' file/group here, select add a New File, scrol down, and in the Core Data section, select 'Data Model' and click next. Call it 'mooskineDataModel.swift'. What we are looking at now is Xcode's Integrated Data Model Editor.
// 01:25 We need to recreate Note and Notebook inside this Data Model. We'll create them as what are called entities. Press the Add Entity button (down-left). This created a new entity in the entities list up here on the up-left. Double click and rename it to the 'Notebook'.
// 01:44 While we are at it, add a new entity and name it 'Note'. We now have two entities we need. Our Data Model is off to great start. We'll add the properties that these entities need, like 'creationDate' and 'text' in moment. But first let's take a look at what entities are.

// MARK: 12. Entities
// let's see comments in playground called '5.Introducing Core Data.playground'.

/*
class Note {
    /// The date the note was created
    let creationDate: Date

    /// The note's text
    var text: String

    init(text: String = "New note") {
        self.text = text
        creationDate = Date()
    }
}
*/
