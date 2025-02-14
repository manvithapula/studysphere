import UIKit

class homeScreenViewController: UIViewController {
    
    private var subjects: [Subject] = []
    private var scheduleItems: [ScheduleItem] = []
    private var studyTechniques: [String] = ["Spaced Repetition", "Active Recall", "Summariser"]
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var gradientLayer = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = false
        setupUI()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            subjects = try await subjectDb.findAll()
            let schedules = try await schedulesDb.findAll()
            let today = formatDateToString(date: Date())
            
            scheduleItems = schedules
                .filter { formatDateToString(date: $0.date.dateValue()) == today }
                .prefix(3)
                .compactMap { schedule in
                    if schedule.completed == nil {
                        return ScheduleItem(
                            iconName: schedule.topicType == TopicsType.flashcards ? "square.stack.3d.down.forward" : "clipboard",
                            title: schedule.title,
                            subtitle: "",
                            progress: 0,
                            topicType: schedule.topicType,
                            topicId: schedule.topic
                        )
                    }
                    return nil
                }
            
            setupGradient()
            contentView.setNeedsLayout()
        }
    }
    
    private func loadData() {
        Task {
            subjects = try await subjectDb.findAll()
            let schedules = try await schedulesDb.findAll()
            let today = formatDateToString(date: Date())
            
            scheduleItems = schedules
                .filter { formatDateToString(date: $0.date.dateValue()) == today }
                .prefix(3)
                .compactMap { schedule in
                    if schedule.completed == nil {
                        return ScheduleItem(
                            iconName: "pencil",
                            title: schedule.title,
                            subtitle: "",
                            progress: 0,
                            topicType: schedule.topicType,
                            topicId: schedule.topic
                        )
                    }
                    return nil
                }
            
            contentView.setNeedsLayout()
        }
    }
    
    private func setupGradient() {
        let mainColor = UIColor.orange
        gradientLayer.colors = [
            mainColor.withAlphaComponent(1.0).cgColor,
            mainColor.withAlphaComponent(0.0).cgColor
        ]
        gradientLayer.locations = [0.0, 0.15]
        gradientLayer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 10)
        view.layer.addSublayer(gradientLayer)
    }
    
    // MARK: - Actions
    
    @objc private func profileButtonTapped() {
        // Handle profile button tap
        print("Profile tapped")
    }
    
    @objc private func bellButtonTapped() {
        // Handle bell button tap
        print("Bell tapped")
    }
    
    @objc private func seeAllButtonTapped() {
        performSegue(withIdentifier: "TodaysLearningSegue", sender: nil)
    }
    
    @objc private func startButtonTapped() {
        // Handle start button tap
        print("Start tapped")
    }
    
    @objc private func addButtonTapped() {
        // Handle add button tap
        print("Add tapped")
    }
    
    // MARK: - Navigation
    
    // Update prepare for segue to handle the new "See All" navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSubjectList" {
            let destination = segue.destination as! subjectViewController
            if let subject = sender as? Subject {
                destination.subject = subject
            }
        } else if segue.identifier == "toSubjectList" {
            let destination = segue.destination as! subjectListTableViewController
            destination.subjects = self.subjects
        }
        
        if segue.identifier == "toFLS" || segue.identifier == "toQTS" {
            if let destinationVC = segue.destination as? SRScheduleViewController {
                if let topic = sender as? Topics {
                    destinationVC.topic = topic
                }
            } else if let destinationVC = segue.destination as? ARScheduleViewController {
                if let topic = sender as? Topics {
                    destinationVC.topic = topic
                }
            }
        }
    }
}

// MARK: - View Creation Methods
extension homeScreenViewController {
    private func setupUI() {
        view.backgroundColor = .systemGray6
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        stackView.addArrangedSubview(createProfileHeaderView())
        stackView.addArrangedSubview(createTodayScheduleView())
        stackView.addArrangedSubview(createStudyTechniquesView())
        stackView.addArrangedSubview(createSubjectsGridView())
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func createProfileHeaderView() -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        
        let profileButton = UIButton()
        profileButton.setImage(UIImage(systemName: "person.crop.circle.fill"), for: .normal)
        profileButton.tintColor = AppTheme.primary
        profileButton.backgroundColor = AppTheme.primary.withAlphaComponent(0.1)
        profileButton.layer.cornerRadius = 25
        profileButton.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        
        let nameLabel = UILabel()
        nameLabel.text = AuthManager.shared.firstName! + " " + AuthManager.shared.lastName!
        nameLabel.font = .systemFont(ofSize: 22, weight: .bold)
        
        let welcomeLabel = UILabel()
        welcomeLabel.text = "Welcome back,"
        welcomeLabel.font = .systemFont(ofSize: 14)
        welcomeLabel.textColor = .secondaryLabel
        
        let labelStack = UIStackView(arrangedSubviews: [welcomeLabel, nameLabel])
        labelStack.axis = .vertical
        labelStack.spacing = 4
        
        let bellButton = UIButton()
        bellButton.setImage(UIImage(systemName: "bell.fill"), for: .normal)
        bellButton.tintColor = AppTheme.primary
        bellButton.addTarget(self, action: #selector(bellButtonTapped), for: .touchUpInside)
        
        [profileButton, labelStack, bellButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalToConstant: 100),
            
            profileButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            profileButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            profileButton.widthAnchor.constraint(equalToConstant: 50),
            profileButton.heightAnchor.constraint(equalToConstant: 50),
            
            labelStack.leadingAnchor.constraint(equalTo: profileButton.trailingAnchor, constant: 16),
            labelStack.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            bellButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            bellButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            bellButton.widthAnchor.constraint(equalToConstant: 30),
            bellButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        return containerView
    }
    private func createScheduleItemView(for item: ScheduleItem) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.05
        containerView.layer.shadowRadius = 5
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = item.title
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView()
        iconView.image = UIImage(systemName: item.iconName)
        iconView.tintColor = AppTheme.primary
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let startButton = UIButton()
        startButton.setTitle("Start", for: .normal)
        startButton.setTitleColor(.white, for: .normal)
        startButton.backgroundColor = AppTheme.primary
        startButton.layer.cornerRadius = 16
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.addAction(UIAction { [weak self] _ in
            Task {
                let topic = try await topicsDb.findAll(where: ["id": item.topicId]).first
                self?.performSegue(withIdentifier: item.topicType == TopicsType.flashcards ? "toFLS" : "toQTS", sender: topic)
            }
        }, for: .touchUpInside)
        
        containerView.addSubview(iconView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(startButton)
        
        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalToConstant: 80),
            
            iconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            startButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            startButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 80),
            startButton.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        return containerView
    }

    private func createSubjectsGridView() -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        
        let titleLabel = UILabel()
        titleLabel.text = "My Subjects"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let seeAllButton = UIButton()
        seeAllButton.setTitle("See All", for: .normal)
        seeAllButton.setTitleColor(AppTheme.primary, for: .normal)
        seeAllButton.addTarget(self, action: #selector(seeAllSubjectsButtonTapped), for: .touchUpInside)
        seeAllButton.translatesAutoresizingMaskIntoConstraints = false
        
        let headerStack = UIStackView(arrangedSubviews: [titleLabel, seeAllButton])
        headerStack.axis = .horizontal
        headerStack.distribution = .equalSpacing
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        
        let subjectsStack = UIStackView()
        subjectsStack.axis = .vertical
        subjectsStack.spacing = 12
        subjectsStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Only show first 3 subjects
        let displayedSubjects = subjects.prefix(3)
        for (index, subject) in displayedSubjects.enumerated() {
            let subjectCard = createSubjectCard(subject: subject, index: index)
            subjectsStack.addArrangedSubview(subjectCard)
        }
        
        let mainStack = UIStackView(arrangedSubviews: [headerStack, subjectsStack])
        mainStack.axis = .vertical
        mainStack.spacing = 16
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
        
        return containerView
    }
    
    @objc private func seeAllSubjectsButtonTapped() {
        performSegue(withIdentifier: "toSubjectList", sender: nil)
    }

 

    private func createSubjectCard(subject: Subject, index: Int) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.05
        containerView.layer.shadowRadius = 5
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconContainer = UIView()
        iconContainer.backgroundColor = AppTheme.getSubjectColor(index).withAlphaComponent(0.1)
        iconContainer.layer.cornerRadius = 20
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView()
        iconView.image = UIImage(systemName: "book.fill")
        iconView.tintColor = AppTheme.getSubjectColor(index)
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = subject.name
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction { [weak self] _ in
            self?.performSegue(withIdentifier: "toSubjectList", sender: subject)
        }, for: .touchUpInside)
        
        containerView.addSubview(iconContainer)
        iconContainer.addSubview(iconView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(button)
        
        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalToConstant: 80),
            
            iconContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconContainer.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 40),
            iconContainer.heightAnchor.constraint(equalToConstant: 40),
            
            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            button.topAnchor.constraint(equalTo: containerView.topAnchor),
            button.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
    
    private func createTodayScheduleView() -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        
        let titleLabel = UILabel()
        titleLabel.text = "Today's Schedule"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        
        let seeAllButton = UIButton()
        seeAllButton.setTitle("See All", for: .normal)
        seeAllButton.setTitleColor(AppTheme.primary, for: .normal)
        seeAllButton.addTarget(self, action: #selector(seeAllButtonTapped), for: .touchUpInside)
        
        let headerStack = UIStackView(arrangedSubviews: [titleLabel, seeAllButton])
        headerStack.axis = .horizontal
        headerStack.distribution = .equalSpacing
        
        let scheduleStack = UIStackView()
        scheduleStack.axis = .vertical
        scheduleStack.spacing = 12
        
        for item in scheduleItems {
            scheduleStack.addArrangedSubview(createScheduleItemView(for: item))
        }
        
        let mainStack = UIStackView(arrangedSubviews: [headerStack, scheduleStack])
        mainStack.axis = .vertical
        mainStack.spacing = 16
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
        
        return containerView
    }
    
    
    private func createStudyTechniquesView() -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        
        let titleLabel = UILabel()
        titleLabel.text = "Study Techniques"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let techniquesStack = UIStackView()
        techniquesStack.axis = .horizontal
        techniquesStack.distribution = .fillEqually
        techniquesStack.spacing = 12
        techniquesStack.translatesAutoresizingMaskIntoConstraints = false
        
        let techniques = [
            ("Spaced Repetition", "clock.fill", TopicsType.flashcards, "toSrListView"),
            ("Active Recall", "brain.head.profile", TopicsType.quizzes, "toArListView"),
            ("Summariser", "doc.text.fill", TopicsType.summary, "toSuListView")
        ]
        
        for (title, icon, type, segue) in techniques {
            let techniqueView = createTechniqueCard(title: title, icon: icon, type: type, segueIdentifier: segue)
            techniquesStack.addArrangedSubview(techniqueView)
        }
        
        let mainStack = UIStackView(arrangedSubviews: [titleLabel, techniquesStack])
        mainStack.axis = .vertical
        mainStack.spacing = 16
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            techniquesStack.heightAnchor.constraint(equalToConstant: 120)
        ])
        
        return containerView
    }
    
    private func createTechniqueCard(title: String, icon: String, type: TopicsType, segueIdentifier: String) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.05
        containerView.layer.shadowRadius = 5
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        let iconContainer = UIView()
        iconContainer.backgroundColor = AppTheme.primary.withAlphaComponent(0.1)
        iconContainer.layer.cornerRadius = 20
        
        let iconView = UIImageView()
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = AppTheme.primary
        iconView.contentMode = .scaleAspectFit
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        
        let button = UIButton()
        button.addAction(UIAction { [weak self] _ in
            self?.performSegue(withIdentifier: segueIdentifier, sender: nil)
        }, for: .touchUpInside)
        
        [iconContainer, iconView, titleLabel, button].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            iconContainer.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            iconContainer.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 40),
            iconContainer.heightAnchor.constraint(equalToConstant: 40),
            
            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),
            
            titleLabel.topAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            
            button.topAnchor.constraint(equalTo: containerView.topAnchor),
            button.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
}
