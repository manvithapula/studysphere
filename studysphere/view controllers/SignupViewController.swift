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
        imageView.image = UIImage(named: "LOGO") // Use the same logo image as login screen
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
        
    // First, fix the titleLabel and subtitleLabel properties
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create Account"
        label.font = .systemFont(ofSize: 24, weight: .bold) // Match login screen font size
        label.textColor = .darkText // Match login screen color
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Fill in your details to get started"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
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
        
      
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(logoImageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)

        [firstNameTextField, lastNameTextField, emailTextField,
         passwordTextField, dateOfBirthTextField].forEach { textField in
            textField?.backgroundColor = .systemGray6
            textField?.layer.cornerRadius = 12
            textField?.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
            textField?.leftViewMode = .always
            textField?.font = .systemFont(ofSize: 16)
            if textField == emailTextField {
                textField?.autocapitalizationType = .none
            }
        }
        signUpButton.isUserInteractionEnabled = true
        signUpButton.backgroundColor = AppTheme.primary
        signUpButton.setTitleColor(.white, for: .normal)
        signUpButton.layer.cornerRadius = 25
        signUpButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        googleSignInButton.isHidden = true
        appleSignInButton.isHidden = true
    }
        
        private func setupDatePicker() {
            datePicker.datePickerMode = .date
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
            dateOfBirthTextField.inputView = datePicker
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
            
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 100),
            logoImageView.heightAnchor.constraint(equalToConstant: 100),
            
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Subtitle label
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Existing constraints for text fields
            firstNameTextField.heightAnchor.constraint(equalToConstant: 50),
            lastNameTextField.heightAnchor.constraint(equalToConstant: 50),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            dateOfBirthTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // Button height
            signUpButton.heightAnchor.constraint(equalToConstant: 50),
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
        FirebaseAuthManager.shared.signUp(email: email, password: password) { result in
            switch result {
            case .success(let user):
                print("User created: \(user.uid)")
                var newUser = UserDetailsType(id: "",
                                            firstName: firstName,
                                            lastName: lastName,
                                              dob: Timestamp(date: self.datePicker.date),
                                            pushNotificationEnabled: false,
                                            faceIdEnabled: false,
                                            email: email,
                                            password: password,
                                            createdAt: Timestamp(),
                                            updatedAt: Timestamp())
                let createdUser = userDB.create(&newUser)
                Task{
                    await self.checkAndNavigate()
                }

            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                self.showError(message: "Error: \(error.localizedDescription)")
            }
        }
        
    }
    private func checkAndNavigate() async {
        guard FirebaseAuthManager.shared.isUserLoggedIn == true else {
            return
        }
        let user = FirebaseAuthManager.shared.currentUser
        do {
            if let user = try await userDB.findAll(where: ["email": user!.email!]).first {
                AuthManager.shared.logIn(email: user.email, firstName: user.firstName, lastName: user.lastName, id: user.id)
                DispatchQueue.main.async {
                    // For new sign ups, always show onboarding first
                    let onboardingVC = OnboardingViewController()
                    onboardingVC.modalPresentationStyle = .fullScreen
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController = onboardingVC
                }
            }
        } catch {
            print("Error checking user: \(error)")
        }
    }
    private func showError(message: String) {
        let alert = UIAlertController(
            title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
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
        
        if userDB.findFirst(where: ["email": email]) != nil {
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
