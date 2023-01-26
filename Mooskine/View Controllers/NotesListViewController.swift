//
//  NotesListViewController.swift
//  Mooskine
//
//  Created by Josh Svatek on 2017-05-31.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit

class NotesListViewController: UIViewController, UITableViewDataSource {
    /// A table view that displays a list of notes for a notebook
    @IBOutlet weak var tableView: UITableView!

    /// The notebook whose notes are being displayed
    var notebook: Notebook!
    
    var notes:[Note] = [] // new based on comments in lines 110 ...

    /// A date formatter for date text in note cells
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = notebook.name
        navigationItem.rightBarButtonItem = editButtonItem
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

    // Adds a new `Note` to the end of the `notebook`'s `notes` array
    // 03:23 The last two errors are about missing functions for adding and and removing notes from a notebook (see "NotesListViewController.swift" line 55)... yeah we are here ... Our code-generated class does not include these functions yet. We'll add them very soon. For now we just comment these out and make them as to-do for later.
    // 03:44 Product/Build again and we are back in the business, no more compile-time errors means we can run the app again. That's important because we are about to fetch data from the store and we'll need to be able to test whether it worked. Not this is end of 5. Switching to Code-Generated Classes and we start 6. Injecting the DataController Dependency
    func addNote() {
        // notebook.addNote() // TODO: .addNote()
        tableView.insertRows(at: [IndexPath(row: numberOfNotes - 1, section: 0)], with: .fade)
        updateEditButtonState()
    }

    // Deletes the `Note` at the specified index path
    func deleteNote(at indexPath: IndexPath) {
        // notebook.removeNote(at: indexPath.row) // TODO: .removeNote
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

        // Configure cell
        cell.textPreviewLabel.text = aNote.text
        // 02:45 It looks like we can handle this one the same way we handled creationDate before using if let:
        if let creationDate = aNote.creationDate {
            cell.dateLabel.text = dateFormatter.string(from: /*aNote.*/creationDate)
        }
        // now that we have corrected all the errors related to the otpionals let move on to the "NotebooksListViewController.swift" line 81 
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete: deleteNote(at: indexPath)
        default: () // Unsupported
        }
    }

    // Helpers
    // 01:52 both numberOfNotes and noteAtIndexpatch func right here, we are having trouble with the notes, since Core Data uses a set instead of an array. We cannot really wrap this in a if let because we need to return a notes.count. So let's worry about this later.
    // 02:15 At top of the file we'll make an empty notes array that we can fill in (see line 18 at the top of this file, line "var notes:[Note] = []). And then back down in numberOfNotes below we can use the notes.count from Notes array
    var numberOfNotes: Int { return /*notebook.*/notes.count }

    func note(at indexPath: IndexPath) -> Note {
        // 02:28 and set note at indexPath to use that array also:
        return /*notebook.*/notes[indexPath.row]
        // 02:35 We are on the roll, there is one more optional error. Let's move to line 97 ...
        // Since the notes as an NSSet cannot be indexed, comment out above line and you can take the `allObjects` like this (adviced by Q&A Udacity Mentor) for now commented out:
        // return notebook.notes?.allObjects[indexPath.row] as! Note
    }
    
    // let orderedPlayers = (game.players!.allObjects as! [Player]).sort { $0.name < $1.name }

    // -------------------------------------------------------------------------
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If this is a NoteDetailsViewController, we'll configure its `Note`
        // and its delete action
        if let vc = segue.destination as? NoteDetailsViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                vc.note = note(at: indexPath)

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
