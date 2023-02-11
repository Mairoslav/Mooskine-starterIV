//
//  NoteDetailsViewController.swift
//  Mooskine
//
//  Created by Josh Svatek on 2017-05-31.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit

class NoteDetailsViewController: UIViewController {
    /// A text view that displays a note's text
    @IBOutlet weak var textView: UITextView!

    /// The note being displayed and edited
    // MARK: 16. Saving Edits in NoteDetailsViewController
    // 00:37 NoteDetailsViewController has a "var note: Note!" property that is injected before the view is displayed. 00:45 Then in viewDidLoad() ...
    var note: Note!
    
    // 02:08 Let's head back to the top and add a dataController property. And as always, we'll make it an implicitly unwrapped optional because we always expect it to be injected before this view controller is displayed.
    var dataController: DataController!
    // 02:18 We'll have the previous view, pass it to us during the segue. So let's head over to 'NotesListViewController' and jump to 'prepareForSender' ...move there...

    /// A closure that is run when the user asks to delete the current note
    var onDelete: (() -> Void)?

    /// A date formatter for the view controller's title text
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let creationDate = note.creationDate {
            navigationItem.title = dateFormatter.string(from: creationDate) 
        }
        
        // 00:45 Then in viewDidLoad(), since we know that the note has been passed in, we can set the textView to show the note's contents. Whenever the user finishes editing the text in the text view, we need to save the changes back into the note.
        // 01:00 Changes in the text field trigge3r a UITextViewDelegate method, textViewDidEndEditing ...move there, it is last method in this file...
        
        textView.text = note.text
    }

    @IBAction func deleteNote(sender: Any) {
        presentDeleteNotebookAlert()
    }
}

// -----------------------------------------------------------------------------
// MARK: - Editing

extension NoteDetailsViewController {
    func presentDeleteNotebookAlert() {
        let alert = UIAlertController(title: "Delete Note", message: "Do you want to delete this note?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: deleteHandler))
        present(alert, animated: true, completion: nil)
    }

    func deleteHandler(alertAction: UIAlertAction) {
        onDelete?()
    }
}

// -----------------------------------------------------------------------------
// MARK: - UITextViewDelegate

extension NoteDetailsViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        // 01:00 Changes in the text field trigger a UITextViewDelegate method, textViewDidEndEditing. Here, we update the note with the edited text.
        note.text = textView.text
        // 01:12 Okay so let's get clear on what we need to fix. We do not need to change anything about how we get the notes text into the text view unload above, but we need to persist any changes the user makes to the note here by saving the context.
        // 01:30 To do this, we'll need a reference to the notes managed object context. Now, we haven't injected a data controller into this class and we usually ask the data controller for its view context. But I want to show you that we can actually just ask the note for its context.
        // 01:47 Managed Objects like our note hold a reference to their associated context. So we'll try saving the context to persist the app's unsaved changes.
        // try? note.managedObjectContext?.save()
        // 01:55 And actually, that's it. It only took one line of code to update this class, but while we are here let's set it up with a reference to the data controller for future use.
        // 02:08 Let's head back to the top and add a dataController property. And as always, we'll make it an implicitly unwrapped optional because we always expect it to be injected before this view controller is displayed.
        
        // 02:36 (jumping back here from 'NotesListViewController') And now, back in the 'NoteDetailsViewController' we can use the data controller's context now. In 'textViewDidEndEditing' we can rewrite the save() this way (above 'try? note.managedObjectContext?.save()' commented out):
        try? dataController.viewContext.save()
        // 02:47 It happens to be equivalent right now because this notes context is the view context. But we're settin this project up to support working with multiple contexts later. Our work here is done, but before we move on, a quick question for you. If we hadn't added this line, will the changes to note have been saved in the persistent store? The answer is, it depends.
        // 03:14 This is not the only place in the code that we call save on the context. Any changes to the note would be saved the next time the context was saved.
            // a) So if the user kept using the app and triggered a save by adding or deleting a note or notebook on either the other two view controllers, our change would have been saved.
            // b) But if the user had immediately terminated the app, the change would have been lost. This obviously would end up being pretty confusing for the user.
        
        // 03:42 The question  of when to save is worth discussing in its own right, so let's take a look at that next, in next lesson called '17. When Should You Save?'...
    }
}
