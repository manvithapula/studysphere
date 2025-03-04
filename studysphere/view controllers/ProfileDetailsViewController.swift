//
//  ProfileDetailsViewController.swift
//  studysphere
//
//  Created by dark on 02/11/24.
//

import UIKit
import FirebaseCore

class ProfileDetailsViewController: UIViewController {
    
    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var firstNameLabel: UILabel!
    @IBOutlet private weak var firstNameValueLabel: UILabel!
    @IBOutlet private weak var lastNameLabel: UILabel!
    @IBOutlet private weak var lastNameValueLabel: UILabel!
    @IBOutlet private weak var dateOfBirthLabel: UILabel!
    @IBOutlet private weak var dateOfBirthValueLabel: UILabel!
    
    //text field
    private lazy var firstNameTextField: UITextField = createTextField(withText: firstNameValueLabel.text)
    private lazy var lastNameTextField: UITextField = createTextField(withText: lastNameValueLabel.text)
    private lazy var dateTextField: UITextField = createTextField(withText: dateOfBirthValueLabel.text)
    
    //properties
    private var isEditMode = false
    private let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDatePicker()
    }
    
    private func setupUI() {
        // Navigation setup
        title = "My Details"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTapped))
        
        // Profile image setup
        profileImageView.contentMode = .scaleAspectFit
        profileImageView.layer.cornerRadius = 50
        profileImageView.clipsToBounds = true
       
        
        // Add tap gesture to profile image
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImageView.addGestureRecognizer(tapGesture)
        profileImageView.isUserInteractionEnabled = true
        
        // Container view setup
        containerView.backgroundColor = .systemGray6
        containerView.layer.cornerRadius = 10
        
        // Labels setup
        setupLabels()
        
        [lastNameTextField, dateTextField,firstNameTextField].forEach { textField in
            textField.textColor = .gray
        }
        
        loadImageFromUserDefaults()
    }
    
    private func setupLabels() {
        // Setup title labels
        [firstNameLabel, lastNameLabel, dateOfBirthLabel].forEach { label in
            label?.font = .systemFont(ofSize: 17)
            label?.textColor = .black
        }
        
        // Setup value labels
        [firstNameValueLabel, lastNameValueLabel, dateOfBirthValueLabel].forEach { label in
            label?.font = .systemFont(ofSize: 17)
            label?.textColor = .black
            label?.textAlignment = .right
        }
        
        // Set label texts
        firstNameLabel.text = "First Name"
        lastNameLabel.text = "Last Name"
        dateOfBirthLabel.text = "Date of Birth"
        firstNameValueLabel.text = user.firstName
        lastNameValueLabel.text = user.lastName
        dateOfBirthValueLabel.text = formatDateToString(date: user.dob.dateValue())
        
        firstNameTextField.text = user.firstName
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        dateOfBirthValueLabel.text = dateFormatter.string(from: user.dob.dateValue())
    }
    
    private func createTextField(withText text: String?) -> UITextField {
        let textField = UITextField()
        textField.text = text
        textField.textAlignment = .right
        textField.font = .systemFont(ofSize: 17)
        textField.borderStyle = .none
        return textField
    }
    
    private func setupDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        dateTextField.inputView = datePicker
        
       //done button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(datePickerDonePressed))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [flexSpace, doneButton]
        dateTextField.inputAccessoryView = toolbar
        
        // Set initial date
        if let dateString = dateOfBirthValueLabel.text {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMMM yyyy"
            if let date = dateFormatter.date(from: dateString) {
                datePicker.date = date
            }
        }
    }
    
    //model handling
    private func toggleEditMode() {
        isEditMode.toggle()
        
        // Update navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: isEditMode ? "Done" : "Edit",
            style: .done,
            target: self,
            action: #selector(editTapped)
        )
        
        if isEditMode {
            // Switch to text fields
            firstNameValueLabel.superview?.addSubview(firstNameTextField)
            lastNameValueLabel.superview?.addSubview(lastNameTextField)
            dateOfBirthValueLabel.superview?.addSubview(dateTextField)
            
            // Setup text field frames
            firstNameTextField.frame = firstNameValueLabel.frame
            lastNameTextField.frame = lastNameValueLabel.frame
            dateTextField.frame = dateOfBirthValueLabel.frame
            
            // Hide labels
            firstNameValueLabel.isHidden = true
            lastNameValueLabel.isHidden = true
            dateOfBirthValueLabel.isHidden = true
        } else {
            // Save changes
            saveChanges()
            
            // Remove text fields
            firstNameTextField.removeFromSuperview()
            lastNameTextField.removeFromSuperview()
            dateTextField.removeFromSuperview()
            
            // Show labels
            firstNameValueLabel.isHidden = false
            lastNameValueLabel.isHidden = false
            dateOfBirthValueLabel.isHidden = false
        }
    }
    
    private func saveChanges() {
        // Update labels with text field values
        firstNameValueLabel.text = firstNameTextField.text
        lastNameValueLabel.text = lastNameTextField.text
        dateOfBirthValueLabel.text = dateTextField.text
        
        if let firstname = firstNameTextField.text, !firstname.isEmpty {
            user.firstName = firstname
        }
        if let lastname = lastNameTextField.text, !lastname.isEmpty {
            user.lastName = lastname
        }
        AuthManager.shared.updateName(firstName: user.firstName, lastName: user.lastName)
        user.dob = Timestamp(date:datePicker.date)
        Task{
            try await userDB.update(&user)
        }
        
        // Here you would typically save to your data source
        // saveToDataSource()
    }
    
    //Actions
    @objc private func editTapped() {
        toggleEditMode()
    }
    
    @objc private func datePickerDonePressed() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        dateTextField.text = dateFormatter.string(from: datePicker.date)
        dateTextField.resignFirstResponder()
    }
    
    @objc private func profileImageTapped() {
        guard isEditMode else { return }
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true)
    }
}

//UIImagePickerControllerDelegate
extension ProfileDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImage: UIImage?
                
                if let editedImage = info[.editedImage] as? UIImage {
                    selectedImage = editedImage
                } else if let originalImage = info[.originalImage] as? UIImage {
                    selectedImage = originalImage
                }
                
                if let image = selectedImage {
                    // Display the image
                    profileImageView.image = image
                    
                    // Save the image to UserDefaults
                    saveImageToUserDefaults(image)
                }
                
                

        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    private func saveImageToUserDefaults(_ image: UIImage) {
            // Convert image to data
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                UserDefaults.standard.set(imageData, forKey: "profileImage")
            }
        }
        
        // Load image from UserDefaults
        private func loadImageFromUserDefaults() {
            if let imageData = UserDefaults.standard.data(forKey: "profileImage"),
               let image = UIImage(data: imageData) {
                profileImageView.image = image
            }
        }
}
