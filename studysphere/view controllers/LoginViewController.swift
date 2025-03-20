//
//  LoginViewController.swift
//  studysphere
//
//  Created by admin64 on 09/11/24.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - Properties
    var emailTextField: UITextField!
    var passwordTextField: UITextField!
    var loginButton: UIButton!
    var forgotPasswordButton: UIButton!
    var googleSignInButton: UIButton!
    var appleSignInButton: UIButton!
    var signUpButton: UIButton!
    
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
        imageView.image = UIImage(named: "LOGO")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let appTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Memoriso"
        label.textColor = AppTheme.primary
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stackView: UIStackView = {
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
        label.text = "Login in to continue"
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        createViews()
        setupUI()
        setupConstraints()
        setupTapGesture()
    }
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Create Views Programmatically
    private func createViews() {
        // Create Email TextField
        emailTextField = UITextField()
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.placeholder = "Email"
        emailTextField.backgroundColor = .systemGray6
        emailTextField.layer.cornerRadius = 12
        emailTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        emailTextField.leftViewMode = .always
        emailTextField.font = .systemFont(ofSize: 16)
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        
        // Create Password TextField
        passwordTextField = PasswordTextField()
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.placeholder = "Password"
        passwordTextField.backgroundColor = .systemGray6
        passwordTextField.layer.cornerRadius = 12
        passwordTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        passwordTextField.leftViewMode = .always
        passwordTextField.font = .systemFont(ofSize: 16)
        passwordTextField.isSecureTextEntry = true
        passwordTextField.autocorrectionType = .no

        
        // Create Login Button
        loginButton = UIButton(type: .system)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.backgroundColor = AppTheme.primary
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 22
        loginButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        loginButton.setTitle("Login", for: .normal)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        // Create Forgot Password Button
        forgotPasswordButton = UIButton(type: .system)
        forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        forgotPasswordButton.setTitleColor(AppTheme.primary, for: .normal)
        forgotPasswordButton.titleLabel?.font = .systemFont(ofSize: 14)
        forgotPasswordButton.setTitle("Forgot Password?", for: .normal)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
        
        // Create Google Sign-In Button
        googleSignInButton = UIButton(type: .system)
        googleSignInButton.translatesAutoresizingMaskIntoConstraints = false
        googleSignInButton.setTitle("Sign in with Google", for: .normal)
        googleSignInButton.setTitleColor(.black, for: .normal)
        googleSignInButton.backgroundColor = .white
        googleSignInButton.layer.cornerRadius = 12
        googleSignInButton.layer.borderWidth = 1
        googleSignInButton.layer.borderColor = UIColor.systemGray4.cgColor
        googleSignInButton.titleLabel?.font = .systemFont(ofSize: 16)
        
        // Create Apple Sign-In Button
        appleSignInButton = UIButton(type: .system)
        appleSignInButton.translatesAutoresizingMaskIntoConstraints = false
        appleSignInButton.setTitle("Sign in with Apple", for: .normal)
        appleSignInButton.setTitleColor(.white, for: .normal)
        appleSignInButton.backgroundColor = .black
        appleSignInButton.layer.cornerRadius = 12
        appleSignInButton.titleLabel?.font = .systemFont(ofSize: 16)
        
        // Create Sign Up Button
        signUpButton = UIButton(type: .system)
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        
        let attributedString = NSMutableAttributedString(string: "Don't have an account? ", attributes: [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.systemGray
        ])
        attributedString.append(NSAttributedString(string: "Sign Up", attributes: [
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
            .foregroundColor: AppTheme.primary
        ]))
        signUpButton.setAttributedTitle(attributedString, for: .normal)
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Setup scroll view hierarchy
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Setup stack views
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(logoImageView)
        stackView.addArrangedSubview(appTitleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        
        // Add spacing between title and fields
        let spacerView = UIView()
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        spacerView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        stackView.addArrangedSubview(spacerView)
        
        // Setup fields stack
        fieldsStackView.addArrangedSubview(emailTextField)
        fieldsStackView.addArrangedSubview(passwordTextField)
        stackView.addArrangedSubview(fieldsStackView)
        
        // Add buttons to stack
        stackView.addArrangedSubview(loginButton)
        stackView.addArrangedSubview(forgotPasswordButton)
        
        // Add Google and Apple buttons but keep them hidden
        stackView.addArrangedSubview(googleSignInButton)
        stackView.addArrangedSubview(appleSignInButton)
        googleSignInButton.isHidden = true
        appleSignInButton.isHidden = true
        
        // Add spacing before sign up button
        let bottomSpacerView = UIView()
        bottomSpacerView.translatesAutoresizingMaskIntoConstraints = false
        bottomSpacerView.heightAnchor.constraint(equalToConstant: 10).isActive = true
        stackView.addArrangedSubview(bottomSpacerView)
        
        stackView.addArrangedSubview(signUpButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor),
            
            // Stack view - positioned with proper spacing
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 60),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -20),
            
            // Logo image
            logoImageView.widthAnchor.constraint(equalToConstant: 200),
            logoImageView.heightAnchor.constraint(equalToConstant: 200),
            
            // Title label constraints
            appTitleLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            appTitleLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            
            // Fields stack
            fieldsStackView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            
            // Text fields
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            emailTextField.widthAnchor.constraint(equalTo: fieldsStackView.widthAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            passwordTextField.widthAnchor.constraint(equalTo: fieldsStackView.widthAnchor),
            
            // Login button
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            loginButton.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            
            // Google and Apple buttons
            googleSignInButton.heightAnchor.constraint(equalToConstant: 50),
            googleSignInButton.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            appleSignInButton.heightAnchor.constraint(equalToConstant: 50),
            appleSignInButton.widthAnchor.constraint(equalTo: stackView.widthAnchor)
        ])
    }
    
    // MARK: - Actions
    @objc func loginButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "Please enter both email and password.")
            return
        }
        
        // Show loading indicator
        let loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.center = view.center
        loadingIndicator.startAnimating()
        view.addSubview(loadingIndicator)
        
        FirebaseAuthManager.shared.signIn(email: email, password: password) { [weak self] result in
            guard let self = self else { return }
            
            // Hide loading indicator
            DispatchQueue.main.async {
                loadingIndicator.removeFromSuperview()
            }
            
            switch result {
            case .success(let user):
                print("User logged in: \(user.uid)")
                
                // Check if email is verified
                if user.isEmailVerified {
                    // Email is verified, proceed with login
                    Task {
                        await self.checkAndNavigate()
                    }
                } else {
                    // Email is not verified
                    let alert = UIAlertController(
                        title: "Email Not Verified",
                        message: "Please verify your email before logging in. Would you like to resend the verification email?",
                        preferredStyle: .alert
                    )
                    
                    alert.addAction(UIAlertAction(title: "Resend Email", style: .default) { _ in
                        // Resend verification email
                        FirebaseAuthManager.shared.sendEmailVerification { verificationResult in
                            switch verificationResult {
                            case .success():
                                self.showAlert(message: "Verification email sent. Please check your inbox.")
                            case .failure(let error):
                                self.showAlert(message: "Failed to send verification email: \(error.localizedDescription)")
                            }
                        }
                    })
                    
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                        // Sign out the user since they can't proceed without verification
                        try? FirebaseAuthManager.shared.signOut()
                    })
                    
                    DispatchQueue.main.async {
                        self.present(alert, animated: true)
                    }
                }
                
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                self.showError(message: "\(error.localizedDescription)")
            }
        }
    }
    
    @objc func forgotPasswordTapped() {
        let forgotPasswordVC = ForgotPasswordViewController()
        forgotPasswordVC.modalPresentationStyle = .fullScreen
        present(forgotPasswordVC, animated: true)
    }
    private func showError(message: String) {
        let alert = UIAlertController(
            title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "goToSignUp", sender: self)
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
                    // Check if user has seen onboarding
                    let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
                    if !hasSeenOnboarding {
                        // Show onboarding only for first-time users
                        let onboardingVC = OnboardingViewController()
                        onboardingVC.modalPresentationStyle = .fullScreen
                        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController = onboardingVC
                    } else {
                        // Direct to main app for returning users
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        if let tabBarVC = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
                            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController = tabBarVC
                        }
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
