//
//  NotebooksListViewController.swift
//  Mooskine
//
//  Created by Josh Svatek on 2017-05-31.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit
import CoreData

class NotebooksListViewController: UIViewController, UITableViewDataSource {
    /// A table view that displays a list of notebooks
    @IBOutlet weak var tableView: UITableView!

    // MARK: 10. The Existing Model
    // 00:16 When you first open Mooskine, you see a list of notebooks. That view is in notebooks list view controller. So let's look in here for an array of notebooks that powers the TableView. And here it is:
    /// The `Notebook` objects being presented
    // // MARK: 6. Injecting the DataController Dependency
    // 00:00 When you launch Mooskine, first screen is a table view of notebooks displayed by the "NotebooksListViewController.swift". So let's look there now ... check in Moonskine.xcodeproj ... Until now, the app has used an array of Notebook objects as the tableView data source ...
    // 00:19 We have changed the Notebook class to work with Core Data, but we can still use this array to power the table view. And actually we do not even have to touch the table view's data source methods, but we do need to populate this array with data from persistent store. And for that, we need the data controller that we created in the AppDelegate.swift
    var notebooks: [Notebook] = []
    // 00:45 Let's add a property to hold the data control right here below the notebooks array. We'll implicitly unwrap it because we cannot count on this dependency being injected once we hop over to AppDelegate.swift and make that happen. Now move to AppDelegate.swift ... // 00:59 Here in application did finish launching with options ...
    var dataController: DataController! // newly inserted based on above comment
    // MARK: 7. Fetching Data for NotebooksListViewController
    // 00:00 Now that we have a reference to the dataContnroller we can use it to request data from the store. We'll do that through the Fetch request. Fetch request selects data that we are interested in, for example all of the notebooks and loads this data from the persistent store into a context where we can access it. It must be configured with with an empty type and can otptionally include filtering, sorting and other configuration. Move to comment // 00:30 few lines below
    
    
    // 00:27 (comment from previous exercise/lesson) By pressing Option and clicking on [Notebook] and choosing link under Defined in 'notebook.swift', let's see how notebooks are defined. Let's move to 'Notebook.swift'...

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "toolbar-cow"))
        navigationItem.rightBarButtonItem = editButtonItem
        
        // 00:30 To create one we need to first import CoreData, so above write import CoreData. Now in viewDidLoad() let's create our Fetch Request of type NSFetchRequest.Fetch Requests are generic type so we specify notebook as the type parameter in angle brackets. That will make this a Fetch Request that works with a specific managed object subclass.
        // 00:55 Then we'll call the type function Fetch Request on that subclass. Which returns a new Fetch Request initialized with that entity. So, we have a basic Fetch Request, let's configure it by adding a sort rule.
        let fetchRequest: NSFetchRequest<Notebook> = Notebook.fetchRequest()
        
        // 01:11 The Fetch Request sortDescriptors property takes an array of sort descriptors. But we're just going to use one that sorts on date from newest to oldest. So above code line 'fetchRequest.sortDescriptors = []' we will write:
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        // 01:37 And we'll add this sort descriptor to the sort descriptors array.
        fetchRequest.sortDescriptors = [sortDescriptor]
        // 01:39 Great, our Fetch Request is ready to go, all we have to do now is to use it. We need to ask a context to execute the request and we'll ask our data controllers view context. Now the fetch() function can throw an error, so we only want to save the result if the fetch was successful. So let's finish passing in the Fetch Request.
        // 02:06 And then we'll only store the result if we're successful. Using try with a questionmark to convert an error into an optional. If the Fetch Request was successful we store the result in the notebooks array.
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            notebooks = result
            // 02:23 As of iOS 10, Fetch Requests and the Fetch method are types. So here it returns an array of notebooks, no casting necessary and we can save it right into our notebooks array.
            // 02:35 The last thing we need to do is to update the UI. So we'll call tableView.reloadData() which will populate the table view using the notebooks array. That's it, not a lot has changed we have added a little extra code to search for data in a persistent store but otherwise things are working just the way they did before Core Data.
            // 02:57 Let's try it out, we'll run Mooskine with the changes we have just made. And as can see there is still nothing there on the 1st screen, not a signle notebook. Oh yeah, I know what is going on, Mooskine is fetching data from the store but there is no data in the store to show yet. Let's fix that now by adding some notebooks. 
            tableView.reloadData()
        }
        
        
        updateEditButtonState()
        
        // let notebook: Notebook // commented out, was here only during exercise
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }

    // -------------------------------------------------------------------------
    // MARK: - Actions

    @IBAction func addTapped(sender: Any) {
        presentNewNotebookAlert()
    }

    // -------------------------------------------------------------------------
    // MARK: - Editing
    
    // MARK: 8. Adding and Deleting Notebooks
    // 00:23 When user taps the addNotebook button, it triggers the addTapped function, where we present an alert that asks the user for a notebook name as can see below "Enter a name for this notebook", and then calls addNotebook as can see in line 'self?.addNotebook(name: name)'. So that's where we need to be.
    // 00:36 I am goin to command + click on .addNotebook(name: name) and select 'jump to definition' (that throws us to the line 'func addNotebook(name: String)' around line 117) ... move there ...

    /// Display an alert prompting the user to name a new notebook. Calls
    /// `addNotebook(name:)`.
    func presentNewNotebookAlert() {
        let alert = UIAlertController(title: "New Notebook", message: "Enter a name for this notebook", preferredStyle: .alert)

        // Create actions
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] action in
            if let name = alert.textFields?.first?.text {
                self?.addNotebook(name: name)
            }
        }
        saveAction.isEnabled = false

        // Add a text field
        alert.addTextField { textField in
            textField.placeholder = "Name"
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: .main) { notif in
                if let text = textField.text, !text.isEmpty {
                    saveAction.isEnabled = true
                } else {
                    saveAction.isEnabled = false
                }
            }
        }

        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        present(alert, animated: true, completion: nil)
    }

    /// Adds a new notebook to the end of the `notebooks` array
    // 03:02 OOOhhh, interesting it's trying to use the old initializer for notebook. The code-generated version of notebook has a different initializer that lets us associcate the instance with a context, but we cannot access the data controller's view context from here yet. Let's leave as to-do for now, and comment out this in next line until we can fix it.
    // 03:23 The last two errors are about missing functions for adding and and removing notes from a notebook (see "NotesListViewController.swift" line 55)... move there ... Our code-generated class does not include these functions yet. We'll add them very soon 
    func addNotebook(name: String) {
        // TODO: change initializer
        // let notebook = Notebook(name: name)
        // notebooks.append(notebook)
        // MARK: 8. Adding and Deleting Notebooks (continuation)
        // 00:45 We need to change the way we instantiate notebooks, the old code (as can see in above commented out lines 'let notebook = Notebook(name: name)') called a non-core data initializer, we can no longer do that. Instead now that notebook is a managed object, we'll use the convenience initializer for managed objects that let's us associate it with a context.
        // 01:06 And we'll create a new notebook associated with the data controllers view context:
        let notebook = Notebook(context: dataController.viewContext)
        // 01:16 We'll set its name with the name the user supplied, let's pass it in the parameter
        notebook.name = name
        // and set the creation date to now
        notebook.creationDate = Date()
        // 01:26 As soon as it is created we'll ask the context to save the notebook to the persistent store.
        try? dataController.viewContext.save()
        // 01:36 we'll also need to add this notebook to the notebooks array.  Since the list is fetched with a sort order of newest first, we'll insert it at the beginning. So instead of appending at the end we'll insert the new notebook at position zero.
        notebooks.insert(notebook, at: 0)/*append(notebook)*/
       // 01:53 And we'll set the row to zero here, so from numberOfNotebooks - 1 change to 0. Now if the context can't save for some reason, it will throw an error. Above in line 'try? dataController.viewContext.save()' we are converting an error to an optional. But in a production app, we would notify user that the data has not been saved. Check out the save function documentation linked below this video for some suggestions about error handling (ee links below). Okey, let's try it out. Let's restart Mooskine, let's add a notebook, great now it appeared in a table. Okey let's add another, nice the new one was added at the top. So let's make sure these are actually being persistent.
        // 02:41 Terminate the app by 
        //https://developer.apple.com/documentation/coredata/nsmanagedobjectcontext/1506866-save
        //https://github.com/objcio/core-data/blob/master/SharedCode/NSManagedObjectContext%2BExtensions.swift
        
        tableView.insertRows(at: [IndexPath(row: /*numberOfNotebooks - 1*/ 0, section: 0)], with: .fade)
        updateEditButtonState()
    }

    /// Deletes the notebook at the specified index path
    func deleteNotebook(at indexPath: IndexPath) {
        notebooks.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        if numberOfNotebooks == 0 {
            setEditing(false, animated: true)
        }
        updateEditButtonState()
    }

    func updateEditButtonState() {
        navigationItem.rightBarButtonItem?.isEnabled = numberOfNotebooks > 0
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }

    // -------------------------------------------------------------------------
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfNotebooks
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aNotebook = notebook(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: NotebookCell.defaultReuseIdentifier, for: indexPath) as! NotebookCell

        // Configure cell
        cell.nameLabel.text = aNotebook.name
        // as per exrcise // MARK: 5. Switching to Code-Generated Classes
        // ok one (error) down, let's handle the other errors that have to do with optionals. This one is about a set being optional, that's the set of notes in a notebook. So we'll need to wrap this in a if let too. Actyally i can see that it is not the notes set itself buth the notes set .count that we are referencing on these two lines. So let's unwrap down to count:
        if let count = aNotebook.notes?.count {
            let pageString = count /*aNotebook.notes.count*/ == 1 ? "page" : "pages"
            cell.pageCountLabel.text = "\(aNotebook.notes?.count ?? 0) \(pageString)"
        }
        // next error shall be and is not in "NotesListViewController.swift" line 110 ... move there
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete: deleteNotebook(at: indexPath)
        default: () // Unsupported
        }
    }

    // Helper

    var numberOfNotebooks: Int { return notebooks.count }

    func notebook(at indexPath: IndexPath) -> Notebook {
        return notebooks[indexPath.row]
    }

    // -------------------------------------------------------------------------
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If this is a NotesListViewController, we'll configure its `Notebook`
        if let vc = segue.destination as? NotesListViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                vc.notebook = notebook(at: indexPath)
            }
        }
    }
}
