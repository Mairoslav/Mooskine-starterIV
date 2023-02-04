//
//  NotesListViewController.swift
//  Mooskine
//
//  Created by Josh Svatek on 2017-05-31.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit
// MARK:  13. Updating NotesListViewController
// MARK: NotesListViewController: Fetch + Predicate
// 00:00 How did it go updating 'NotesListViewController.swift'? Let's review the steps together. We'll start by importing CoreData (a).
import CoreData

class NotesListViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!

    var notebook: Notebook!
    
    var notes:[Note] = []
    
    // 00:12 And we'll need access to the CoreDataStack. So let's prepare this class to h ave the DataCotroller injected. Here at the to I'll add an implicitly unwrapped DataController property (b). ..now move to 'NotebooksListViewController.swift'...
    var dataController: DataController! 

    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = notebook.name
        navigationItem.rightBarButtonItem = editButtonItem
        
        // 00:50 Next step is to fetch all of the notes associated with this notebook. So head back to 'NotesListViewController.swift' and in viewDidLoad() we'll declare a fetchRequest typed to a Note, and we'll use the note class to create it (c).
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        // 01:09 Now, to configure it, we need to ensure it only fetches Notes from the selected notebook. For this filtering, we use a predicate. I'll create a predicate with the format notebook equals equals percent at, and notebook as the argument. The percent at will get replaced with the actual notebook at runtime. This is how we check whether a single note's notebook property is set to the current notebook (d).
        let predicate = NSPredicate(format: "notebook == %@", notebook)
        // 01:42 Now, we need to set the fetchRequest to use this predicate (e).
        fetchRequest.predicate = predicate
        // 01:47 Once we have all the ritht notes, we'll want to sort them. Create a SortDescriptor that sorts by creationDate ascending (f),
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        // 01:59 and we'll set the fetchRequest sortDescriptors array to use it (g).
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // 02:03 All ritht, our fetchRequest is ready to go. Time to ask the managed object contacts to perform the fetch (h.i).
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            // 02:11 If it's successful, we'll sotre those notes in this class's notes array (h.ii). ...Move to addNote()...
            notes = result
        }
        
        updateEditButtonState()
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
        addNote()
    }

    // -------------------------------------------------------------------------
    // MARK: - Editing

    func addNote() {
        // MARK: NotesListViewController: Update addNote()
        // 02:18 We also need to update the code for adding and deleting notes. We had commented those out earlier but now that we have a DataController, we can get them working again. Let's start with addNote. I'll remove TODO comment and now instead of creating a note on the notebook, we'll create a note registered to a context (a).
        let note = Note(context: dataController.viewContext)
        // 02:44 We'll set its text to "New note" (b),
        // note.text = "New note"
        // 02:50 Configure its creationDate (c),
        note.creationDate = Date()
        // 02:54 set its notebook (d)
        note.notebook = notebook
        // 02:57 and now, we can try to save it into the context (e).
        try? dataController.viewContext.save()
        // 03:06 We'll also add it at the front of this class's notes array (f),
        notes.insert(note, at: 0)
        // 03:09 and we'll want it to appear at the top of the table view. So change the row here to zero (g).
        tableView.insertRows(at: [IndexPath(row: /*numberOfNotes - 1*/ 0, section: 0)], with: .fade)
        updateEditButtonState()
    }

    func deleteNote(at indexPath: IndexPath) {
        // MARK: NotesListViewController: Update deleteNote()
        // 03:18 That covers adding a note. Now for deleting one. Again we can get rid of the TODO comnment. And instead of removing the note from the notebook, we'll get a reference to the note to delete (a),
        let noteToDelete = note(at: indexPath)
        // 03:33 delete it from the context (b),
        dataController.viewContext.delete(noteToDelete)
        // 03:37 and try to save the change (c).
        try? dataController.viewContext.save()
        // 03:41 Then finally, remove it from the notes array, and we are good to go (d).
        notes.remove(at: indexPath.row)
        
        tableView.deleteRows(at: [indexPath], with: .fade)
        if numberOfNotes == 0 {
            setEditing(false, animated: true)
        }
        updateEditButtonState()
    }

    func updateEditButtonState() {
        navigationItem.rightBarButtonItem?.isEnabled = numberOfNotes > 0
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
        return numberOfNotes
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aNote = note(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: NoteCell.defaultReuseIdentifier, for: indexPath) as! NoteCell

        cell.textPreviewLabel.text = aNote.text
        if let creationDate = aNote.creationDate {
            cell.dateLabel.text = dateFormatter.string(from: /*aNote.*/creationDate)
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete: deleteNote(at: indexPath)
        default: ()
        }
    }

    var numberOfNotes: Int { return notes.count }

    func note(at indexPath: IndexPath) -> Note {
        return notes[indexPath.row]
    }

    // -------------------------------------------------------------------------
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? NoteDetailsViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                // 02:29 We are already setting the note property,
                vc.note = note(at: indexPath)
                // 02:31 so we'll add another line passing along the data controller as well.
                vc.dataController = dataController
                // 02:36 And now, back in the 'NoteDetailsViewController' we can use the data controller's context now. In 'textViewDidEndEditing' ...move there...

                vc.onDelete = { [weak self] in
                    if let indexPath = self?.tableView.indexPathForSelectedRow {
                        self?.deleteNote(at: indexPath)
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
}
