//
//  SignupViewController.swift
//  studysphere
//
//  Created by admin64 on 12/11/24.
//

import UIKit

class SignupViewController: UIViewController {

    // Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var dateOfBirthTextField: UITextField!
    @IBOutlet weak var googleSignInButton: UIButton!
    @IBOutlet weak var appleSignInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
       
        signUpButton.layer.cornerRadius = 8
        signUpButton.clipsToBounds = true
        
    
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        dateOfBirthTextField.inputView = datePicker
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        dateOfBirthTextField.text = formatter.string(from: sender.date)
    }
    
    
    // Actions
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let firstName = firstNameTextField.text, !firstName.isEmpty,
              let lastName = lastNameTextField.text, !lastName.isEmpty,
              let dateOfBirth = dateOfBirthTextField.text, !dateOfBirth.isEmpty else {
            showAlert(message: "Please fill out all fields.")
            return
        }
        
     
        print("Signing up with email: \(email), name: \(firstName) \(lastName)")
    }
    
    @IBAction func googleSignInButtonTapped(_ sender: UIButton) {
        print("Sign up with Google tapped")
    }
    
    @IBAction func appleSignInButtonTapped(_ sender: UIButton) {
        print("Sign up with Apple tapped")
    }
    
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
