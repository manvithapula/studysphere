import UIKit
import FirebaseCore

class StudyTechniquesViewController: UIViewController {
    
    // MARK: - Properties
    private let document: FileMetadata
    
    private let unitNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Unit Name"
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
        ("Summariser", "text.alignleft", UIColor.systemBlue)
    ]
    
    
    // MARK: - Initialization
    init(document: FileMetadata) {
        self.document = document
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .systemBackground
        Topic.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(unitNameLabel)
        view.addSubview(Topic)
        view.addSubview(titleLabel)
        view.addSubview(stackView)
        
        techniques.forEach { title, image, color in
            let button = createTechniqueButton(title: title, imageName: image, color: color)
            stackView.addArrangedSubview(button)
        }
        
        // Constraints
        NSLayoutConstraint.activate([
            unitNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            unitNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            Topic.topAnchor.constraint(equalTo: unitNameLabel.bottomAnchor, constant: 24),
            Topic.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            Topic.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            titleLabel.topAnchor.constraint(equalTo: Topic.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
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
        config.cornerStyle = .medium
    
        button.configuration = config
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        button.addTarget(self, action: #selector(techniqueTapped(_:)), for: .touchUpInside)
        return button
    }
    
    // MARK: - Actions
    @objc private func techniqueTapped(_ sender: UIButton) {
        guard let selectedTechnique = sender.configuration?.title else { return }
        if((Topic.text?.isEmpty) != nil){
            showError(message: "Enter a topic")
            return
        }
        switch(selectedTechnique){
        case techniques[0].0:
            createSR(self)
        case techniques[1].0:
            createAR(self)
        case techniques[2].0:
            createSummarizer(self)
        default:
            return
        }
    }
    func createSR(_ sender: Any) {
        var newTopic = Topics(
            id: "", title: Topic.text!, subject: document.subjectId,
            type: .flashcards, subtitle: "6 more to go", createdAt: Timestamp(),
            updatedAt: Timestamp())
        newTopic = topicsDb.create(&newTopic)
        showLoading(text: "Generating flashcards...")
        Task {
            let cards = await FirebaseAiManager.shared.createFlashcards(
                topic: newTopic.id, document: document.documentUrl,
                selectedSubject: document.subjectId)
            if cards.isEmpty {
                hideLoading()
                showError(message: "Faled to generate flashcards")
                topicsDb.delete(id: newTopic.id)
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
    func createAR(_ sender: Any) {
        var newTopic = Topics(
            id: "", title: Topic.text!, subject: document.subjectId,
            type: .quizzes, subtitle: "6 more to go", createdAt: Timestamp(),
            updatedAt: Timestamp())
        newTopic = topicsDb.create(&newTopic)
        showLoading(text: "Generating Quiz...")
        Task {
            let ques = await FirebaseAiManager.shared.createQuiz(
                topic: newTopic.id, document: document.documentUrl,
                selectedSubject: document.subjectId)
            if ques.isEmpty {
                hideLoading()
                showError(message: "Failed to generate Quiz")
                topicsDb.delete(id: newTopic.id)
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

    func createSummarizer(_ sender: Any) {
        var newTopic = Topics(
            id: "", title: Topic.text!, subject: document.subjectId,
            type: .summary, subtitle: "", createdAt: Timestamp(),
            updatedAt: Timestamp())
        newTopic = topicsDb.create(&newTopic)
        showLoading(text: "Generating summary...")
        Task {
            let summary = await FirebaseAiManager.shared.createSummary(
                topic: newTopic.id, document: document.documentUrl,
                selectedSubject: document.subjectId)
            hideLoading()
            if summary == nil {
                showError(message: "Failed to create summary")
                topicsDb.delete(id: newTopic.id)
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
