//
//  Notebook+Extensions.swift
//  MooskineII
//
//  Created by mairo on 01/02/2023.
//  Copyright © 2023 Udacity. All rights reserved.
//

import Foundation

// MARK: 20. Extending Model Classes
// these comments are also in 'Notebook+Extensions.swift' that is created in time 03:31
// 00:00 Our Mooskine app is now fully functional and fully persisted using core data, and we did not have to change a lot. We just have:
    // set up the data model and core data stack
    // then we added a little code so that model objects were inserted and deleted in a contexts
    // and finally, we made sure to save the contexts at appropriate times.

// 00:28 So it's working but there is one small piece of functionality we lost, and it has to do with how we set the creation date for notebooks and notes. The original version set the creation date in their initializers. Here the auto-generated classes don't do that. So now, we have to set all the attributes for our model objects manually after in it.

// 00:49 For example, in NotebooksListViewController, in 'func addNotebook' right here ... see code line: 'notebook.creationDate = Date()'

// 00:58 Can we update our managed object subclasses to set a property on in it? We have to be a little careful. The life cycle or series of states and object instance passes through over the course of its existence is a little different than it used to be. We used to only create a notebook instance at the time the user asked us to, right here in line 'notebook.creationDate = Date()' within 'NotebooksListViewController.swift'

// 01:22 But now, we also instantiate notebooks when we fetch them from the persistance store in viewDidLoad of 'NotebooksListViewController.swift' see following code lines:
    /*
     let fetchRequest: NSFetchRequest<Notebook> = Notebook.fetchRequest()
     let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
     fetchRequest.sortDescriptors = [sortDescriptor]
     if let result = try? dataController.viewContext.fetch(fetchRequest) {
        notebooks = result
        tableView.reloadData()
     */

// 01:33 If we were to set the creation date every time we loaded a saved notebook, we'd be overwriting its true creation time. To configure an object when it's first created, we have a couple of options.
    // 01:46 The 1st option is to set default values for attributes in the model editor i.e. 'mooskineDataModel.xcdatamodeld'. For example, looking at Note, we can give the same default text value of 'New Note' to all new notes, go to 'mooskineDataModel.xcdatamodeld'/ Note / text / for Default Value write e.g. 'Neue Note', still in 'NotesListViewController.swift' have to comment out code line 'note.text = "New note"' so that the Default Value is shown, otherwise the one defined in code is shown.
    // 02:03 THe 2nd otpion, for values that we can't anticipate, like the current time, our second option is to override a life cycle mehtod in NSManagedObject. When opening the developer documentation, 'func  willSave() and 'func prepareForDeletion()' are two examples of life cycle events. The ones for managed object creation all start with awake. Here we see 'func awakeFromFetch()', 'func awakeFromInsert', and 'awake(fromSnapshotEvents: NSSnapshotEnentType)'.

// 02:31 'func awakeFromFetch()' is called when we fulfilled data from a fault, or in other words, load saved dta from the store. So, not this one.
// 02:42 awake(fromSnapshotEvents: NSSnapshotEnentType)' relates to undo and context roll backs. So not that one either.
// 02:50 That leaves 3rd option i.e. 'func awakeFromInsert' which is called only on initial object creation. Perfect. Let's look at how overwriting 'func awakeFromInsert' would work in Notebook. Now, remember that we're using a generated class file for Notebook. The Notebook class file doesn't even appear in the project navigator. It's tucked away in derived data. And we shouldn't update that file as our changes would be overwritten. So let's create an extention, where we can safely put custom code.
// 03:22 First, let's create a group in the project for our model extensions. Right click on folder 'Model' and choose 'New Group', and le't rename that to 'Managed Object Extensions'
// 03:31 Now, let's create a new Swift file. We'll call it 'Notebook+Extensions.swift'. Let's be sure to import CoreData.

import CoreData

// 03:33 and let's be sure to declare the extension
extension Notebook {
    // 03:47 Now, we can implement awake from insert.
    public override func awakeFromInsert() {
        // 03:50 First, we need to call super.awake from insert. We don't want to override the default implementation, only add to it.
        super.awakeFromInsert()
        // 04:00 Now, we can set the creation date to the current date. Okay, that takes care of initializing Notebook.
        creationDate = Date()
        // 04:07 Now, we need to do the same for Note. Complete the following task list to customize Note initialization. Once you do, both Notebook and Note will set their creation dates when they're created.

    }
}
