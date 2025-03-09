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
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    private func loadData() {
        Task {
            subjects = try await subjectDb.findAll()
            let schedules = try await schedulesDb.findAll()
            let today = formatDateToString(date: Date())
            
            scheduleItems = schedules
                .filter { formatDateToString(date: $0.date.dateValue()) == today && $0.completed == nil }
                .prefix(3)
                .compactMap { schedule in
                        return ScheduleItem(
                            iconName: schedule.topicType == TopicsType.flashcards ? "clock.fill" : schedule.topicType == TopicsType.quizzes ? "brain.head.profile" : "doc.text.fill",
                            title: schedule.title,
                            subtitle: "",
                            progress: 0,
                            topicType: schedule.topicType,
                            topicId: schedule.topic
                        )
                }
            setupUI()
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
        performSegue(withIdentifier: "toProfile", sender: self)
    }

    
    @objc private func seeAllButtonTapped() {
        performSegue(withIdentifier: "TodaysLearningSegue", sender: nil)
    }
    
    @objc private func startButtonTapped() {
        // Handle start button tap
        print("Start tapped")
    }

    @IBAction func comeFromProfile(segue:UIStoryboardSegue) {
        setupUI()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSubjectDetails" {
            let destination = segue.destination as? subjectViewController
            if let subject = sender as? Subject {
                destination?.subject = subject
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
        contentView.subviews.forEach { $0.removeFromSuperview() }
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
        stackView.addArrangedSubview(createUploadPDFView()) // pdf
        stackView.addArrangedSubview(createTodayScheduleView())
        stackView.addArrangedSubview(createSubjectsGridView())
        stackView.addArrangedSubview(createStudyTechniquesView())

       
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    

    private func createUploadPDFView() -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        
        // Banner container
        let bannerView = UIView()
        bannerView.backgroundColor = AppTheme.primary.withAlphaComponent(0.1)
        bannerView.layer.cornerRadius = 12
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        
        // PDF icon
        let iconContainer = UIView()
        iconContainer.backgroundColor = .white
        iconContainer.layer.cornerRadius = 25
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let pdfIcon = UIImageView()
        pdfIcon.image = UIImage(systemName: "doc.fill")
        pdfIcon.tintColor = AppTheme.primary
        pdfIcon.contentMode = .scaleAspectFit
        pdfIcon.translatesAutoresizingMaskIntoConstraints = false
        
        // Text content
        let titleLabel = UILabel()
        titleLabel.text = "Upload Study Material"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Create flashcards, quizzes and summaries from your PDFs"
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = .darkGray
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Upload button
        let uploadButton = UIButton()
        uploadButton.setTitle("Upload PDF", for: .normal)
        uploadButton.setTitleColor(.white, for: .normal)
        uploadButton.backgroundColor = AppTheme.primary
        uploadButton.layer.cornerRadius = 16
        uploadButton.translatesAutoresizingMaskIntoConstraints = false
        uploadButton.addTarget(self, action: #selector(uploadPDFButtonTapped), for: .touchUpInside)
        
        // Add subviews
        containerView.addSubview(bannerView)
        bannerView.addSubview(iconContainer)
        iconContainer.addSubview(pdfIcon)
        bannerView.addSubview(titleLabel)
        bannerView.addSubview(subtitleLabel)
        bannerView.addSubview(uploadButton)
        
        NSLayoutConstraint.activate([
            bannerView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            bannerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            bannerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            bannerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            iconContainer.leadingAnchor.constraint(equalTo: bannerView.leadingAnchor, constant: 16),
            iconContainer.centerYAnchor.constraint(equalTo: bannerView.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 50),
            iconContainer.heightAnchor.constraint(equalToConstant: 50),
            
            pdfIcon.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            pdfIcon.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            pdfIcon.widthAnchor.constraint(equalToConstant: 24),
            pdfIcon.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: bannerView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: bannerView.trailingAnchor, constant: -16),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: bannerView.trailingAnchor, constant: -16),
            
            uploadButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            uploadButton.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            uploadButton.widthAnchor.constraint(equalToConstant: 120),
            uploadButton.heightAnchor.constraint(equalToConstant: 40),
            uploadButton.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor, constant: -20)
        ])
        
        return containerView
    }

    @objc private func uploadPDFButtonTapped() {
        performSegue(withIdentifier: "toCreate", sender: nil)
    }
    
    private func createProfileHeaderView() -> UIView {
        let headerView = UIView()
        
        let profileButton = UIButton()
        profileButton.setImage(UIImage(systemName: "person.crop.circle.fill"), for: .normal)
     
        profileButton.backgroundColor = AppTheme.primary.withAlphaComponent(0.1)
        profileButton.layer.cornerRadius = 25
        profileButton.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        func loadImageFromUserDefaults() {
            if let imageData = UserDefaults.standard.data(forKey: "profileImage"),
               let image = UIImage(data: imageData) {
                let roundedImage = makeRoundedImage(image)
                profileButton.setImage(roundedImage, for: .normal)
            }
        }
         func makeRoundedImage(_ image: UIImage) -> UIImage? {
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                imageView.contentMode = .scaleAspectFill
                imageView.layer.cornerRadius = 25  // Half of width/height for perfect circle
                imageView.layer.masksToBounds = true
                imageView.image = image
                UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, 0.0)
                imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
                let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                return roundedImage
            }
        let welcomeLabel = UILabel()
        welcomeLabel.text = "Welcome back!"
        welcomeLabel.font = .systemFont(ofSize: 22, weight: .bold)
      
        
        let nameLabel = UILabel()
        nameLabel.text = AuthManager.shared.firstName!
        nameLabel.font = .systemFont(ofSize: 22, weight: .bold)
        
        [welcomeLabel, nameLabel, profileButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            headerView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            welcomeLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            welcomeLabel.bottomAnchor.constraint(equalTo: nameLabel.topAnchor, constant: -4),
            
            nameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            nameLabel.bottomAnchor.constraint(equalTo: headerView.centerYAnchor, constant: 8),
            
            profileButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            profileButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            profileButton.widthAnchor.constraint(equalToConstant: 50),
            profileButton.heightAnchor.constraint(equalToConstant: 50),
            profileButton.bottomAnchor.constraint(equalTo: headerView.topAnchor, constant: 34),
            
            headerView.heightAnchor.constraint(equalToConstant: 70)
        ])
        loadImageFromUserDefaults()
        return headerView
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
        
        let subjectTag: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 12)
            label.textColor = .black
            label.backgroundColor = .systemBlue.withAlphaComponent(0.1)
            label.layer.cornerRadius = 10
            label.clipsToBounds = true
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "Loading.."
            return label
        }()
        containerView.addSubview(iconView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(startButton)
        containerView.addSubview(subjectTag)
        let topConstraint:CGFloat = 16
        NSLayoutConstraint.activate([
            
            iconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: topConstraint),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: topConstraint),
            
            startButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            startButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 80),
            startButton.heightAnchor.constraint(equalToConstant: 32),
            
            subjectTag.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            subjectTag.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            subjectTag.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            subjectTag.heightAnchor.constraint(greaterThanOrEqualToConstant: 30),
            
            containerView.bottomAnchor.constraint(equalTo: subjectTag.bottomAnchor, constant: 16)
        ])
        subjectTag.layoutIfNeeded()
        subjectTag.layer.cornerRadius = 8
        subjectTag.setPadding(horizontal: 12, vertical: 4)
        
        Task {
            let alltopics = try await topicsDb.findAll(where: ["id": item.topicId])
            if let topic = alltopics.first{
                let allSubjects = try await subjectDb.findAll(where: ["id": topic.subject])
                if let subject = allSubjects.first {
                    await MainActor.run {
                        subjectTag.text = subject.name
                    }
                }
            }
        }
        return containerView
    }

    private func createSubjectsGridView() -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.08
        containerView.layer.shadowRadius = 8
        containerView.layer.shadowOffset = CGSize(width: 0, height: 3)
        
        let titleLabel = UILabel()
        titleLabel.text = "Recent Subjects"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let headerStack = UIStackView(arrangedSubviews: [titleLabel])
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
            let subjectCard = createModernSubjectCard(subject: subject, index: index)
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

    private func createModernSubjectCard(subject: Subject, index: Int) -> UIView {
        // Card container
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Card background with gradient
        let cardBackground = GradientView()
        cardBackground.layer.cornerRadius = 12
        cardBackground.clipsToBounds = true
        cardBackground.translatesAutoresizingMaskIntoConstraints = false
        
        // Icon container with gradient
        let iconContainer = GradientView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.layer.cornerRadius = 24
        iconContainer.clipsToBounds = true
        
        // Get appropriate icon using SubjectIconService
        let iconService = subjectListTableViewCell.SubjectIconService()
        let iconResult = iconService.getIconAndCategory(for: subject.name)
        
        // Icon image view
        let iconImageView = UIImageView()
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white
        iconImageView.image = UIImage(systemName: iconResult.iconName)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Subject title label
        let titleLabel = UILabel()
        titleLabel.text = subject.name
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .darkText
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Topics count label (use random topics count just like in the cell)
        let topicsCountLabel = UILabel()
        let topicsCount = Int.random(in: 12...20)
        topicsCountLabel.text = "\(topicsCount) topics"
        topicsCountLabel.font = .systemFont(ofSize: 13, weight: .medium)
        topicsCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup colors based on index
        let colorSchemes: [(start: UIColor, end: UIColor, pattern: UIColor)] = [
            (AppTheme.primary.withAlphaComponent(0.15), AppTheme.primary.withAlphaComponent(0.05), AppTheme.primary.withAlphaComponent(0.1)),
            (AppTheme.secondary.withAlphaComponent(0.15), AppTheme.secondary.withAlphaComponent(0.05), AppTheme.secondary.withAlphaComponent(0.1))
        ]
        
        let iconColorSchemes: [(start: UIColor, end: UIColor)] = [
            (AppTheme.primary, AppTheme.primary.adjustBrightness(by: 0.2)),
            (AppTheme.secondary, AppTheme.secondary.adjustBrightness(by: 0.2))
        ]
        
        let colorIndex = index % colorSchemes.count
        let colors = colorSchemes[colorIndex]
        let iconColors = iconColorSchemes[colorIndex]
        
        // Set up gradients
        cardBackground.setGradient(startColor: colors.start,
                                  endColor: colors.end,
                                  startPoint: CGPoint(x: 0.0, y: 0.0),
                                  endPoint: CGPoint(x: 1.0, y: 1.0))
        
        iconContainer.setGradient(startColor: iconColors.start,
                                 endColor: iconColors.end,
                                 startPoint: CGPoint(x: 0.0, y: 0.0),
                                 endPoint: CGPoint(x: 1.0, y: 1.0))
        
        // Set topics count label color
        topicsCountLabel.textColor = iconColors.start.withAlphaComponent(0.8)
        
        // Create tap button for the whole card
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction { [weak self] _ in
            self?.performSegue(withIdentifier: "toSubjectDetails", sender: subject)
        }, for: .touchUpInside)
        
        // Add all subviews
        containerView.addSubview(cardBackground)
        containerView.addSubview(button)
        cardBackground.addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        cardBackground.addSubview(titleLabel)
        cardBackground.addSubview(topicsCountLabel)
        
        NSLayoutConstraint.activate([
            // Container view constraints
            containerView.heightAnchor.constraint(equalToConstant: 80),
            
            // Card background constraints
            cardBackground.topAnchor.constraint(equalTo: containerView.topAnchor),
            cardBackground.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            cardBackground.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            cardBackground.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            // Icon container constraints
            iconContainer.leadingAnchor.constraint(equalTo: cardBackground.leadingAnchor, constant: 16),
            iconContainer.centerYAnchor.constraint(equalTo: cardBackground.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 48),
            iconContainer.heightAnchor.constraint(equalToConstant: 48),
            
            // Icon image view constraints
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // Title label constraints
            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: cardBackground.topAnchor, constant: 16),
            
            // Topics count label constraints
            topicsCountLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            topicsCountLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            
            // Button constraints (cover the whole card)
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
        containerView.backgroundColor = AppTheme.primary.withAlphaComponent(0.1)
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
