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
    
    // Update prepare for segue to handle the new "See All" navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       /* if segue.identifier == "toSubjectDetails" {
            let destination = segue.destination as? subjectViewController
            if let subject = sender as? Subject {
                destination?.subject = subject
            }
        } else if segue.identifier == "toSubjectList" {
            let destination = segue.destination as! subjectListTableViewController
            destination.subjects = self.subjects
        }*/
        
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
        stackView.addArrangedSubview(HomeProgressWidget())
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
    // Add this method to your homeScreenViewController extension:

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
      //  profileButton.tintColor = AppTheme.primary
        profileButton.backgroundColor = AppTheme.primary.withAlphaComponent(0.1)
        profileButton.layer.cornerRadius = 25
        profileButton.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        
        let welcomeLabel = UILabel()
        welcomeLabel.text = "Welcome back!"
        welcomeLabel.font = .systemFont(ofSize: 22, weight: .bold)
       // welcomeLabel.textColor = .s
        
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
        
        return headerView
    }
    

    class HomeProgressWidget: UIView {
        // UI Elements
        private let containerView = UIView()
        private let progressRing = UIView()
        private let progressLayer = CAShapeLayer()
        private let backgroundLayer = CAShapeLayer()
        private let percentLabel = UILabel()
        private let statsLabel = UILabel()
        private let viewDetailsButton = UIButton()
        
        // View controller reference for navigation
       // weak var parentViewController: UIViewController?
        
        // MARK: - Initialization
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupView()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupView()
        }
        
        // MARK: - UI Setup
        
        private func setupView() {
            // Container styling
            backgroundColor = .clear
            
            // Main container
            containerView.backgroundColor = .white
            containerView.layer.cornerRadius = 16
            containerView.layer.shadowColor = UIColor.black.cgColor
            containerView.layer.shadowOpacity = 0.1
            containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
            containerView.layer.shadowRadius = 8
            containerView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(containerView)
            
            // Title label
            let titleLabel = UILabel()
            titleLabel.text = "Study Progress"
            titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
            titleLabel.textColor = UIColor(red: 0.0, green: 0.2, blue: 0.7, alpha: 1.0) // Royal blue
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(titleLabel)
            
            // Progress ring setup
            setupProgressRing()
            
            // Stats label
            statsLabel.font = .systemFont(ofSize: 15)
            statsLabel.textColor = .darkGray
            statsLabel.numberOfLines = 2
            statsLabel.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(statsLabel)
            
            // View details button
            viewDetailsButton.setTitle("View Details", for: .normal)
            viewDetailsButton.setTitleColor(.white, for: .normal)
            viewDetailsButton.backgroundColor = UIColor(red: 0.0, green: 0.2, blue: 0.7, alpha: 1.0) // Royal blue
            viewDetailsButton.layer.cornerRadius = 16
            viewDetailsButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
            viewDetailsButton.addTarget(self, action: #selector(showProgressDetails), for: .touchUpInside)
            viewDetailsButton.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(viewDetailsButton)
            
            // Layout constraints
            NSLayoutConstraint.activate([
                containerView.topAnchor.constraint(equalTo: topAnchor),
                containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
                containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
                containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
                
                titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
                titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
                
                progressRing.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
                progressRing.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
                progressRing.widthAnchor.constraint(equalToConstant: 80),
                progressRing.heightAnchor.constraint(equalToConstant: 80),
                
                percentLabel.centerXAnchor.constraint(equalTo: progressRing.centerXAnchor),
                percentLabel.centerYAnchor.constraint(equalTo: progressRing.centerYAnchor),
                
                statsLabel.leadingAnchor.constraint(equalTo: progressRing.trailingAnchor, constant: 16),
                statsLabel.centerYAnchor.constraint(equalTo: progressRing.centerYAnchor),
                statsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
                
                viewDetailsButton.topAnchor.constraint(equalTo: progressRing.bottomAnchor, constant: 16),
                viewDetailsButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
                viewDetailsButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
                viewDetailsButton.heightAnchor.constraint(equalToConstant: 40),
                viewDetailsButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
            ])
        }
        
        private func setupProgressRing() {
            progressRing.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(progressRing)
            
            // Background circle
            let circularPath = UIBezierPath(arcCenter: CGPoint(x: 40, y: 40),
                                           radius: 32,
                                           startAngle: -CGFloat.pi / 2,
                                           endAngle: 2 * CGFloat.pi - CGFloat.pi / 2,
                                           clockwise: true)
            
            backgroundLayer.path = circularPath.cgPath
            backgroundLayer.fillColor = UIColor.clear.cgColor
            backgroundLayer.strokeColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0).cgColor
            backgroundLayer.lineWidth = 8
            backgroundLayer.lineCap = .round
            progressRing.layer.addSublayer(backgroundLayer)
            
            // Progress circle
            progressLayer.path = circularPath.cgPath
            progressLayer.fillColor = UIColor.clear.cgColor
            progressLayer.strokeColor = UIColor(red: 0.0, green: 0.2, blue: 0.7, alpha: 1.0).cgColor // Royal blue
            progressLayer.lineWidth = 8
            progressLayer.lineCap = .round
            progressLayer.strokeEnd = 0
            progressRing.layer.addSublayer(progressLayer)
            
            // Percentage label
            percentLabel.font = .systemFont(ofSize: 16, weight: .bold)
            percentLabel.textAlignment = .center
            percentLabel.text = "0%"
            percentLabel.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(percentLabel)
        }
        
        // MARK: - Data Update
        
        func updateProgress() {
            Task {
                // Use your existing backend functions
                let timeInterval = Calendar.Component.weekOfYear
                let flashcardsProgress = await createProgress(type: TopicsType.flashcards, timeInterval: timeInterval)
                let questionsProgress = await createProgress(type: TopicsType.quizzes, timeInterval: timeInterval)
                
                // Calculate overall progress
                let overallProgress = (flashcardsProgress.progress + questionsProgress.progress) / 2.0
                
                // Update UI on main thread
                await MainActor.run {
                    // Update progress ring
                    self.progressLayer.strokeEnd = CGFloat(overallProgress)
                    
                    // Update percentage label
                    let percentText = String(format: "%.0f%%", overallProgress * 100)
                    self.percentLabel.text = percentText
                    
                    // Update stats text
                    let statsText = "📚 \(flashcardsProgress.completed)/\(flashcardsProgress.total) cards\n📝 \(questionsProgress.completed)/\(questionsProgress.total) questions"
                    self.statsLabel.text = statsText
                }
            }
        }
        
        // MARK: - Actions
        
        @objc private func showProgressDetails() {
            let progressVC = ProgressViewController()
            parentViewController?.present(progressVC, animated: true)
        }
        
        // MARK: - Backend Functions (reusing your existing code)
        
        private func createProgress(type: TopicsType, timeInterval: Calendar.Component) async -> ProgressType {
            let lastWeekCount = try! await getLastWeekCount(type: type, timeInterval: timeInterval)
            let lastWeekCompletedCount = try! await getLastWeekCompletedCount(type: type, timeInterval: timeInterval)
            return ProgressType(completed: lastWeekCompletedCount, total: lastWeekCount)
        }
        
        private func getLastWeekCount(type: TopicsType, timeInterval: Calendar.Component) async throws -> Int {
            let today = Calendar.current.startOfDay(for: Date())
            let lastWeek = Calendar.current.date(byAdding: timeInterval, value: -1, to: today)!
            
            // Get schedules asynchronously
            let schedules = try await schedulesDb.findAll(where: ["topicType": type.rawValue])
            
            // Filter schedules
            let lastWeekSchedules = schedules.filter {
                let scheduleDate = Calendar.current.startOfDay(for: $0.date.dateValue())
                return scheduleDate >= lastWeek && scheduleDate <= today
            }
            
            return lastWeekSchedules.count
        }
        
        private func getLastWeekCompletedCount(type: TopicsType, timeInterval: Calendar.Component) async throws -> Int {
            let today = Calendar.current.startOfDay(for: Date())
            let lastWeek = Calendar.current.date(byAdding: timeInterval, value: -1, to: today)!
            let schedules = try await schedulesDb.findAll(where: ["topicType": type.rawValue])
            
            let lastWeekSchedules = schedules.filter {
                let scheduleDate = Calendar.current.startOfDay(for: $0.date.dateValue())
                return scheduleDate >= lastWeek && scheduleDate <= today && $0.completed != nil
            }
            return lastWeekSchedules.count
        }
    }
    private func createStatItem(label: String, value: String) -> UIView {
        let containerView = UIView()
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 16, weight: .bold)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = label
        descriptionLabel.font = .systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.textColor = .systemGray
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(valueLabel)
        containerView.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            valueLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 2),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
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
        
        let titleLabel = UILabel()
        titleLabel.text = "Recent Subjects"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
      /*  let seeAllButton = UIButton()
        seeAllButton.setTitle("See All", for: .normal)
        seeAllButton.setTitleColor(AppTheme.primary, for: .normal)
        seeAllButton.addTarget(self, action: #selector(seeAllSubjectsButtonTapped), for: .touchUpInside)
        seeAllButton.translatesAutoresizingMaskIntoConstraints = false */
        
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
    
  /*  @objc private func seeAllSubjectsButtonTapped() {
        performSegue(withIdentifier: "toSubjectList", sender: nil)
    }*/

 

    private func createSubjectCard(subject: Subject, index: Int) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = AppTheme.primary.withAlphaComponent(0.1)
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.05
        containerView.layer.shadowRadius = 5
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconContainer = UIView()
        iconContainer.backgroundColor = .white
        iconContainer.layer.cornerRadius = 20
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView()
        iconView.image = UIImage(systemName: "book.fill")
        iconView.tintColor = AppTheme.primary
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = subject.name
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction { [weak self] _ in
            self?.performSegue(withIdentifier: "toSubjectDetails", sender: subject)
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
