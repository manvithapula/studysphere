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
        label.text = "Welcome to\nMemoriso"
        //label.textColor = .black
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0 // Important for supporting multiple lines
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
        //label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let spaceRepetitionDescription: UILabel = {
        let label = UILabel()
        label.text = "Review your lessons using flashcards at the right times to remember better."
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
        //label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let activeRecallDescription: UILabel = {
        let label = UILabel()
        label.text = "Test yourself with questions to strengthen memory and learn faster."
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
        //label.textColor = .black
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
        //label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let documentDescription: UILabel = {
        let label = UILabel()
        label.text = "Organise and access your study materials easily"
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Get Started", for: .normal)
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
        
        // Add all components directly to contentView
        contentView.addSubview(spaceRepetitionTitle)
        contentView.addSubview(spaceRepetitionImageView)
        contentView.addSubview(spaceRepetitionDescription)
        
        contentView.addSubview(activeRecallTitle)
        contentView.addSubview(activeRecallImageView)
        contentView.addSubview(activeRecallDescription)
        
        contentView.addSubview(summarizerTitle)
        contentView.addSubview(summarizerImageView)
        contentView.addSubview(summarizerDescription)
        
        contentView.addSubview(DocumnetTitle)
        contentView.addSubview(documnetImageView)
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
            
            // Spaced Repetition
            spaceRepetitionTitle.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            spaceRepetitionTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 80),
            spaceRepetitionTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            spaceRepetitionImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            spaceRepetitionImageView.topAnchor.constraint(equalTo: spaceRepetitionTitle.bottomAnchor, constant: -10),
            
            spaceRepetitionDescription.topAnchor.constraint(equalTo: spaceRepetitionTitle.bottomAnchor, constant: 10),
            spaceRepetitionDescription.leadingAnchor.constraint(equalTo: spaceRepetitionImageView.trailingAnchor, constant: 20),
            spaceRepetitionDescription.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Active Recall
            activeRecallTitle.topAnchor.constraint(equalTo: spaceRepetitionDescription.bottomAnchor, constant: 30),
            activeRecallTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 80),
            activeRecallTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            activeRecallImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            activeRecallImageView.topAnchor.constraint(equalTo: activeRecallTitle.bottomAnchor, constant: -10),
            
            activeRecallDescription.topAnchor.constraint(equalTo: activeRecallTitle.bottomAnchor, constant: 10),
            activeRecallDescription.leadingAnchor.constraint(equalTo: activeRecallImageView.trailingAnchor, constant: 20),
            activeRecallDescription.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Summarizer
            summarizerTitle.topAnchor.constraint(equalTo: activeRecallDescription.bottomAnchor, constant: 30),
            summarizerTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 80),
            summarizerTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            summarizerImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            summarizerImageView.topAnchor.constraint(equalTo: summarizerTitle.bottomAnchor, constant: -10),
            
            summarizerDescription.topAnchor.constraint(equalTo: summarizerTitle.bottomAnchor, constant: 10),
            summarizerDescription.leadingAnchor.constraint(equalTo: summarizerImageView.trailingAnchor, constant: 20),
            summarizerDescription.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Document
            DocumnetTitle.topAnchor.constraint(equalTo: summarizerDescription.bottomAnchor, constant: 30),
            DocumnetTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 80),
            DocumnetTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            documnetImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            documnetImageView.topAnchor.constraint(equalTo: DocumnetTitle.bottomAnchor, constant: -10),
            
            documentDescription.topAnchor.constraint(equalTo: DocumnetTitle.bottomAnchor, constant: 10),
            documentDescription.leadingAnchor.constraint(equalTo: documnetImageView.trailingAnchor, constant: 20),
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
        markOnboardingAsSeen()
        
        // Navigate to Login screen
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginVC = storyboard.instantiateInitialViewController() {
            loginVC.modalPresentationStyle = .fullScreen
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController = loginVC
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

