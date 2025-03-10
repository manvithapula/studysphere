//
//  SignupViewController.swift
//  studysphere
//
//  Created by admin64 on 12/11/24.
//

import UIKit
import FirebaseCore

class SignupViewController: UIViewController {


    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var dateOfBirthTextField: UITextField!
    @IBOutlet weak var googleSignInButton: UIButton!
    @IBOutlet weak var appleSignInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
   
        
        private let datePicker = UIDatePicker()
        
        private let scrollView: UIScrollView = {
            let scrollView = UIScrollView()
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            return scrollView
        }()
        
        private let contentView: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        private let stackView: UIStackView = {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.spacing = 24
            stack.alignment = .center
            stack.translatesAutoresizingMaskIntoConstraints = false
            return stack
        }()
        
        private let logoImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.backgroundColor = UIColor(red: 30/255, green: 41/255, blue: 59/255, alpha: 1)
            imageView.layer.cornerRadius = 40
            imageView.clipsToBounds = true
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.layer.shadowColor = UIColor(red: 37/255, green: 99/255, blue: 235/255, alpha: 0.3).cgColor
            imageView.layer.shadowOffset = CGSize(width: 0, height: 4)
            imageView.layer.shadowOpacity = 1
            imageView.layer.shadowRadius = 20
            return imageView
        }()
        
        private let titleLabel: UILabel = {
            let label = UILabel()
            label.text = "Create Account"
            label.font = .systemFont(ofSize: 28, weight: .bold)
            label.textColor = .black
            label.textAlignment = .center
            return label
        }()
        
        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            setupConstraints()
            setupDatePicker()
            setupTapGesture()
        }
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
        
        // MARK: - UI Setup
            
            private func setupUI() {
                view.backgroundColor = .systemGray6
                
                // Setup scroll view hierarchy
//                view.addSubview(scrollView)
//                scrollView.addSubview(contentView)
//                contentView.addSubview(stackView)
//                
//                // Add logo and title to stack view
//                stackView.addArrangedSubview(logoImageView)
//                stackView.addArrangedSubview(titleLabel)
                
                // Configure and add text fields to stack view
                [firstNameTextField, lastNameTextField, emailTextField,
                 passwordTextField, dateOfBirthTextField].forEach { textField in
                    textField?.backgroundColor = .systemGray6
                    textField?.layer.cornerRadius = 12
                    textField?.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
                    textField?.leftViewMode = .always
                    textField?.font = .systemFont(ofSize: 16)
                    // Add text fields to stack view
//                    if let field = textField {
//                        stackView.addArrangedSubview(field)
//                    }
                }
//                contentView.addSubview(signUpButton)
                // Configure sign up button
                signUpButton.isUserInteractionEnabled = true
                signUpButton.backgroundColor = AppTheme.primary
                signUpButton.setTitleColor(.white, for: .normal)
                signUpButton.layer.cornerRadius = 12
                signUpButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)

            
            // Hide unused buttons
            googleSignInButton.isHidden = true
            appleSignInButton.isHidden = true
        }
        
        private func setupDatePicker() {
            datePicker.datePickerMode = .date
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
            dateOfBirthTextField.inputView = datePicker
            
            // Add toolbar with Done button
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            let doneButton = UIBarButtonItem(title: "Done", style: .done,
                                             target: self, action: #selector(doneButtonTapped))
            toolbar.setItems([UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                             doneButton], animated: true)
            dateOfBirthTextField.inputAccessoryView = toolbar
        }
        
        private func setupConstraints() {
            NSLayoutConstraint.activate([
                // Scroll view
//                scrollView.topAnchor.constraint(equalTo: view.topAnchor),
//                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//                scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//                
//                // Content view
//                contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
//                contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
//                contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
//                contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
//                contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
//                contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
//                
//                // Stack view
//                stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//                stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
//                stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
                
                // Text field heights
                firstNameTextField.heightAnchor.constraint(equalToConstant: 50),
                lastNameTextField.heightAnchor.constraint(equalToConstant: 50),
                emailTextField.heightAnchor.constraint(equalToConstant: 50),
                passwordTextField.heightAnchor.constraint(equalToConstant: 50),
                dateOfBirthTextField.heightAnchor.constraint(equalToConstant: 50),
                
                // Button height
                signUpButton.heightAnchor.constraint(equalToConstant: 50),
                
                // Full width constraints
            ])
        }
        
        // MARK: - Actions
        @objc private func dateChanged(_ sender: UIDatePicker) {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            dateOfBirthTextField.text = formatter.string(from: sender.date)
        }
        
        @objc private func doneButtonTapped() {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            dateOfBirthTextField.text = formatter.string(from: datePicker.date)
            dateOfBirthTextField.resignFirstResponder()
        }
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let firstName = firstNameTextField.text, !firstName.isEmpty,
              let lastName = lastNameTextField.text, !lastName.isEmpty,
              let dateOfBirth = dateOfBirthTextField.text, !dateOfBirth.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "Please fill out all fields.")
            return
        }
        
        var newUser = UserDetailsType(id: "",
                                    firstName: firstName,
                                    lastName: lastName,
                                    dob: Timestamp(date: datePicker.date),
                                    pushNotificationEnabled: false,
                                    faceIdEnabled: false,
                                    email: email,
                                    password: password,
                                    createdAt: Timestamp(),
                                    updatedAt: Timestamp())
        
        if let existingUser = userDB.findFirst(where: ["email": email]) {
            showAlert(message: "User with email \(email) already exists.")
            return
        }
        
        let db = FirestoreManager.shared.db
        let createdUser = userDB.create(&newUser)
        
        do {
            try db.collection("usertemp").document(createdUser.id).setData(createdUser.asDictionary())
            dismiss(animated: true)
        } catch {
            showAlert(message: "Error creating user: \(error.localizedDescription)")
        }
    }
    @objc private func signUp(){
        print("tapped")
        guard let email = emailTextField.text, !email.isEmpty,
              let firstName = firstNameTextField.text, !firstName.isEmpty,
              let lastName = lastNameTextField.text, !lastName.isEmpty,
              let dateOfBirth = dateOfBirthTextField.text, !dateOfBirth.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "Please fill out all fields.")
            return
        }
        
        var newUser = UserDetailsType(id: "",
                                    firstName: firstName,
                                    lastName: lastName,
                                    dob: Timestamp(date: datePicker.date),
                                    pushNotificationEnabled: false,
                                    faceIdEnabled: false,
                                    email: email,
                                    password: password,
                                    createdAt: Timestamp(),
                                    updatedAt: Timestamp())
        
        if let existingUser = userDB.findFirst(where: ["email": email]) {
            showAlert(message: "User with email \(email) already exists.")
            return
        }
        
        let db = FirestoreManager.shared.db
        let createdUser = userDB.create(&newUser)
        
        do {
            try db.collection("usertemp").document(createdUser.id).setData(createdUser.asDictionary())
            dismiss(animated: true)
        } catch {
            showAlert(message: "Error creating user: \(error.localizedDescription)")
        }
    }
    private func showAlert(message: String) {
            let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
