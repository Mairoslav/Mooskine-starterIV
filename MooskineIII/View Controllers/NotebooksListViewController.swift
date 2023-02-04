//
//  NotebooksListViewController.swift
//  Mooskine
//
//  Created by Josh Svatek on 2017-05-31.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit
import CoreData

// 03:25 Scroll to the top of our file and in the class declaration, we will add NSFetchedResultsControllerDelegate conformance
class NotebooksListViewController: UIViewController, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    var notebooks: [Notebook] = []
    
    var dataController: DataController!
    
    // MARK: 6. Adding a Fetched Results Controller
    // 00:00 Let's update 'NotebooksListViewController.swift' to use a fetchedResultsController. The fetchedResultsController will persist over the lifetime of the ViewController, so let's add a 'var fetchedResultsController: NSFetchedResultsController' property to retain it (make this change in 'NotebooksListViewController.swift').
    var fetchedResultsController: NSFetchedResultsController<Notebook>!
    // 00:14 Just like with fetchedRequests, the fetchedResultsController needs to be specialized for the type of object it returns. In our case, <Notebook>!. Via ! we make it an implicitly unwrapped optional and instantiate it in viewDidLoad().
    // 00:33 You could also instantiate it in 'viewWillAppear if you prefer. The important thing is to set up the 'fetchedResultsController' early, so that it's ready to present content to the user. Before we do that, though, for reasons related to notifications, we'll also need to tear down the fetchedResultsController when this view disappears.
    // 00:52 So, we'll override 'viewDidDisapper' called ... move down ...
    
    fileprivate func setUpFetchedResultsController(_ fetchRequest: NSFetchRequest<Notebook>) {
        // 02:02 Now, we can use this fetchRequest to instantiate the fetchedResultsController. The initializer takes several parameters. 1. We'll pass in the fetchRequest as the first parameter. 2. For the managedObjectContext, we'll use the dataController's viewContext. 3. and 4. And we'll use nil for both the sectionNameKeyPath and the cacheName for now.
        // 02:25 The keyPath could be used to split results into sections and display a title for each section, similarly to how contacts are grouped in the phone app. But since we want all the notebooks in a single section, will just leave this as nil. cacheName is also optional so, we'll set it to nil for now until we look into caching later.
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        // 02:50 Finally, will call .performFetch() to load data and start tracking. performFetch throws if the fetchRequest can't be executed for some reason. So we'll wrap in a do catch block, and throw a fatalError if it fails.
        // *fetchedResultsController delegate property to self and that's it
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "toolbar-cow"))
        navigationItem.rightBarButtonItem = editButtonItem
        
        // 01:37 (below trhee lines of code wer copy-pasted from fileprivate func reloadNotebooks()) One things to be aware of, generally, fetchRequests don't have to be sorted but any fetchRequest you use with a fetchResultsController must be sorted so that it has a consistent ordering.
        // 01:52 We're alrady sorting this one by creationDate, so we do not need to change anything here.
        let fetchRequest: NSFetchRequest<Notebook> = Notebook.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        setUpFetchedResultsController(fetchRequest)
        // 03:03 There is one last step, fetchedResultsControllers track changes and to respond to those changes, we need to implement some delegate methods. We'll look at the delegtate in detail in a moment. But since it doesn't have any mandatory elements, let's go ahead and make our viewController conform.
        // 03:25 Scroll to the top of our file and in the class declaration, we will add NSFetchedResultsControllerDelegate conformance (see this comment also duplicated obove there).
        // 03:37 Now in viewDidLoad, above the do-try-catch statement, we'll set the *fetchedResultsControllerDelegate property to self and that's it. We now have a fetchedResultsController that loads and tracks data for us. The steps we took were:
            // 1. that we created a fetchRequest rememberring to include sortDesctiptors (via copy paste of 3 lines of code)
            // 2. and used it to instantiate the fetchedResultsController (via fetchedResultsController = NSFetchedResultsController(4 parameters...))
            // 3. we added NSFetchedResultsControllerDelegate protocol conformance to the class and set the delegate via fetchedResultsController.delegate = self
            // 4. and finally, we called fetchedResultsController.performFetch() within do-try-catch statement
        // 04:15 Now, I don't really like leaving all this fetchedResultsController set up in viewDidLoad. So I am going to refactor it out into a separate setUpFetchedResultsController method (she selects all code described in above steps (now commented out)/Refactor/Extract Method/call it setUpFetchedResultsController). That's better.
        // 04:27 You may be thinking this code (3 copy-pasted lines) is duplicated in reloadNotebooks (from where it was copied), but we are about to change that. Now that we have a fetchedResultsController, we can swap it in as the data source for our table view and have the table view update itself when changes occur.
        
        reloadNotebooks() // *basically content of this function had been before here
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
    
    // 00:52 So, we'll override 'viewDidDisapper'
    override func viewDidDisappear(_ animated: Bool) {
        // called super.viewDidDisappear.
        super.viewDidDisappear(animated)
        // and then in here, we can set the fetchedResultsController to nil
        fetchedResultsController = nil
        // 01:04 Okay, so back to setup. To instantiate a fetchedResultsController, we'll neet to tell it which data objects to fetch and track. Just as we did before, we'll describe the data we want through a fetchRequest. Actually, we can use the same fetchRequest we already have.
        // 01:24 From here in override func viewDidDisappear Let's go and copy the fetchRequest from 'reloadNotebooks and paste it in viewDidLoad (she press Command+click on reloadNotebooks()/Jump To Definition/that throws us to fileprivate func reloadNotebooks(), from here we copy code lines of fetchRequest, now they are commented out there). ...move up to viewDidLoad check // 01:37 One things to be aware of, generally, ...
    }

    // -------------------------------------------------------------------------
    // MARK: - Actions

    @IBAction func addTapped(sender: Any) {
        presentNewNotebookAlert()
    }

    // -------------------------------------------------------------------------
    // MARK: - Editing

    /// `addNotebook(name:)`.
    func presentNewNotebookAlert() {
        let alert = UIAlertController(title: "New Notebook", message: "Enter a name for this notebook", preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] action in
            if let name = alert.textFields?.first?.text {
                self?.addNotebook(name: name)
            }
        }
        saveAction.isEnabled = false

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
    // MARK: 3. Complexity in Mooskine
    // 00:16 In the UI, when the user taps on the Add Notebook button, an alert is displayed. If th user provides a name and taps save, then addNotebook is called. Reading through this method, there are actually several different things that it's doing:
    func addNotebook(name: String) {
        // TODO: 01:26 We can break this function into the tasks related to adding a notebook in the model,
        // 00:36 It creates a new notebook
        let notebook = Notebook(context: dataController.viewContext)
        // 00:40 configures it,
        notebook.name = name
        notebook.creationDate = Date()
        // 00:41 and saves the context to persist it.
        try? dataController.viewContext.save()
        // TODO: 01:30 and the tasks for refreshing the tableView in the UI
        // 00:48 It adds the new notebook to the ViewControllers NotebooksArray.
        // notebooks.insert(notebook, at: 0) // TODO: line 1
        // 00:51 It tells tableView to add a row and animate the insertion.
        // tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade) // TODO: line 2
        // 00:59 And finally, it updates the state of the edit button since that button is disabled when the list is empty.
        // updateEditButtonState() // TODO: line 3
        // 01:08 This method is a big blob of functionality all tangled up together. The root of the proble is that we both change the data in the model and update the user interface. So let's separete out those responsibilities.
        // 01:26 We can break this function into the tasks related to adding a notebook in the model (see above again this comment, to see what lines it involves),
        // 01:30 and the tasks for refreshing the tableView in the UI (see above again this comment, to see what lines it involves).
        
        // 02:20 and finally in 'addNotebook' we can replace these last three lines (now commented out, see TODOs: 1 - 3) with a call to our new method:
        reloadNotebooks()
        
        // 02:27 This will work, 'addNotebook' is much cleaner now. It only updates the model and calls out to reload notebooks to update the UI. But it's still not as clean as it could be. It would be better if the view just new to update when the context changed without having to be prompted here. The good news is that Core Data provides tools for reactging to data changes. Let's look into using a fetchedResults controller to do precisely this (see next lesson '4. NSFetchedResultsController').
        
    }
    
    fileprivate func reloadNotebooks() {
        // 01:37 We also have some code for refreshing the UI in viewDidLoad (move there). And what's nice about the logic up here is the way it executes the fetchRequest before reloading the tableView. It doesn't have any insertion animations to give the user clues what content has changed but that's okay. Let's keep this simple for now, and we'll improve it later in the lesson.
        // 02:00 Let's pull this code out into its own function that we can call from both viewDidLoad() and addNotebook(). Choose below code / right click / Refactor / Extract Method. And we'll name it 'reloadNotebooks'.
        // 02:14 Xcode put it (the 'fileprivate func reloadNotebooks()) here above viewDidLoad(). Let's move it down below addNotebook, ok done. And finally in 'addNotebook' ... move there
        /// 01:24 based on // MARK: 6. Adding a Fetched Results Controller - From here in override func viewDidDisappear Let's go and copy the fetchRequest from 'reloadNotebooks and paste it in viewDidLoad (she press Command+click on reloadNotebooks()/Jump To Definition/that throws us to fileprivate func reloadNotebooks(), from here we copy code lines of fetchRequest, now they are commented out there).
        /*
        let fetchRequest: NSFetchRequest<Notebook> = Notebook.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
         */
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            notebooks = result
            tableView.reloadData()
        }
        updateEditButtonState()
    }

    func deleteNotebook(at indexPath: IndexPath) {
        let notebookToDelete = notebook(at: indexPath)
        dataController.viewContext.delete(notebookToDelete)
        try? dataController.viewContext.save()
        
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

        cell.nameLabel.text = aNotebook.name
        if let count = aNotebook.notes?.count {
            let pageString = count /*aNotebook.notes.count*/ == 1 ? "page" : "pages"
            cell.pageCountLabel.text = "\(aNotebook.notes?.count ?? 0) \(pageString)"
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete: deleteNotebook(at: indexPath)
        default: ()
        }
    }

    var numberOfNotebooks: Int { return notebooks.count }

    func notebook(at indexPath: IndexPath) -> Notebook {
        return notebooks[indexPath.row]
    }

    // -------------------------------------------------------------------------
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? NotesListViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                vc.notebook = notebook(at: indexPath)
                // MARK: NotebooksListViewController: pass `dataController`
                // 00:25 Now, over in NotebooksListViewController (move there ...) we can pass the DataController instance in prepare for sender (b.ii).
                // 00:38 Okay, great. So now, we pass both notebook and the CoreDataStack to the NotesList once a notebook is selected (b.iii). Move to 'NotesListViewController.swift' in viewDidLoad()... 
                vc.dataController = dataController
            }
        }
    }
}
