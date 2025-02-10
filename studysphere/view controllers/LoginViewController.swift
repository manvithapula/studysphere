//
//  LoginViewController.swift
//  studysphere
//
//  Created by admin64 on 09/11/24.
//

import UIKit

class LoginViewController: UIViewController {


        
        @IBOutlet weak var emailTextField: UITextField!
        @IBOutlet weak var passwordTextField: UITextField!
        @IBOutlet weak var loginButton: UIButton!
        @IBOutlet weak var forgotPasswordButton: UIButton!
        @IBOutlet weak var googleSignInButton: UIButton!
        @IBOutlet weak var appleSignInButton: UIButton!
        @IBOutlet weak var signUpButton: UIButton!

        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
        }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task{
            await checkAndNavigate()
        }

    }
        
        private func setupUI() {
            //login button
            loginButton.layer.cornerRadius = 8
            loginButton.clipsToBounds = true
        }
    private func checkAndNavigate() async {
        if AuthManager.shared.isLoggedIn {
            guard try! await userDB.findAll(where: ["email": AuthManager.shared.userEmail!]).first != nil else { return }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let tabBarVC = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
                        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController = tabBarVC
                    }
        }
    }
        
        // Actions
        @IBAction func loginButtonTapped(_ sender: UIButton) {
            guard let email = emailTextField.text, !email.isEmpty,
                  let password = passwordTextField.text, !password.isEmpty else {
                showAlert(message: "Please enter both email and password.")
                return
            }
            
            // Perform login action
            Task{
                let user = try await userDB.findAll(where: ["email": email]).first
                if user != nil {
                    AuthManager.shared.logIn(email: email,firstName: user!.firstName, lastName: user!.lastName,id: String(user!.id))
                    if password != user?.password {
                        showAlert(message: "Invalid password.")
                        return
                    }
                    await checkAndNavigate()
                }
                showAlert(message: "User not found.")
            }
        }
        
        @IBAction func forgotPasswordButtonTapped(_ sender: UIButton) {
            //forgot pass
            print("Forgot password tapped")
        }
        
        @IBAction func googleSignInButtonTapped(_ sender: UIButton) {
            // signin
            print("Sign in with Google tapped")
        }
        
        @IBAction func appleSignInButtonTapped(_ sender: UIButton) {
            // Handle Apple sign-in action
            print("Sign in with Apple tapped")
        }
        
        @IBAction func signUpButtonTapped(_ sender: UIButton) {
            // Navigate to the sign-up screen
//            if let signupVC = storyboard?.instantiateViewController(withIdentifier: "SignupViewController") {
//                //present modally
//                signupVC.modalPresentationStyle = .fullScreen
//                navigationController?.pushViewController(signupVC, animated: true)
//            }
        }
        
        private func showAlert(message: String) {
            let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }



