//
//  OnboardingViewController.swift
//  studysphere
//
//  Created by Dev on 17/03/25.
//
import UIKit
import FirebaseAuth

class OnboardingViewController: UIViewController {
    
    // MARK: - Properties
    private let hasSeenOnboardingKey = "hasSeenOnboarding"
    
    // MARK: - UI Components
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
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Study Techniques"
        label.textColor = .black
        label.font = .systemFont(ofSize: 25, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Space Repetition Section
    private let spaceRepetitionContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let spaceRepetitionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "clock")
        imageView.tintColor = AppTheme.primary
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let spaceRepetitionTitle: UILabel = {
        let label = UILabel()
        label.text = "Spaced Repetition"
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let spaceRepetitionDescription: UILabel = {
        let label = UILabel()
        label.text = "Review at optimal intervals to maximize memory retention"
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Active Recall Section
    private let activeRecallContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let activeRecallImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "brain.head.profile")
        imageView.tintColor = AppTheme.primary
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let activeRecallTitle: UILabel = {
        let label = UILabel()
        label.text = "Active Recall"
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let activeRecallDescription: UILabel = {
        let label = UILabel()
        label.text = "Test yourself to strengthen memory and understanding"
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Summarizer Section
    private let summarizerContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let summarizerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "doc.text")
        imageView.tintColor = AppTheme.primary
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let summarizerTitle: UILabel = {
        let label = UILabel()
        label.text = "Summariser"
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let summarizerDescription: UILabel = {
        let label = UILabel()
        label.text = "Create concise notes to improve comprehension"
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let documnetContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let documnetImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "doc.on.doc")
        imageView.tintColor = AppTheme.primary
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let DocumnetTitle: UILabel = {
        let label = UILabel()
        label.text = "Document Organiser"
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let documentDescription: UILabel = {
        let label = UILabel()
        label.text = "Organize and access your study materials easily"
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next", for: .normal)
        button.backgroundColor = AppTheme.primary
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 26
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    // MARK: - Private Methods
    private func markOnboardingAsSeen() {
        UserDefaults.standard.set(true, forKey: hasSeenOnboardingKey)
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Update icon sizes
        [spaceRepetitionImageView, activeRecallImageView, summarizerImageView, documnetImageView].forEach { imageView in
            imageView.tintColor = AppTheme.primary
            imageView.contentMode = .scaleAspectFit
            imageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        }
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        
        // Add all components directly to contentView instead of containers
        contentView.addSubview(spaceRepetitionImageView)
        contentView.addSubview(spaceRepetitionTitle)
        contentView.addSubview(spaceRepetitionDescription)
        
        contentView.addSubview(activeRecallImageView)
        contentView.addSubview(activeRecallTitle)
        contentView.addSubview(activeRecallDescription)
        
        contentView.addSubview(summarizerImageView)
        contentView.addSubview(summarizerTitle)
        contentView.addSubview(summarizerDescription)
        
        contentView.addSubview(documnetImageView)
        contentView.addSubview(DocumnetTitle)
        contentView.addSubview(documentDescription)
        
        contentView.addSubview(nextButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Spaced Repetition constraints
            spaceRepetitionImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            spaceRepetitionImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            spaceRepetitionTitle.leadingAnchor.constraint(equalTo: spaceRepetitionImageView.trailingAnchor, constant: 12),
            spaceRepetitionTitle.centerYAnchor.constraint(equalTo: spaceRepetitionImageView.centerYAnchor),
            
            spaceRepetitionDescription.topAnchor.constraint(equalTo: spaceRepetitionImageView.bottomAnchor, constant: 8),
            spaceRepetitionDescription.leadingAnchor.constraint(equalTo: spaceRepetitionImageView.leadingAnchor,constant: 50),
            spaceRepetitionDescription.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Active Recall constraints
            activeRecallImageView.topAnchor.constraint(equalTo: spaceRepetitionDescription.bottomAnchor, constant: 32),
            activeRecallImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            activeRecallTitle.leadingAnchor.constraint(equalTo: activeRecallImageView.trailingAnchor, constant: 12),
            activeRecallTitle.centerYAnchor.constraint(equalTo: activeRecallImageView.centerYAnchor),
            
            activeRecallDescription.topAnchor.constraint(equalTo: activeRecallImageView.bottomAnchor, constant: 8),
            activeRecallDescription.leadingAnchor.constraint(equalTo: spaceRepetitionImageView.leadingAnchor,constant: 50),
            activeRecallDescription.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Summarizer constraints
            summarizerImageView.topAnchor.constraint(equalTo: activeRecallDescription.bottomAnchor, constant: 32),
            summarizerImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            summarizerTitle.leadingAnchor.constraint(equalTo: summarizerImageView.trailingAnchor, constant: 12),
            summarizerTitle.centerYAnchor.constraint(equalTo: summarizerImageView.centerYAnchor),
            
            summarizerDescription.topAnchor.constraint(equalTo: summarizerImageView.bottomAnchor, constant: 8),
            summarizerDescription.leadingAnchor.constraint(equalTo: summarizerImageView.leadingAnchor,constant: 52),
            summarizerDescription.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Document constraints
            documnetImageView.topAnchor.constraint(equalTo: summarizerDescription.bottomAnchor, constant: 32),
            documnetImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            DocumnetTitle.leadingAnchor.constraint(equalTo: documnetImageView.trailingAnchor, constant: 12),
            DocumnetTitle.centerYAnchor.constraint(equalTo: documnetImageView.centerYAnchor),
            
            documentDescription.topAnchor.constraint(equalTo: documnetImageView.bottomAnchor, constant: 8),
            documentDescription.leadingAnchor.constraint(equalTo: documnetImageView.leadingAnchor,constant: 52),
            documentDescription.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            nextButton.topAnchor.constraint(equalTo: documentDescription.bottomAnchor, constant: 40),
            nextButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            nextButton.heightAnchor.constraint(equalToConstant: 50),
            nextButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    private func setupActions() {
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    @objc private func nextButtonTapped() {
        // Set onboarding as seen
        UserDefaults.standard.set(true, forKey: hasSeenOnboardingKey)
        
        // Navigate to TabBarController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let tabBarVC = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
            tabBarVC.modalPresentationStyle = .fullScreen
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController = tabBarVC
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

