//
//  addSubjectViewController.swift
//  studysphere
//
//  Created by admin64 on 14/11/24.
//

import UIKit

class AddSubjectViewController: UIViewController {

    // Closure to send the new subject back to the table view controller
    var onSubjectAdded: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }

    private func setupUI() {
        // Set up a text field and a save button (example setup)
        let textField = UITextField(frame: CGRect(x: 20, y: 100, width: view.frame.width - 40, height: 40))
        textField.borderStyle = .roundedRect
        textField.placeholder = "Enter subject name"
        view.addSubview(textField)

        let saveButton = UIButton(type: .system)
        saveButton.setTitle("Save", for: .normal)
        saveButton.frame = CGRect(x: 20, y: 160, width: view.frame.width - 40, height: 40)
        saveButton.addTarget(self, action: #selector(saveSubject), for: .touchUpInside)
        view.addSubview(saveButton)

        // Store the text field in a property for later use
        self.subjectNameTextField = textField
    }

    // A property to store the subject name text field
    private var subjectNameTextField: UITextField?

    // Function to handle saving the subject
    @objc func saveSubject() {
        guard let subjectName = subjectNameTextField?.text,
              !subjectName.isEmpty else {
            return // Exit if there's no valid subject name
        }
        
        // Call the closure to pass the new subject back
        onSubjectAdded?(subjectName)
        
        // Dismiss the modal
        dismiss(animated: true, completion: nil)
    }
}


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
