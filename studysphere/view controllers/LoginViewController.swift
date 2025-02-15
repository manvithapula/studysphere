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

        // MARK: - Properties
        private let brandColor = UIColor(red: 37/255, green: 99/255, blue: 235/255, alpha: 1.0)
        
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
        
        private let logoImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.backgroundColor = UIColor(red: 30/255, green: 41/255, blue: 59/255, alpha: 1)
            imageView.layer.cornerRadius = 40
            imageView.clipsToBounds = true
            imageView.translatesAutoresizingMaskIntoConstraints = false
            // Add glow effect
            imageView.layer.shadowColor = UIColor(red: 37/255, green: 99/255, blue: 235/255, alpha: 0.3).cgColor
            imageView.layer.shadowOffset = CGSize(width: 0, height: 4)
            imageView.layer.shadowOpacity = 1
            imageView.layer.shadowRadius = 20
            return imageView
        }()
        
        private let stackView: UIStackView = {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.spacing = 24
            stack.alignment = .center
            stack.translatesAutoresizingMaskIntoConstraints = false
            return stack
        }()
        
        private let titleStackView: UIStackView = {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.spacing = 8
            stack.alignment = .center
            stack.translatesAutoresizingMaskIntoConstraints = false
            return stack
        }()
        
        private let fieldsStackView: UIStackView = {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.spacing = 16
            stack.translatesAutoresizingMaskIntoConstraints = false
            return stack
        }()
        
        
        private let subtitleLabel: UILabel = {
            let label = UILabel()
            label.text = "Sign in to continue"
            label.font = .systemFont(ofSize: 16)
            label.textColor = .systemGray
            label.textAlignment = .center
            return label
        }()
        
        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            setupConstraints()
        }
        
        // MARK: - UI Setup
        private func setupUI() {
            view.backgroundColor = .systemBackground
            
            // Setup scroll view
            view.addSubview(scrollView)
            scrollView.addSubview(contentView)
            
            // Setup stack views
            contentView.addSubview(stackView)
            
            stackView.addArrangedSubview(logoImageView)
            
            titleStackView.addArrangedSubview(subtitleLabel)
            stackView.addArrangedSubview(titleStackView)
            
            // Configure text fields
            [emailTextField, passwordTextField].forEach { textField in
                textField?.backgroundColor = .systemGray6
                textField?.layer.cornerRadius = 12
                textField?.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
                textField?.leftViewMode = .always
                textField?.font = .systemFont(ofSize: 16)
                fieldsStackView.addArrangedSubview(textField!)
            }
            
            emailTextField.placeholder = "Email"
            passwordTextField.placeholder = "Password"
            passwordTextField.isSecureTextEntry = true
            
            stackView.addArrangedSubview(fieldsStackView)
            
            // Configure buttons
            loginButton.backgroundColor = brandColor
            loginButton.setTitleColor(.white, for: .normal)
            loginButton.layer.cornerRadius = 12
            loginButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
            loginButton.setTitle("Login", for: .normal)
            stackView.addArrangedSubview(loginButton)
            
            forgotPasswordButton.setTitleColor(brandColor, for: .normal)
            forgotPasswordButton.titleLabel?.font = .systemFont(ofSize: 14)
            forgotPasswordButton.setTitle("Forgot Password?", for: .normal)
            stackView.addArrangedSubview(forgotPasswordButton)
            
            let attributedString = NSMutableAttributedString(string: "Don't have an account? ", attributes: [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.systemGray
            ])
            attributedString.append(NSAttributedString(string: "Sign Up", attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                .foregroundColor: brandColor
            ]))
            signUpButton.setAttributedTitle(attributedString, for: .normal)
            stackView.addArrangedSubview(signUpButton)
            
            // Hide unused buttons
            googleSignInButton.isHidden = true
            appleSignInButton.isHidden = true
        }
        
    private func setupConstraints() {
           NSLayoutConstraint.activate([
               // Scroll view
               scrollView.topAnchor.constraint(equalTo: view.topAnchor),
               scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
               scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
               scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
               
               // Content view
               contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
               contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
               contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
               contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
               contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
               // Make content view height equal to scroll view to allow centering
               contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
               
               // Stack view - centered in content view
               stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
               stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
               stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
               
               // Logo
               logoImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 150),
               logoImageView.widthAnchor.constraint(equalToConstant: 80),
               logoImageView.heightAnchor.constraint(equalToConstant: 80),
               
               // Fields stack
               fieldsStackView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
               
               // Text fields
               emailTextField.heightAnchor.constraint(equalToConstant: 50),
               passwordTextField.heightAnchor.constraint(equalToConstant: 50),
               
               // Login button
               loginButton.heightAnchor.constraint(equalToConstant: 50),
               loginButton.widthAnchor.constraint(equalTo: stackView.widthAnchor)
           ])
        }
        
        // MARK: - Actions
        @IBAction func loginButtonTapped(_ sender: UIButton) {
            guard let email = emailTextField.text, !email.isEmpty,
                  let password = passwordTextField.text, !password.isEmpty else {
                showAlert(message: "Please enter both email and password.")
                return
            }
            
            Task {
                do {
                    if let user = try await userDB.findAll(where: ["email": email]).first {
                        if password != user.password {
                            showAlert(message: "Invalid password.")
                            return
                        }
                        AuthManager.shared.logIn(email: email, firstName: user.firstName, lastName: user.lastName, id: String(user.id))
                        await checkAndNavigate()
                    } else {
                        showAlert(message: "User not found.")
                    }
                } catch {
                    showAlert(message: "An error occurred. Please try again.")
                }
            }
        }
        
        @IBAction func forgotPasswordButtonTapped(_ sender: UIButton) {
            print("Forgot password tapped")
        }
        
        @IBAction func signUpButtonTapped(_ sender: UIButton) {
            // Handle sign up navigation
        }
        
        private func checkAndNavigate() async {
            guard AuthManager.shared.isLoggedIn,
                  let userEmail = AuthManager.shared.userEmail else {
                return
            }
            
            do {
                if let _ = try await userDB.findAll(where: ["email": userEmail]).first {
                    DispatchQueue.main.async {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        if let tabBarVC = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
                            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController = tabBarVC
                        }
                    }
                }
            } catch {
                print("Error checking user: \(error)")
            }
        }
        
        private func showAlert(message: String) {
            let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
