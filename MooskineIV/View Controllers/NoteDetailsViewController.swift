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

    // based on 11. Preparing the keyboard - Then, back in the main class, replace viewDidLoad (previous viewDidLoad and its content commented out below) with the following:
    //The accessory view used when displaying the keyboard
        var keyboardToolbar: UIToolbar?

        override func viewDidLoad() {
            super.viewDidLoad()

            if let creationDate = note.creationDate {
                navigationItem.title = dateFormatter.string(from: creationDate)
            }
            textView.attributedText = note.attributedText

            // keyboard toolbar configuration
            configureToolbarItems()
            configureTextViewInputAccessoryView()
        }
    /*
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let creationDate = note.creationDate {
            navigationItem.title = dateFormatter.string(from: creationDate) 
        }
        
        // 00:45 Then in viewDidLoad(), since we know that the note has been passed in, we can set the textView to show the note's contents. Whenever the user finishes editing the text in the text view, we need to save the changes back into the note.
        // 01:00 Changes in the text field trigge3r a UITextViewDelegate method, textViewDidEndEditing ...move there, it is last method in this file...
        
        // textView.text = note.text
        textView.attributedText = note.attributedText
    }
     */

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
        // note.text = textView.text
        note.attributedText = textView.attributedText
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

// as per lesson 11. Preparing the keyboard
// MARK: - Toolbar

extension NoteDetailsViewController {
    /// Returns an array of toolbar items. Used to configure the view controller's
    /// `toolbarItems' property, and to configure an accessory view for the
    /// text view's keyboard that also displays these items.
    func makeToolbarItems() -> [UIBarButtonItem] {
        let trash = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteTapped(sender:)))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        // MARK: 13. Adding Text Formatting
        // 00:31 We'll want to use the UIBarButtonItem initializer that lets us pass in an image. I'll type image literal to get the picker that allows me to choose an asset from the library. Set this style to plain, target to self, and action to a function that we'll write in a moment, boldTapped. I'll copy and paste this twice. Then, rename these to Red and Cow. And double click the image literals to choose the appropriate icons. And I'll set the selectors to redTapped and cowTapped. We'll impolement these action functions next. But before we do, let's finish here by updating the list of buttons this function returns.
        // 01:21 Okay, now to implement those actions. Let's copy and paste deleteTapped to create boldTapped, redTapped and cowTapped. ...move down there...
        let bold = UIBarButtonItem(image: #imageLiteral(resourceName: "toolbar-bold"), style: .plain, target: self, action: #selector(boldTapped(sender:)))
        let red = UIBarButtonItem(image: #imageLiteral(resourceName: "toolbar-underline"), style: .plain, target: self, action: #selector(redTapped(sender:)))
        let cow = UIBarButtonItem(image: #imageLiteral(resourceName: "toolbar-cow"), style: .plain, target: self, action: #selector(cowTapped(sender:)))

        return [trash, space, bold, red, cow]
    }

    /// Configure the current toolbar
    func configureToolbarItems() {
        toolbarItems = makeToolbarItems()
        navigationController?.setToolbarHidden(false, animated: false)
        }

    /// Configure the text view's input accessory view -- this is the view that
    /// appears above the keyboard. We'll return a toolbar populated with our
    /// view controller's toolbar items, so that the toolbar functionality isn't
    /// hidden when the keyboard appears
    func configureTextViewInputAccessoryView() {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 44))
        toolbar.items = makeToolbarItems()
        textView.inputAccessoryView = toolbar
    }

    @IBAction func deleteTapped(sender: Any) {
        showDeleteAlert()
    }
    
    // 01:30 Remove the line of code inside each so that the're empty. and let's start with the bold action
    @IBAction func boldTapped(sender: Any) {
        // 01:38 We'll make a variable to hold the new text. By taking the textViews attributed text and making a mutableCopy with a forced downcast.
        let newText = textView.attributedText.mutableCopy() as! NSMutableAttributedString
        // 01:46 Then, we'll aply a bold attribute to the text using NSMutableAttributed strings addAttribute method passing font as the name, a bold font as the value and the currently selected range from the textView. Now it really would be better to have color and font preferences across the project reside in a struct or enum. But for now, I am going to leave it hardcoded and carry on.
        newText.addAttribute(.font, value: UIFont(name: "OpenSans-Bold", size: 22)!, range: textView.selectedRange)
        // 02:17 Okay, we're almost ready to replace the text fused text with the formatted text. We just need to make a copy of the currently selected text range so that we can restore the selection after replacing the text. NOtice that this timer grabbing the UITextRange (option click on it to see its UI) version instead of the NSRange version (option click on .selectedRange above to see its NSRange).
        let selectedTextRange = textView.selectedTextRange
        // 02:41 And now finally, we can update the textView with the new text.
        textView.attributedText = newText
        // 02:43 Set the selected range to what it was.
        textView.selectedTextRange = selectedTextRange
        // 02:46 Update the notes attributed text property
        note.attributedText = textView.attributedText
        // 02:51 and try saving the change to the persistence store
        try? dataController.viewContext.save()
    }
    
    // 02:55 Let's do the same for the redTapped method. This method will be almost identical to boldTapped.
    @IBAction func redTapped(sender: Any) {
        let newText = textView.attributedText.mutableCopy() as! NSMutableAttributedString
        // 03:00 We'll just set different attributes. Let's making this really stand out by making it red and underlined. Since we have more than one attribute, let's delete the code section below:
        // newText.addAttribute(.font, value: UIFont(name: "OpenSans-Bold", size: 22)!, range: textView.selectedRange)
        // 03:15 and create an attributes dictionary so that we can set multiple attributes at once. We'll set foregroundColor to red, underlineStyle to one and underlineColor to red.
        let attributes:[NSAttributedString.Key: Any] = [.foregroundColor: UIColor.red,
            .underlineStyle: 1,
            .underlineColor: UIColor.red
        ]
        // 03:33 Then, we'll call addAttributesPlural passing our attributes array and the selected range.
        newText.addAttributes(attributes, range: textView.selectedRange)
        // 03:39 The rest will be identical to the bold action. We'll update the text and selection and core data. Note that in a real app, we'd probably want to refactor thesae methods to simplify them and remove duplication.
        let selectedTextRange = textView.selectedTextRange
        textView.attributedText = newText
        textView.selectedTextRange = selectedTextRange
        note.attributedText = textView.attributedText
        try? dataController.viewContext.save()
    }
    
    // 03:54 Finally let's implement our cowText feature. We can start by copy pasting the functionality from redTapped.
    @IBAction func cowTapped(sender: Any) {
        let newText = textView.attributedText.mutableCopy() as! NSMutableAttributedString
        // 04:03 Now, we're actually not going to set the attributes this way, so let's delete these two lines:
        /*
        let attributes:[NSAttributedString.Key: Any] = [.foregroundColor: UIColor.red,
            .underlineStyle: 1,
            .underlineColor: UIColor.red
        ]
        
        newText.addAttributes(attributes, range: textView.selectedRange)
         */
        
        // 04:07 Instead, we're going to hand over the work to the Pathifier struct. So, we'll get the selected range.
        let selectedRange = textView.selectedRange
        // 04:17 And use it to get he selected text.
        let selectedText = textView.attributedText.attributedSubstring(from: selectedRange)
        // 04:25 Once we have that, we can create the cowText by calling Pathifier.makeMutableAttribvutedString. ANd passing in the selected text, the font and the pattern image.
        let cowText = Pathifier.makeMutableAttributedString(for: selectedText, withFont: UIFont(name: "AvenirNext-Heavy", size: 56)!, withPatternImage: #imageLiteral(resourceName: "texture-cow"))
        // 04:49 With the result we get back, we'll want to replace the relevant selection in the original text and update the textView and note.
        newText.replaceCharacters(in: selectedRange, with: cowText)
        // 04:59 Since we converted the text to an image, we won't use selectedTextRange anymore (so comment out bolow two code lines)
        
        // let selectedTextRange = textView.selectedTextRange
        textView.attributedText = newText
        
        // textView.selectedTextRange = selectedTextRange
        // 05:09 Instead we'll set the selected range to start at the inserted image and have a lenght of 1.
        textView.selectedRange = NSMakeRange(selectedRange.location, 1)
        // 05:12 The rest looks good. We set the notes text to match what is showing in the textView and save the changes. Okay, let's try it out, run the app. Now in simulator, let's navigate down to a note. Try highlighteing some text and making it bold. Now let's try cowifying some text. Nice I think our users are going to love this. Now, let's navigate back to the list of notes in this notebook. Cool. Since we are using attributed Strings in the labels on this screen too, we immediatelly get richly formatted preview as well. The work we did to enable a rewactive user interface in th elast lesson is really paying off. Note that our are primitive implementations, we haven't added any way to remove formatting. Feel free to experinment with different attributes and create a few formatting buttons of your own. And when you are ready, come back here and we'll look into the performance implication of our code.
        note.attributedText = textView.attributedText
        try? dataController.viewContext.save()
    }

    // MARK: Helper methods for actions
    private func showDeleteAlert() {
        let alert = UIAlertController(title: "Delete Note?", message: "Are you sure you want to delete the current note?", preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.onDelete?()
        }

        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        present(alert, animated: true, completion: nil)
    }
}
