import UIKit
import FirebaseCore

class SignupViewController: UIViewController {
    
    // MARK: - Properties
    var emailTextField: UITextField!
    var passwordTextField: UITextField!
    var firstNameTextField: UITextField!
    var signUpButton: UIButton!
    
    // Hidden fields 
    var lastNameTextField: UITextField!
    var dateOfBirthTextField: UITextField!
    var googleSignInButton: UIButton!
    var appleSignInButton: UIButton!
    
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
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create Account"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Fill in your details to get started"
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let fieldsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
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
        // Create First Name TextField
        firstNameTextField = UITextField()
        firstNameTextField.translatesAutoresizingMaskIntoConstraints = false
        firstNameTextField.placeholder = "First Name"
        firstNameTextField.backgroundColor = .systemGray6
        firstNameTextField.layer.cornerRadius = 12
        firstNameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        firstNameTextField.leftViewMode = .always
        firstNameTextField.font = .systemFont(ofSize: 16)
        firstNameTextField.autocorrectionType = .no
        
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
        passwordTextField = UITextField()
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.placeholder = "Password"
        passwordTextField.backgroundColor = .systemGray6
        passwordTextField.layer.cornerRadius = 12
        passwordTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        passwordTextField.leftViewMode = .always
        passwordTextField.font = .systemFont(ofSize: 16)
        passwordTextField.isSecureTextEntry = true
        passwordTextField.autocorrectionType = .no
        passwordTextField.autocapitalizationType = .none
        
        // Create Sign Up Button
        signUpButton = UIButton(type: .system)
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.backgroundColor = AppTheme.primary
        signUpButton.setTitleColor(.white, for: .normal)
        signUpButton.layer.cornerRadius = 22
        signUpButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        signUpButton.setTitle("Sign Up", for: .normal)
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        
        // Create hidden fields (for backend compatibility)
        lastNameTextField = UITextField()
        lastNameTextField.isHidden = true
        lastNameTextField.text = ""
        
        dateOfBirthTextField = UITextField()
        dateOfBirthTextField.isHidden = true
        
        googleSignInButton = UIButton(type: .system)
        googleSignInButton.isHidden = true
        
        appleSignInButton = UIButton(type: .system)
        appleSignInButton.isHidden = true
    }
    
    private func setupUI() {
        // Set background color to match login screen
        view.backgroundColor = .systemBackground
        
        // Setup scroll view hierarchy
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Setup stack views
        contentView.addSubview(stackView)
        
        // Add logo and title elements
        stackView.addArrangedSubview(logoImageView)
        stackView.addArrangedSubview(appTitleLabel)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        
        // Add spacing between title and fields
        let spacerView = UIView()
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        spacerView.heightAnchor.constraint(equalToConstant: 10).isActive = true
        stackView.addArrangedSubview(spacerView)
        
        // Setup fields stack
        fieldsStackView.addArrangedSubview(firstNameTextField)
        fieldsStackView.addArrangedSubview(emailTextField)
        fieldsStackView.addArrangedSubview(passwordTextField)
        stackView.addArrangedSubview(fieldsStackView)
        
        // Add sign up button
        stackView.addArrangedSubview(signUpButton)
        
        // Add hidden fields to the view hierarchy
        view.addSubview(lastNameTextField)
        view.addSubview(dateOfBirthTextField)
        view.addSubview(googleSignInButton)
        view.addSubview(appleSignInButton)
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
            
            // App title label
            appTitleLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            appTitleLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            
            // Title label
            titleLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            
            // Subtitle label
            subtitleLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            
            // Fields stack
            fieldsStackView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            
            // Text fields
            firstNameTextField.heightAnchor.constraint(equalToConstant: 50),
            firstNameTextField.widthAnchor.constraint(equalTo: fieldsStackView.widthAnchor),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            emailTextField.widthAnchor.constraint(equalTo: fieldsStackView.widthAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            passwordTextField.widthAnchor.constraint(equalTo: fieldsStackView.widthAnchor),
            
            // Button
            signUpButton.heightAnchor.constraint(equalToConstant: 50),
            signUpButton.widthAnchor.constraint(equalTo: stackView.widthAnchor),
        ])
    }
    
    // MARK: - Actions
    @objc func signUpButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let firstName = firstNameTextField.text, !firstName.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "Please fill out all fields.")
            return
        }
        
        FirebaseAuthManager.shared.signUp(email: email, password: password) { result in
            switch result {
            case .success(let user):
                print("User created: \(user.uid)")
                // Set default values for lastName and dateOfBirth since they're now hidden
                let lastName = ""
                
                var newUser = UserDetailsType(id: "",
                                            firstName: firstName,
                                            lastName: lastName,
                                            dob: Timestamp(date: Date()), // Use current date as default
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
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
