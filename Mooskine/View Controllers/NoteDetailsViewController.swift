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
    var note: Note!

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
        
        // 00:47 In the viewDidLoad() we need to check if the note has a creation date before we can use it in the title. So I'll wrap this statement in an if let and change it to use the unwrapped creation date (see comment ****).

        // navigationItem.title = dateFormatter.string(from: ((note.creationDate ?? Date()) as NSObject) as! Date) // error corrected thanks to Xcode suggestion, it shall work, still below code is as per lesson and above comment from 00:47:
        if let creationDate = note.creationDate {
            navigationItem.title = dateFormatter.string(from: creationDate) // **** use the unwrapped creation date i.e. changed from note.creationDate to creationDate after .string(from: ...)
            // 01:04 you may need to Product/Build again for the issues list to register this fix
            // ok one (error) down, let's handle the other errors that have to do with optionals, move to line 125 of "NotebooksListViewController.swift" 01:52 ... 
        }
        
        
        
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
        note.text = textView.text
    }
}
