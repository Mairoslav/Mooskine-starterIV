//
//  NotesListViewController.swift
//  Mooskine
//
//  Created by Josh Svatek on 2017-05-31.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit

// MARK: 14. Practice: NotesListViewController
// apllying this exercise in 'MooskineIV.xcodeproj' where we delete previous comments so we create space for below changes and comments:

import CoreData

class NotesListViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!

    var notebook: Notebook!
    
    //  3.a. delete the notes property
    // var notes:[Note] = []
    
    var dataController: DataController!
    
    // 1.a. add an implicitly unwrapped 'fetchedResultsController' variable
    var fetchedResultsController: NSFetchedResultsController<Note>! // NSFetchedResultsController is typed to return Note instead of Notebook object
    
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()

    // 2.a. extract all fetch request-related code form viewDidLoad into a setupFetchedResultsController() function
    // 2.b. observe that the existing fetch request uses a predicate to fetch only notes for the current notebook, and is sorted
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        let predicate = NSPredicate(format: "notebook == %@", notebook)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        /*
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            notes = result
        }
        */
        // 2.c. instantiate the fetchedResultscontroller, passing in the fetch request, view content, a nil keypath, and a cache name that will vary based on the notebook (use string interpolatioin to include the notebook name somewhere in the cache name).
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(String(describing: notebook))-notes")
        // 2.d. on the next line, set the fetchedResultsConroller's delegate to self.
        fetchedResultsController.delegate = self
        //  2.e. instead of calling fetch on the viewContext, replace this block with a do-catch block calling performFetch on the fetchedResultsController
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
            
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = notebook.name
        navigationItem.rightBarButtonItem = editButtonItem
        
        setupFetchedResultsController()
        
        updateEditButtonState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //  3.c. viewWillAppear: update to call setupFetchedResultsController right after the super call
        setupFetchedResultsController()
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
    
    //  3.d. viewDidDisappear: add viewDidDisappear and set FRC to nil after the super call
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }

    // -------------------------------------------------------------------------
    // MARK: - Actions

    @IBAction func addTapped(sender: Any) {
        addNote()
    }

    // -------------------------------------------------------------------------
    // MARK: - Editing
    // 3.e. addNote: remove the lines inserting the note into the notes array, inserting the note into the tableview an updating the edit button state
    func addNote() {
        let note = Note(context: dataController.viewContext)
        // note.text = "New note"
        note.attributedText = NSAttributedString(string: "New note")
        note.creationDate = Date()
        note.notebook = notebook
        try? dataController.viewContext.save()
        /*
        notes.insert(note, at: 0)
        tableView.insertRows(at: [IndexPath(row: /*numbertes - 1*/ 0, section: 0)], with: .fade)
        updateEditButtonState()
         */
    }

    // 3.f. deleteNote: change the first line to get the note at the indexPath from the fetchedResultsController.
    // 3.g. deleteNote: remove the second half of the function - everything from removing the note from the notes array, through updating the edit button state.
    func deleteNote(at indexPath: IndexPath) {
        let noteToDelete = fetchedResultsController.object(at: indexPath) /*note(at: indexPath)*/
        dataController.viewContext.delete(noteToDelete)
        try? dataController.viewContext.save()
        /*
        notes.remove(at: indexPath.row)
        
        tableView.deleteRows(at: [indexPath], with: .fade)
        if numberOfNotes == 0 {
            setEditing(false, animated: true)
        }
        updateEditButtonState()
         */
    }

    // 3.b. updateEditButtonState: change to check whether the fetchedResultsController's number of objects in the zeroeth section is nonzero
    func updateEditButtonState() {
        navigationItem.rightBarButtonItem?.isEnabled = /*numberOfNotes > 0*/ fetchedResultsController.sections![0].numberOfObjects > 0
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }

    // -------------------------------------------------------------------------
    // MARK: - Table view data source

    // 3.i. numberOfSections: return the fetchedResultsControler's section count, otherwise one
    func numberOfSections(in tableView: UITableView) -> Int {
        // return 1
        return fetchedResultsController.sections?.count ?? 1 // this done ...CONTINUE HERE...
    }

    // 3.j. tableView(_:numberOfRowsInSection): return the correct nubmer of objects from a given section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return numberOfNotes
        return fetchedResultsController.sections?[0].numberOfObjects ?? 0
    }

    //  3.k. tableView(_:cellForRowAt:): update first line to get the note from the fetchedResultsController.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // let aNote = note(at: indexPath)
        let aNote = fetchedResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: NoteCell.defaultReuseIdentifier, for: indexPath) as! NoteCell

        // cell.textPreviewLabel.text = aNote.text
        cell.textPreviewLabel.attributedText = aNote.attributedText
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
    // 3.h. remove the numberOfNotes and note(at indexPath) helpers.
    /*
    var numberOfNotes: Int { return notes.count }

    func note(at indexPath: IndexPath) -> Note {
        return notes[indexPath.row]
    }
     */
    
    // -------------------------------------------------------------------------
    // MARK: - Navigation

    //  3.l. prepare(for:sender:): update the line setting vc.note to get the note from the fetchedResultsController.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? NoteDetailsViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                // vc.note = note(at: indexPath)
                vc.note = fetchedResultsController.object(at: indexPath)
                vc.dataController = dataController

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

// 1.b. add a class extension to house the 'NSFetchedResultsControllerDelegate' functionality
extension NotesListViewController: NSFetchedResultsControllerDelegate {
    
    // 4.a. implement controller(_:didChange:atSectionIndex:for:)
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
            case .insert:
                tableView.insertSections(indexSet, with: .fade)
            case .delete:
                tableView.deleteSections(indexSet, with: .fade)
            case .update, .move:
                fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
            default:
                break
        }
    }
    
    // 4.b. implement controller(_:didChange:at:for:newIndexPath:)
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                tableView.reloadRows(at: [indexPath!], with: .fade)
            case .move:
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
            default:
                break
        }
    }
    
    //  4.c. implement controllerWillChangeContent(_:)
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    
    // 4.d. implement controllerDidChangeCntent(_:)
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
