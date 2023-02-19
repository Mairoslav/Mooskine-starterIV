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
class NotebooksListViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!

    // MARK: 8. Displaying Data
    // 00:00 We have an instance of fetchedResultsController, and we understand how it's structured (see 'var fetchedResultsController: NSFetchedResultsController<Notebook>' in NotebooksListViewController.swift). Now let's update the table view so that we can actuallyh see the data. The key change is that we're going to get rid of the Notebooks array (comment out 'var notebooks: [Notebook] = []'). Previously we had to populate a maintenance array manually, but now the fetchedResultsController will keep track of Notebooks for us. Any code that used the Notebooks array before, will now use the fetchedResultsController instead. So let's delete the Notebooks property (comment out 'var notebooks: [Notebook] = []'). And it's gone.
    // var notebooks: [Notebook] = []
    // 00:37 (continuation of 8. Displaying Data) We won't have to manually reload Notebooks anymore either. So let's delete the call to reloadNotebooks in viewDidLoad. ...move there...
    
    var dataController: DataController!
    
    // MARK: 6. Adding a Fetched Results Controller
    // 00:00 Let's update 'NotebooksListViewController.swift' to use a fetchedResultsController. The fetchedResultsController will persist over the lifetime of the ViewController, so let's add a 'var fetchedResultsController: NSFetchedResultsController' property to retain it (make this change in 'NotebooksListViewController.swift').
    var fetchedResultsController: NSFetchedResultsController<Notebook>!
    // 00:14 Just like with fetchedRequests, the fetchedResultsController needs to be specialized for the type of object it returns. In our case, <Notebook>!. Via ! we make it an implicitly unwrapped optional and instantiate it in viewDidLoad().
    // 00:33 You could also instantiate it in 'viewWillAppear if you prefer. The important thing is to set up the 'fetchedResultsController' early, so that it's ready to present content to the user. Before we do that, though, for reasons related to notifications, we'll also need to tear down the fetchedResultsController when this view disappears.
    // 00:52 So, we'll override 'viewDidDisapper' called ... move down ...
    
    fileprivate func setUpFetchedResultsController() {
        // below 3 lines were actually also chosen when she did Refactoring, I did miss it so doing it after only now as correction
        let fetchRequest: NSFetchRequest<Notebook> = Notebook.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        // 02:02 Now, we can use this fetchRequest to instantiate the fetchedResultsController. The initializer takes several parameters. 1. We'll pass in the fetchRequest as the first parameter. 2. For the managedObjectContext, we'll use the dataController's viewContext. 3. and 4. And we'll use nil for both the sectionNameKeyPath and the cacheName for now.
        // 02:25 The keyPath could be used to split results into sections and display a title for each section, similarly to how contacts are grouped in the phone app. But since we want all the notebooks in a single section, will just leave this as nil. cacheName is also optional so, we'll set it to nil for now until we look into caching later.
        // MARK: 13. Caching
        // 00:00 fetchedResultsControllers can avoid repetitive work byt caching section and ordering information. And in so doing, improved performance. When we created our fetched results controller, we left the cache name nil (see 'cacheName: nil'), which means that our fetched results controller will not use caching.
        // 00:20 If we specify a name for a cache, caching will happen automatically and teh cache will persist between sessions. Let's enable it by settin a cache name of notebooks (i.e. 'cacheName = "notebooks"). The cache updates itself automatically when section or ordering informatio changes. If you have multiple fetched results controllers, then each should have their own cache with different names. For example, our 'NotesListWiewController.swift' should only show cached results if we're looking at the same notebook as the last time this view appeared. You don't want to cache only one notebook's notes. So we have to be careful how we implement the cache name there.
        // 01:03 Also, if you ever change the fetch request and the fetched results controller, you should delete the cache manually first by calling the type method '.deleteCache(withName:).
        // NSFetchedResultsController<Notebook>.deleteCache(withName: "notebooks")
        // But we do not want to do that right now. In short, with caching, you can basically set it and forget it. We do not have big data in Mooskine, but caching is especially useful when you're working with large data sets. It helps your app load any table view the user has seen before, nearly instantaneously. You just have to turn it on (i.e. write 'cacheName = "notebooks")
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: /*nil*/ "notebooks")
        // below continuation of 6. Adding a Fetched Results Controller:
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
        // 01:52 We're alrady sorting this one by creationDate, so we do not need to change anything here(below 3 lines were actually also chosen when she did Refactoring, I did miss it so doing it after only now as correction):.
        /*
        let fetchRequest: NSFetchRequest<Notebook> = Notebook.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        */
        
        setUpFetchedResultsController()
       
        // 03:03 There is one last step, fetchedResultsControllers track changes and to respond to those changes, we need to implement some delegate methods. We'll look at the delegtate in detail in a moment. But since it doesn't have any mandatory elements, let's go ahead and make our viewController conform.
        // 03:25 Scroll to the top of our file and in the class declaration, we will add NSFetchedResultsControllerDelegate conformance (see this comment also duplicated obove there).
        // 03:37 Now in viewDidLoad, above the do-try-catch statement, we'll set the *fetchedResultsControllerDelegate property to self and that's it. We now have a fetchedResultsController that loads and tracks data for us. The steps we took were:
            // 1. that we created a fetchRequest rememberring to include sortDesctiptors (via copy paste of 3 lines of code)
            // 2. and used it to instantiate the fetchedResultsController (via fetchedResultsController = NSFetchedResultsController(4 parameters...))
            // 3. we added NSFetchedResultsControllerDelegate protocol conformance to the class and set the delegate via fetchedResultsController.delegate = self
            // 4. and finally, we called fetchedResultsController.performFetch() within do-try-catch statement
        // 04:15 Now, I don't really like leaving all this fetchedResultsController set up in viewDidLoad. So I am going to refactor it out into a separate setUpFetchedResultsController method (she selects all code described in above steps (now commented out)/Refactor/Extract Method/call it setUpFetchedResultsController). That's better.
        // 04:27 You may be thinking this code (3 copy-pasted lines) is duplicated in reloadNotebooks (from where it was copied), but we are about to change that. Now that we have a fetchedResultsController, we can swap it in as the data source for our table view and have the table view update itself when changes occur.
        
        // 00:37 (continuation of 8. Displaying Data) We won't have to manually reload Notebooks anymore either. So let's delete the call to reloadNotebooks in viewDidLoad. In fact, we should delete the whole reloadNotebooks method, since we're no longer managing this data ourselves (move to reloadNotebooks method and comment it out, also its call in func addNotebook). 00:58 That's grat func addNotebooks is definitely getting narrower in scope. The next step is to update our data source methods, since those had previously used the NOtebooks array. Let's jump to the data source section (i.e. MARK; Table view data source). There are three functions we'll need to change. 1st let's replace a code in func numberOfSections. ...move there...
        // reloadNotebooks() // *basically content of this function had been before here
        
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
        // reloadNotebooks()
        
        // 02:27 This will work, 'addNotebook' is much cleaner now. It only updates the model and calls out to reload notebooks to update the UI. But it's still not as clean as it could be. It would be better if the view just new to update when the context changed without having to be prompted here. The good news is that Core Data provides tools for reactging to data changes. Let's look into using a fetchedResults controller to do precisely this (see next lesson '4. NSFetchedResultsController').
        
    }
    
    /*
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
     */
    // 02:38 We also use the Notebook at helper function in deleteNotebook
    func deleteNotebook(at indexPath: IndexPath) {
        // 02:43 We can update the notebookToDelete constant to use object at instead.
        // let notebookToDelete = notebook(at: indexPath)
        let notebookToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(notebookToDelete)
        try? dataController.viewContext.save()
        
        // 02:47 While we are here, we can delete the second half of this method that deals with manually updating the UI (comment out below lines), since the fetchResultsController is going to handle that for us. // 03:00 Next, scroll down to prepare(for:sender:), ...move there...
        /*
        notebooks.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        
        if numberOfNotebooks == 0 {
            setEditing(false, animated: true)
        }
        updateEditButtonState()
         */
    }

    // 03:12 Last, the updateEditButtonState method has been using the NOtebooks array count to disable the edit button if there are no rows to edit. This should use the fetchedResultsController too.
    func updateEditButtonState() {
        // 03:23 We'll conditionally unwrap the sectons array,
        if let sections = fetchedResultsController.sections {
            // then check the number of objects in the first and only section (commenting out the previous code below). // 03:36 Finally, since we are no longer using them, we can delete the notebook(at:) helper method, and the numberOfNotebooks computed property. ... move there to see they are now commented out ...
            navigationItem.rightBarButtonItem?.isEnabled = sections[0].numberOfObjects > 0
        }
        // navigationItem.rightBarButtonItem?.isEnabled = numberOfNotebooks > 0
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }

    // -------------------------------------------------------------------------
    // MARK: - Table view data source

    // 01:12 First, let's replace a code in func numberOfSections. We'll need to use the fetchedResultsController's sections property to find out how many secions the data has.
    func numberOfSections(in tableView: UITableView) -> Int {
        // return 1
        // 01:23 The sections property is optional, so let's use optional binding.
        /*
        if let sections = fetchedResultsController.sections {
            return sections.count
        } else {
            return 1
        }
         */
        // 01:33 You can actually shorten this code using the coalescing operator to return the count if it exists, or one otherwise (so its alternative above we comment out).
        setUpFetchedResultsController() // A quick workaround is to call again the `setUpFetchedResultsController()` method just before the return statement as per Q&A: 'Unexpectedly found nil while implicitly unwrapping an Optional value for 'fetchedResultsController.sections?'
        return fetchedResultsController.sections?.count ?? 1 // this as shorthand of below code, check link below
        // fetchedResultsController.sections?.count != nil ? fetchedResultsController.sections!.count : 1
        // https://sarunw.com/posts/what-does-nil-coalescing-operator-means-in-swift/
        
    }

    // 01:43 Now, let's update tableView numberOfRowsInSection.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return numberOfNotebooks
        // 01:48 Again, we need to get the number of sections, so that we can refer to the specific section. Each section has a property name numberOfObjects. So we'll return numberOf Objects, otherwise, zero.
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    // 02:05 Finally, the last data source method we need to update is tableView cellForRowAt.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 02:10 In the existing version, we pass the indexPath to a helper method to get the right Notebook from the Notebooks array. We just need to switch this to get the Notebook from the fetchedResultsController instead. To do this we can feed the index path right into the fetchResultsController's object at function, so instead of below code that now commented out
        // let aNotebook = notebook(at: indexPath)
        // we write new one below. .object(at: ...) is generic, and will return an object typed to the result type of the fetchedResultsController, here, aNotebook (check it by option+click on .object). // 02:38 We also use the Notebook at helper function in deleteNotebook. ...move there...
        let aNotebook = fetchedResultsController.object(at: indexPath)
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

    // 03:36 Finally, since we are no longer using them, we can delete the notebook(at:) helper method, and the numberOfNotebooks computed property. And that's it. We've replaced our Notebooks array with the fetchedResultsController, and updated our tableView data source methods to get data from the fetchedResultsController instead. Now let's give it a try. Run the app in the simulator. We can see that we're still seeing all our Notebooks in the app. Yes. However, if we try to add a new Notebook, the new row still doesn't appear. We have to fix that. Let's look at how we can make the tableView automatically observe changes - see next lesson called '9. Tracking Changes'.
    /*
    var numberOfNotebooks: Int { return notebooks.count }

    func notebook(at indexPath: IndexPath) -> Notebook {
        return notebooks[indexPath.row]
    }
     */

    // -------------------------------------------------------------------------
    // MARK: - Navigation

    // 03:00 Next, scroll down to prepare(for:sender:), where we pass the selected Notebook to the next viewController,
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? NotesListViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                // 03:06 and change this line to use the fetchedResultsControllers object at method too. // 03:12 Last, the updateEditButtonState method has been using ... move there ...
                // vc.notebook = notebook(at: indexPath)
                vc.notebook = fetchedResultsController.object(at: indexPath)
                // MARK: NotebooksListViewController: pass `dataController`
                // 00:25 Now, over in NotebooksListViewController (move there ...) we can pass the DataController instance in prepare for sender (b.ii).
                // 00:38 Okay, great. So now, we pass both notebook and the CoreDataStack to the NotesList once a notebook is selected (b.iii). Move to 'NotesListViewController.swift' in viewDidLoad()... 
                vc.dataController = dataController
            }
        }
    }
}

// MARK: 9. Tracking Changes
// 00:00 NotebookListViewController.swift is correctly using the fetchedResultsController to display data when the view loads. But the table is not yet updating when the data changes, for example, after the user adds a new notebook. Now, we know that fetchedResultsControllers can automaticaly track dataq model changes. So why isn't it working? Well, to take advantage of this, we need to implement the fetchedResultsControllers' delegate methods.

// 00:31 We've alrady set up the delegate relationship as can see in line 'fetchedResultsController.delegate = self', and for that, we set up the class to conform to the NSFetchedResultsController delegate protocol. Let's move that conformance to an extension to keep this class organized. So we move 'NSFetchedResultsControllerDelegate' from place after the class declaration to extension down in file

extension NotebooksListViewController: NSFetchedResultsControllerDelegate {
    // 02:53 The controllerWillChangeContent method will get caled before a batch of updates.
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // 03:00 We can use that tol call .beginUpdates
        tableView.beginUpdates()
    }
    
    // 03:06 And there is a matching controllerDidChangeContent method that we'll use to call .endUpdates() on the tableView. And that's it. We now have a reactive table view that automatically responds to inserts and deletes. Let's try it out. Run the app in the simulator again and let's try adding a new notebook. I'll call this one Ideas. Great, it appears in the list with that smooth fade animation, and removing a notebook works too. This is pretty great. We have made our UI reactive while reducing the amount of code in our app. We removed the code that explicitly maintained a notebooks array and replaced it with the fetchedResultsController that now serves as the tableView's data source. We implemented the fetchResultsController's delegate methods to update the tableView when the data changes. Next, let's a quick look at how we could expand this code to support additional change types like update and move.
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    // 00:46 The most important method for us is controller(didChange:at:newIndexPath:), it's a little hard to find it but this is the comment you are looking for: "Notifies the receiver that a fetched object has been changed due to an add, remove, move, or update. And here it is. It is called whenever the fetch results controller receives the notification that an object has been added, deleted, or changed. When any of those events happen, the table view should update the affected rows.
    // 01:20 The type of event is reflected in the 'for type' parameter. NSFetchedResultsChangeType is an enum that can be an insert, delete, update, or remove. In Mooskine, notebooks can only be added or deleted, so we only need to implement insert and delete.
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        // 01:39 We'll switch on the type parameter, and I'll put some break statements in her etemporarily to silence errors while we're working.
        // 01:48 In the insert case, the newIndexPath parameter contains the IndexPath of the row to insert. So we can call the tableView's insertRows method passing the newIdexPath in and tellin it to face the insertion animation. Now, newIndexPath is optional so we have to unwrap it (i.e. have to write ! after newIndexPath), and insertRows accepts an array of rows so we'll make this a single element array (i.e. put newIndexPath! in [...] brackets). OK thats insert.
        // 02:20 In the delete case, the indexPath parameter contains the indexPath of the row to delete. So we'll call tableView.deleteRows with that indexPath. Again, force unwrapping the indexPath and embedding it in array and specifying a fade animation. So that's delete.
        // 02:44 Now, both of these table view changes need to be bookended between begin updates and end updates calls. Our fetchedResultsController has delegtate methods that we can use for this. So let's add those now.
        // 02:53 The controllerWillChangeContent method will get caled before a batch of updates (write that func above func controller above ...). We can use that tol call ... move there to continue ...
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            default:
                break
        }
    }
}
