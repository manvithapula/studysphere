import UIKit
import FirebaseCore

class StudyTechniquesViewController: UIViewController {
    
    // MARK: - Properties
    private let document: FileMetadata
    private var documentHasValue: Bool = false
    private var topic:Topics?
    
    private let unitNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Topic Name"
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false // Add this line

        return label
    }()

    private let Topic = StyledTextField()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.text = "Learning Technique"
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    private  let techniques = [
        ("Spaced Repetition", "clock", UIColor.systemBlue),
        ("Active Recall", "brain.head.profile", UIColor.systemBlue),
        ("Summariser", "doc.text", UIColor.systemBlue)
    ]
    
    
    // MARK: - Initialization
    init(document: FileMetadata) {
        self.document = document
        self.topic = nil
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
           super.viewDidLoad()
           setupUI()
           checkDocumentValue()
       }
    
    // MARK: - Setup UI
    private func setupUI() {
            view.backgroundColor = .systemBackground
            Topic.translatesAutoresizingMaskIntoConstraints = false
            
            // Add title label and technique buttons by default
            view.addSubview(titleLabel)
            view.addSubview(stackView)
            
            techniques.forEach { title, image, color in
                let button = createTechniqueButton(title: title, imageName: image, color: color)
                stackView.addArrangedSubview(button)
            }
            
            // Set up constraints for title label and techniques
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
                titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                
                stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
                stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
            ])
        }
    private func checkDocumentValue() {
            
            // Simulating asynchronous function to check if document has value
            Task {
                // Replace this with your actual asynchronous check
                do {
                    // Example of an asynchronous check
                    let alltopics = try await topicsDb.findAll(where: ["subject":document.subjectId])
                    print(alltopics)
                    self.documentHasValue = alltopics.first != nil
                    if(self.documentHasValue){
                        topic = alltopics.first
                    }
                    // Update UI on main thread
                    await MainActor.run {
                        
                        if !self.documentHasValue {
                            self.setupValueDependentUI()
                        } else {
                            print("Document has no value. Showing only technique buttons.")
                        }
                    }
                } catch {
                    await MainActor.run {
                    }
                }
            }
        }
        
        // Setup UI elements that depend on document value
        private func setupValueDependentUI() {
            // Add unitNameLabel and Topic only if document has value
            view.addSubview(unitNameLabel)
            view.addSubview(Topic)
            
            // Adjust constraints based on the presence of unitNameLabel and Topic
            NSLayoutConstraint.activate([
                unitNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
                unitNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                
                Topic.topAnchor.constraint(equalTo: unitNameLabel.bottomAnchor, constant: 24),
                Topic.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                Topic.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                
                // Adjust the title label's top anchor to be below the Topic
                titleLabel.topAnchor.constraint(equalTo: Topic.bottomAnchor, constant: 24)
            ])
            
            // Remove the original top constraint for the title label
            for constraint in view.constraints {
                if constraint.firstItem === titleLabel && constraint.firstAttribute == .top && constraint.secondItem === view.safeAreaLayoutGuide {
                    constraint.isActive = false
                    break
                }
            }
        }
    private func createTechniqueButton(title: String, imageName: String, color: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        
        var config = UIButton.Configuration.filled()
        config.title = title
        config.image = UIImage(systemName: imageName)
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.baseBackgroundColor = UIColor.systemBlue.withAlphaComponent(0.1) // Light blue
        config.baseForegroundColor = color
        config.cornerStyle = .capsule
    
        button.configuration = config
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        button.addTarget(self, action: #selector(techniqueTapped(_:)), for: .touchUpInside)
        return button
    }
    
    // MARK: - Actions
    @objc private func techniqueTapped(_ sender: UIButton) {
        guard let selectedTechnique = sender.configuration?.title else { return }
        if(!documentHasValue && (Topic.text == nil || Topic.text!.isEmpty)){
            showError(message: "Enter a topic")
            return
        }
        let title = documentHasValue ? topic!.title : Topic.text
        switch(selectedTechnique){
        case techniques[0].0:
            createSR(title: title!)
        case techniques[1].0:
            createAR(title: title!)
        case techniques[2].0:
            createSummarizer(title: title!)
        default:
            return
        }
    }
    func createSR(title:String) {
        var newTopic = Topics(
            id: "", title: title, subject: document.subjectId,
            type: .flashcards, subtitle: "6 revision remaining", createdAt: Timestamp(),
            updatedAt: Timestamp())
        newTopic = topicsDb.create(&newTopic)
        showLoading(text: "We're on it! Please wait a moment.")
        Task {
            let cards = await FirebaseAiManager.shared.createFlashcards(
                topic: newTopic.id, document: document.documentUrl,
                selectedSubject: document.subjectId)
            if cards.isEmpty {
                hideLoading()
                showError(message: "Faled to generate flashcards")
                await topicsDb.delete(id: newTopic.id)
                return
            }

            let mySchedules = spacedRepetitionSchedule(
                startDate: Foundation.Date(), title: newTopic.title,
                topic: newTopic.id, topicsType: TopicsType.flashcards)
            for var schedule in mySchedules {
                let _ = schedulesDb.create(&schedule)
            }
            hideLoading()
            performCustomNav(identifier: "toSrListView")
        }

    }
    func createAR(title:String) {
        var newTopic = Topics(
            id: "", title: title, subject: document.subjectId,
            type: .quizzes, subtitle: "6 revision remaining", createdAt: Timestamp(),
            updatedAt: Timestamp())
        newTopic = topicsDb.create(&newTopic)
        showLoading(text: "We're on it! Please wait a moment.")
        Task {
            let ques = await FirebaseAiManager.shared.createQuiz(
                topic: newTopic.id, document: document.documentUrl,
                selectedSubject: document.subjectId)
            if ques.isEmpty {
                hideLoading()
                showError(message: "Failed to generate Quiz")
                await topicsDb.delete(id: newTopic.id)
                return
            }
            let mySchedules = spacedRepetitionSchedule(
                startDate: Foundation.Date(), title: newTopic.title,
                topic: newTopic.id, topicsType: TopicsType.quizzes)
            for var schedule in mySchedules {
                let _ = schedulesDb.create(&schedule)
            }
            hideLoading()
            performCustomNav(identifier: "toArListView")
        }
    }

    func createSummarizer(title:String) {
        var newTopic = Topics(
            id: "", title: title, subject: document.subjectId,
            type: .summary, subtitle: "", createdAt: Timestamp(),
            updatedAt: Timestamp())
        newTopic = topicsDb.create(&newTopic)
        showLoading(text: "We're on it! Please wait a moment.")
        Task {
            let summary = await FirebaseAiManager.shared.createSummary(
                topic: newTopic.id, document: document.documentUrl,
                selectedSubject: document.subjectId)
            hideLoading()
            if summary == nil {
                showError(message: "Failed to create summary")
                await topicsDb.delete(id: newTopic.id)
                return
            }
            performCustomNav(identifier: "toSuListView")
        }

    }
    
    private func performCustomNav(identifier: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let tabBarVC = storyboard.instantiateViewController(
            withIdentifier: "TabBarController") as? UITabBarController
        {
            (UIApplication.shared.connectedScenes.first?.delegate
                as? SceneDelegate)?.window?.rootViewController = tabBarVC
            (UIApplication.shared.connectedScenes.first?.delegate
                as? SceneDelegate)?.window?.makeKeyAndVisible()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let navigationVC = tabBarVC.viewControllers?.first(where: {
                    $0 is UINavigationController
                }) as? UINavigationController,
                    let homeVC = navigationVC.viewControllers.first(where: {
                        $0 is homeScreenViewController
                    }) as? homeScreenViewController
                {
                    homeVC.performSegue(withIdentifier: identifier, sender: nil)
                } else {
                    print(
                        "Error: HomeViewController is not properly embedded in UINavigationController under TabBarController."
                    )
                }
            }
        } else {
            print("Error: Could not instantiate TabBarController.")
        }
    }
    private func showLoading(text: String) {
        let loadingView = LoadingView()
        loadingView.tag = 999  // Tag for easy removal
        loadingView.text = text
        view.addSubview(loadingView)
        loadingView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        loadingView.show()
    }

    private func hideLoading() {
        if let loadingView = view.viewWithTag(999) {
            loadingView.removeFromSuperview()
        }
    }
    private func showError(message: String) {
        let alert = UIAlertController(
            title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
