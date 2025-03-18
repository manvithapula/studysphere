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
        label.font = .systemFont(ofSize: 28, weight: .bold)
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
        label.text = "Review at intervals to retain information longer. This method leverages the spacing effect to help with memory retention"
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
        imageView.image = UIImage(systemName: "brain")
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
        label.text = "Test yourself to strengthen memory and identify gaps. This method enhances long-term retention and promotes deeper understanding."
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
        imageView.image = UIImage(systemName: "text.alignleft")
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
        label.text = "Simplify complex topics into concise notes. This method helps reinforce learning and improve comprehension."
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
        imageView.image = UIImage(systemName: "doc.text")
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
        label.text = "Add your study materials to the app and access them anytime."
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
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add container views
        contentView.addSubview(titleLabel)
        
        // Setup Spaced Repetition container
        contentView.addSubview(spaceRepetitionContainer)
        spaceRepetitionContainer.addSubview(spaceRepetitionImageView)
        spaceRepetitionContainer.addSubview(spaceRepetitionTitle)
        contentView.addSubview(spaceRepetitionDescription)
        
        // Setup Active Recall container
        contentView.addSubview(activeRecallContainer)
        activeRecallContainer.addSubview(activeRecallImageView)
        activeRecallContainer.addSubview(activeRecallTitle)
        contentView.addSubview(activeRecallDescription)
        
        // Setup Summarizer container
        contentView.addSubview(summarizerContainer)
        summarizerContainer.addSubview(summarizerImageView)
        summarizerContainer.addSubview(summarizerTitle)
        contentView.addSubview(summarizerDescription)
        
        // Setup Document container
        contentView.addSubview(documnetContainer)
        documnetContainer.addSubview(documnetImageView)
        documnetContainer.addSubview(DocumnetTitle)
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
            spaceRepetitionContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            spaceRepetitionContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            spaceRepetitionContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            spaceRepetitionContainer.heightAnchor.constraint(equalToConstant: 30),
            
            spaceRepetitionImageView.leadingAnchor.constraint(equalTo: spaceRepetitionContainer.leadingAnchor),
            spaceRepetitionImageView.centerYAnchor.constraint(equalTo: spaceRepetitionContainer.centerYAnchor),
            spaceRepetitionImageView.widthAnchor.constraint(equalToConstant: 30),
            spaceRepetitionImageView.heightAnchor.constraint(equalToConstant: 30),
            
            spaceRepetitionTitle.leadingAnchor.constraint(equalTo: spaceRepetitionImageView.trailingAnchor, constant: 12),
            spaceRepetitionTitle.centerYAnchor.constraint(equalTo: spaceRepetitionContainer.centerYAnchor),
            spaceRepetitionTitle.trailingAnchor.constraint(equalTo: spaceRepetitionContainer.trailingAnchor),
            
            spaceRepetitionDescription.topAnchor.constraint(equalTo: spaceRepetitionContainer.bottomAnchor, constant: 12),
            spaceRepetitionDescription.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            spaceRepetitionDescription.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Active Recall constraints
            activeRecallContainer.topAnchor.constraint(equalTo: spaceRepetitionDescription.bottomAnchor, constant: 32),
            activeRecallContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            activeRecallContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            activeRecallContainer.heightAnchor.constraint(equalToConstant: 30),
            
            activeRecallImageView.leadingAnchor.constraint(equalTo: activeRecallContainer.leadingAnchor),
            activeRecallImageView.centerYAnchor.constraint(equalTo: activeRecallContainer.centerYAnchor),
            activeRecallImageView.widthAnchor.constraint(equalToConstant: 30),
            activeRecallImageView.heightAnchor.constraint(equalToConstant: 30),
            
            activeRecallTitle.leadingAnchor.constraint(equalTo: activeRecallImageView.trailingAnchor, constant: 12),
            activeRecallTitle.centerYAnchor.constraint(equalTo: activeRecallContainer.centerYAnchor),
            activeRecallTitle.trailingAnchor.constraint(equalTo: activeRecallContainer.trailingAnchor),
            
            activeRecallDescription.topAnchor.constraint(equalTo: activeRecallContainer.bottomAnchor, constant: 12),
            activeRecallDescription.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            activeRecallDescription.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Summarizer constraints
            summarizerContainer.topAnchor.constraint(equalTo: activeRecallDescription.bottomAnchor, constant: 32),
            summarizerContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            summarizerContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            summarizerContainer.heightAnchor.constraint(equalToConstant: 30),
            
            summarizerImageView.leadingAnchor.constraint(equalTo: summarizerContainer.leadingAnchor),
            summarizerImageView.centerYAnchor.constraint(equalTo: summarizerContainer.centerYAnchor),
            summarizerImageView.widthAnchor.constraint(equalToConstant: 30),
            summarizerImageView.heightAnchor.constraint(equalToConstant: 30),
            
            summarizerTitle.leadingAnchor.constraint(equalTo: summarizerImageView.trailingAnchor, constant: 12),
            summarizerTitle.centerYAnchor.constraint(equalTo: summarizerContainer.centerYAnchor),
            summarizerTitle.trailingAnchor.constraint(equalTo: summarizerContainer.trailingAnchor),
            
            summarizerDescription.topAnchor.constraint(equalTo: summarizerContainer.bottomAnchor, constant: 12),
            summarizerDescription.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            summarizerDescription.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Document constraints
            documnetContainer.topAnchor.constraint(equalTo: summarizerDescription.bottomAnchor, constant: 32),
            documnetContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            documnetContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            documnetContainer.heightAnchor.constraint(equalToConstant: 30),
            
            documnetImageView.leadingAnchor.constraint(equalTo: documnetContainer.leadingAnchor),
            documnetImageView.centerYAnchor.constraint(equalTo: documnetContainer.centerYAnchor),
            documnetImageView.widthAnchor.constraint(equalToConstant: 30),
            documnetImageView.heightAnchor.constraint(equalToConstant: 30),
            
            DocumnetTitle.leadingAnchor.constraint(equalTo: documnetImageView.trailingAnchor, constant: 12),
            DocumnetTitle.centerYAnchor.constraint(equalTo: documnetContainer.centerYAnchor),
            DocumnetTitle.trailingAnchor.constraint(equalTo: documnetContainer.trailingAnchor),
            
            documentDescription.topAnchor.constraint(equalTo: documnetContainer.bottomAnchor, constant: 12),
            documentDescription.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            documentDescription.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            nextButton.topAnchor.constraint(equalTo: documentDescription.bottomAnchor, constant: 40),
            nextButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            nextButton.heightAnchor.constraint(equalToConstant: 50),
            nextButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
        
        // Add subtle animations to the images
        animateImages()
    }
    
    private func animateImages() {
        // Apply a subtle pulse animation to each image
        let images = [spaceRepetitionImageView, activeRecallImageView, summarizerImageView, documnetImageView]
        
        for (index, imageView) in images.enumerated() {
            // Delay each animation slightly
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.2) {
                UIView.animate(withDuration: 1.0, delay: 0, options: [.autoreverse, .repeat], animations: {
                    imageView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                }, completion: nil)
            }
        }
    }
    
    private func setupActions() {
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    @objc private func nextButtonTapped() {
        markOnboardingAsSeen()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let tabBarVC = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
            tabBarVC.modalPresentationStyle = .fullScreen
            present(tabBarVC, animated: true)
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

