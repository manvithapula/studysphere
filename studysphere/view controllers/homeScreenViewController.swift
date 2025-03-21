import UIKit

class homeScreenViewController: UIViewController {
    
    private var subjects: [Subject] = []
    private var scheduleItems: [ScheduleItem] = []
    private var allTopics:[Topics] = []
    private var studyTechniques: [String] = ["Spaced Repetition", "Active Recall", "Summariser"]
    private var viewTopicIds = [UIView: String]()

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
            allTopics = try await topicsDb.findAll()
            let today = formatDateToString(date: Date())
            
            scheduleItems = schedules
                .filter { formatDateToString(date: $0.date.dateValue()) == today && $0.completed == nil }
                .prefix(3)
                .compactMap { schedule in
                        return ScheduleItem(
                            iconName: schedule.topicType == TopicsType.flashcards ? "clock" : schedule.topicType == TopicsType.quizzes ? "brain.head.profile" : "doc.text",
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
            let destination = segue.destination as? SubjectDetailsViewController
            if let subject = sender as? Subject {
                destination?.subject = subject
            }
        } else if segue.identifier == "toSubjectList" {
            let destination = segue.destination as! MySubjectListTableViewController
            destination.subjects = self.subjects
        }
        if segue.identifier == "toFLS" || segue.identifier == "toQTS" || segue.identifier == "toSummary"{
            if let destinationVC = segue.destination as? SRScheduleViewController {
                if let topic = sender as? Topics {
                    destinationVC.topic = topic
                }
            } else if let destinationVC = segue.destination as? ARScheduleViewController {
                if let topic = sender as? Topics {
                    destinationVC.topic = topic
                }
            }
        else if let destinationVC = segue.destination as? SummaryViewController {
            if let topic = sender as? Topics {
                destinationVC.topic = topic
            }
        }
            else if let destinationVC = segue.destination as? UINavigationController{
                if let destination = destinationVC.topViewController as? SRScheduleViewController{
                    if let topic = sender as? Topics {
                        destination.topic = topic
                    }
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
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        stackView.addArrangedSubview(createProfileHeaderView())
        stackView.addArrangedSubview(createUploadPDFView()) // pdf upload
        stackView.addArrangedSubview(createTodayScheduleView()) // todays schedule
        stackView.addArrangedSubview(createSubjectsGridView()) //recent subjects
        stackView.addArrangedSubview(createRecentModulesView())
        
        
        
        // stackView.addArrangedSubview(createStudyTechniquesView())
        // stackView.addArrangedSubview(spacedRepetitionGridView(type: .flashcards, title: "Spaced Repetition", action: #selector(SRseeAllButtonTapped)))
        
        //  stackView.addArrangedSubview(spacedRepetitionGridView(type: .quizzes, title: "Active Recall", action: #selector(ARseeAllButtonTapped)))
        
        //  stackView.addArrangedSubview(spacedRepetitionGridView(type: .summary, title: "Summariser", action: #selector(summaryseeAllButtonTapped)))
        
        
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    
    // MARK: HEADER
    private func createProfileHeaderView() -> UIView {
        let headerView = UIView()
        
        let profileButton = UIButton()
        profileButton.setImage(UIImage(systemName: "person.crop.circle"), for: .normal)
        
        profileButton.backgroundColor = AppTheme.primary.withAlphaComponent(0.1)
        profileButton.layer.cornerRadius = 25
        profileButton.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        func loadImageFromUserDefaults() {
            let cacheKey = "profileImage"
            
            // Check if image exists in UserDefaults cache
            if let cachedImageData = UserDefaults.standard.data(forKey: cacheKey),
               let cachedImage = UIImage(data: cachedImageData) {
                // Use cached image
                DispatchQueue.main.async {
                    let roundedImage = makeRoundedImage(cachedImage)
                    profileButton.setImage(roundedImage, for: .normal)
                }
                return
            }
            if let photoURL = FirebaseAuthManager.shared.currentUser?.photoURL {
                
                // If not in cache, download from network
                URLSession.shared.dataTask(with: photoURL) { data, response, error in
                    guard let imageData = data, error == nil,
                          let image = UIImage(data: imageData) else {
                        print("Error loading profile image: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    
                    // Save to UserDefaults cache
                    UserDefaults.standard.set(imageData, forKey: cacheKey)
                    
                    // Make sure UI updates happen on the main thread
                    DispatchQueue.main.async {
                        let roundedImage = makeRoundedImage(image)
                        profileButton.setImage(roundedImage, for: .normal)
                    }
                }.resume()
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
        nameLabel.text = AuthManager.shared.firstName ?? "Loading"
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
            profileButton.topAnchor.constraint(equalTo: welcomeLabel.topAnchor),
            profileButton.widthAnchor.constraint(equalToConstant: 45),
            profileButton.heightAnchor.constraint(equalToConstant: 45),
            headerView.heightAnchor.constraint(equalToConstant: 60)
        ])
        loadImageFromUserDefaults()
        return headerView
    }
    
    //MARK: UPLOAD
    private func createUploadPDFView() -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.08
        containerView.layer.shadowRadius = 8
        containerView.layer.shadowOffset = CGSize(width: 0, height: 3)
        let bannerView = UIView()
        bannerView.backgroundColor = AppTheme.primary.withAlphaComponent(0.1)
        bannerView.layer.cornerRadius = 12
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        let iconContainer = UIView()
        iconContainer.layer.cornerRadius = 25
        iconContainer.clipsToBounds = true
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.backgroundColor = AppTheme.secondary
        let pdfIcon = UIImageView()
        pdfIcon.image = UIImage(systemName: "doc")
        pdfIcon.tintColor = .white
        pdfIcon.contentMode = .scaleAspectFit
        pdfIcon.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "Upload Study Material"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .black
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Create flashcards, quizzes and summaries from your materials"
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = .darkGray
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let uploadButton = UIButton()
        uploadButton.setTitle("Create module", for: .normal)
        uploadButton.setTitleColor(.white, for: .normal)
        uploadButton.backgroundColor = AppTheme.primary
        
        uploadButton.layer.cornerRadius = 20
        uploadButton.clipsToBounds = true
        uploadButton.translatesAutoresizingMaskIntoConstraints = false
        uploadButton.addTarget(self, action: #selector(uploadPDFButtonTapped), for: .touchUpInside)
        uploadButton.addAction(UIAction { _ in
            UIView.animate(withDuration: 0.2) {
                uploadButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                UIView.animate(withDuration: 0.2) {
                    uploadButton.transform = .identity
                }
            }
        }, for: .touchDown)
        
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
            uploadButton.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 20),
            uploadButton.widthAnchor.constraint(equalToConstant: 140),
            uploadButton.heightAnchor.constraint(equalToConstant: 40),
            uploadButton.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor, constant: -20)
        ])
        
        return containerView
    }
    
    @objc private func uploadPDFButtonTapped() {
        performSegue(withIdentifier: "toCreate", sender: nil)
    }
    
    //MARK: TODAYS LEARNING
    private func createTodayScheduleView() -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.08
        containerView.layer.shadowRadius = 8
        containerView.layer.shadowOffset = CGSize(width: 0, height: 3)
        
        // Fix date formatting to match the UI
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        let currentDate = Date()
        let dateString = dateFormatter.string(from: currentDate)
        
        // Create title and date labels
        let titleLabel = UILabel()
        titleLabel.text = "Today's Schedule"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let dateLabel = UILabel()
        dateLabel.text = dateString
        dateLabel.font = .systemFont(ofSize: 13, weight: .medium)
        dateLabel.textColor = .gray
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let seeAllButton = UIButton()
        seeAllButton.setTitle("See All", for: .normal)
        seeAllButton.setTitleColor(AppTheme.primary, for: .normal)
        seeAllButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        seeAllButton.addTarget(self, action: #selector(seeAllButtonTapped), for: .touchUpInside)
        seeAllButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Add all elements to the container
        containerView.addSubview(titleLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(seeAllButton)
        
        let scheduleStack = UIStackView()
        scheduleStack.axis = .vertical
        scheduleStack.spacing = 12
        scheduleStack.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(scheduleStack)
        
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 18),
            
            seeAllButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            seeAllButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
        ])
        
        // Add content to schedule stack
        if scheduleItems.isEmpty {
            let emptyContainer = UIView()
            emptyContainer.layer.cornerRadius = 12
            emptyContainer.translatesAutoresizingMaskIntoConstraints = false
            
            let emptyIcon = UIImageView(image: UIImage(systemName: "checkmark.circle"))
            emptyIcon.tintColor = AppTheme.primary
            emptyIcon.contentMode = .scaleAspectFit
            emptyIcon.translatesAutoresizingMaskIntoConstraints = false
            emptyIcon.widthAnchor.constraint(equalToConstant: 18).isActive = true
            emptyIcon.heightAnchor.constraint(equalToConstant: 18).isActive = true
            
            let emptyStateLabel = UILabel()
            emptyStateLabel.text = "No tasks for today!"
            emptyStateLabel.font = .systemFont(ofSize: 15, weight: .medium)
            emptyStateLabel.textColor = .black
            
            let emptyStack = UIStackView(arrangedSubviews: [emptyIcon, emptyStateLabel])
            emptyStack.axis = .horizontal
            emptyStack.spacing = 6
            emptyStack.alignment = .center
            
            emptyContainer.addSubview(emptyStack)
            emptyStack.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                emptyStack.centerXAnchor.constraint(equalTo: emptyContainer.centerXAnchor),
                emptyStack.centerYAnchor.constraint(equalTo: emptyContainer.centerYAnchor),
                emptyContainer.heightAnchor.constraint(equalToConstant: 50)
            ])
            
            scheduleStack.addArrangedSubview(emptyContainer)
        }
        else {
            for (index, item) in scheduleItems.prefix(3).enumerated() {
                let scheduleItemView = createScheduleItemCard(for: item, index: index)
                scheduleStack.addArrangedSubview(scheduleItemView)
            }
        }
        
        // Add constraints for schedule stack
        NSLayoutConstraint.activate([
            scheduleStack.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            scheduleStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            scheduleStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            scheduleStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
        
        return containerView
    }
    
    private func createScheduleItemCard(for item: ScheduleItem, index: Int) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let isPrimary = index % 2 == 0
        let mainColor = isPrimary ? AppTheme.primary : AppTheme.secondary
        let cardBackground = UIView()
        cardBackground.layer.cornerRadius = 12
        cardBackground.clipsToBounds = true
        cardBackground.backgroundColor = mainColor.withAlphaComponent(0.1)
        cardBackground.translatesAutoresizingMaskIntoConstraints = false
        
        
        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.layer.cornerRadius = 24
        iconContainer.clipsToBounds = true
        iconContainer.backgroundColor = mainColor
        
        let iconView = UIImageView()
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .white
        iconView.image = UIImage(systemName: item.iconName)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = item.title
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .darkText
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
    
        
        let subjectTag = UILabel()
        subjectTag.font = .systemFont(ofSize: 12, weight: .medium)
        subjectTag.text = " "
        subjectTag.textColor = mainColor.withAlphaComponent(0.8)
        subjectTag.backgroundColor = mainColor.withAlphaComponent(0.1)
        subjectTag.layer.cornerRadius = 8
        subjectTag.clipsToBounds = true
        subjectTag.translatesAutoresizingMaskIntoConstraints = false
        subjectTag.setPadding(horizontal: 12, vertical: 4)
        
        let startButton = UIButton()
        startButton.setTitle("Start", for: .normal)
        startButton.setTitleColor(.white, for: .normal)
        startButton.backgroundColor = mainColor
        startButton.layer.cornerRadius = 16
        startButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        startButton.addAction(UIAction { [weak self] _ in
            Task {
                let topic = try await topicsDb.findAll(where: ["id": item.topicId]).first
                self?.performSegue(withIdentifier: item.topicType == TopicsType.flashcards ? "toFLS" : "toQTS", sender: topic)
            }
        }, for: .touchUpInside)
        
        
        startButton.addAction(UIAction { _ in
            UIView.animate(withDuration: 0.2) {
                startButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                UIView.animate(withDuration: 0.2) {
                    startButton.transform = .identity
                }
            }
        }, for: .touchDown)
        
        containerView.addSubview(cardBackground)
        cardBackground.addSubview(iconContainer)
        iconContainer.addSubview(iconView)
        cardBackground.addSubview(titleLabel)
      //  cardBackground.addSubview(subtitleLabel)
        cardBackground.addSubview(subjectTag)
        cardBackground.addSubview(startButton)
        
        NSLayoutConstraint.activate([
            cardBackground.topAnchor.constraint(equalTo: containerView.topAnchor),
            cardBackground.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            cardBackground.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            cardBackground.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            iconContainer.leadingAnchor.constraint(equalTo: cardBackground.leadingAnchor, constant: 16),
            iconContainer.centerYAnchor.constraint(equalTo: cardBackground.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 48),
            iconContainer.heightAnchor.constraint(equalToConstant: 48),
            
            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: cardBackground.topAnchor, constant: 16),
            
            subjectTag.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            subjectTag.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            
            startButton.trailingAnchor.constraint(equalTo: cardBackground.trailingAnchor, constant: -16),
            startButton.centerYAnchor.constraint(equalTo: cardBackground.centerYAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 80),
            startButton.heightAnchor.constraint(equalToConstant: 32),
            
            containerView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        
        Task {
            let alltopics = try await topicsDb.findAll(where: ["id": item.topicId])
            if let topic = alltopics.first {
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
    
    @objc private func cardTapped(_ gesture: UITapGestureRecognizer) {
        if let containerView = gesture.view {
            UIView.animate(withDuration: 0.2) {
                containerView.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                UIView.animate(withDuration: 0.2) {
                    containerView.transform = .identity
                }
            }
        }
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
            label.backgroundColor = AppTheme.secondary.withAlphaComponent(0.1)
            label.layer.cornerRadius = 10
            label.clipsToBounds = true
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = " "
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
    
    
    //MARK: RECENT SUBJECTS
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
        
        if subjects.isEmpty {
            let emptyStateView = createEmptyStateView()
            subjectsStack.addArrangedSubview(emptyStateView)
        } else {
            let displayedSubjects = subjects.prefix(3)
            for (index, subject) in displayedSubjects.enumerated() {
                let subjectCard = createSubjectCard(subject: subject, index: index)
                subjectsStack.addArrangedSubview(subjectCard)
            }
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
    
    private func createEmptyStateView() -> UIView {
        let emptyStateView = UIView()
        emptyStateView.layer.cornerRadius = 12
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        
        let emptyIcon = UIImageView()
        emptyIcon.image = UIImage(systemName: "book.closed")
        emptyIcon.tintColor = AppTheme.primary
        emptyIcon.contentMode = .scaleAspectFit
        emptyIcon.translatesAutoresizingMaskIntoConstraints = false
        
        let emptyLabel = UILabel()
        emptyLabel.text = "No subjects yet."
        emptyLabel.font = .systemFont(ofSize: 16, weight: .medium)
        emptyLabel.textColor = .black
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let actionLabel = UILabel()
        actionLabel.text = "Go to Subjects"
        actionLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        actionLabel.textColor = AppTheme.primary
        actionLabel.isUserInteractionEnabled = true
        actionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openSubjectsTab))
        actionLabel.addGestureRecognizer(tapGesture)
        
        let stackView = UIStackView(arrangedSubviews: [emptyIcon, emptyLabel, actionLabel])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        emptyStateView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            emptyStateView.heightAnchor.constraint(equalToConstant: 50),
            
            stackView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: emptyStateView.centerYAnchor),
            
            emptyIcon.widthAnchor.constraint(equalToConstant: 20),
            emptyIcon.heightAnchor.constraint(equalToConstant: 20),
        ])
        
        return emptyStateView
    }
    
    @objc private func openSubjectsTab() {
        tabBarController?.selectedIndex = 1
    }
    
    
    private func createSubjectCard(subject: Subject, index: Int) -> UIView {
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        let cardBackground = UIView()
        cardBackground.layer.cornerRadius = 12
        cardBackground.clipsToBounds = true
        cardBackground.translatesAutoresizingMaskIntoConstraints = false
        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.layer.cornerRadius = 24
        iconContainer.clipsToBounds = true
        let iconService = SubjectIconService()
        let iconResult = iconService.getIconAndCategory(for: subject.name)
        let iconImageView = UIImageView()
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white
        iconImageView.image = UIImage(systemName: iconResult.iconName)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        let titleLabel = UILabel()
        titleLabel.text = subject.name
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .darkText
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let topicsCountLabel = UILabel()
        topicsCountLabel.font = .systemFont(ofSize: 13, weight: .medium)
        topicsCountLabel.translatesAutoresizingMaskIntoConstraints = false
        Task {
            let allTopics = try await topicsDb.findAll(where: ["subject":subject.id])
            let topicsCount = allTopics.count
            
            await MainActor.run {
                topicsCountLabel.text = "\(topicsCount) modules"
            }
        }
        
        let colorSchemes: [(main: UIColor, text: UIColor)] = [
            (AppTheme.primary.withAlphaComponent(0.1), AppTheme.primary.withAlphaComponent(0.8)),
            (AppTheme.secondary.withAlphaComponent(0.1), AppTheme.secondary.withAlphaComponent(0.8))
        ]
        
        let iconColorSchemes: [UIColor] = [
            AppTheme.primary,
            AppTheme.secondary
        ]
        
        let colorIndex = index % colorSchemes.count
        let mainColor = colorSchemes[colorIndex].main
        let iconColor = iconColorSchemes[colorIndex]
        
        cardBackground.backgroundColor = mainColor
        iconContainer.backgroundColor = iconColor
        topicsCountLabel.textColor = iconColorSchemes[colorIndex].withAlphaComponent(0.8)
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction { [weak self] _ in
            self?.performSegue(withIdentifier: "toSubjectDetails", sender: subject)
        }, for: .touchUpInside)
        
        
        containerView.addSubview(cardBackground)
        containerView.addSubview(button)
        cardBackground.addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        cardBackground.addSubview(titleLabel)
        cardBackground.addSubview(topicsCountLabel)
        
        NSLayoutConstraint.activate([
            
            containerView.heightAnchor.constraint(equalToConstant: 80),
            cardBackground.topAnchor.constraint(equalTo: containerView.topAnchor),
            cardBackground.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            cardBackground.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            cardBackground.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            iconContainer.leadingAnchor.constraint(equalTo: cardBackground.leadingAnchor, constant: 16),
            iconContainer.centerYAnchor.constraint(equalTo: cardBackground.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 48),
            iconContainer.heightAnchor.constraint(equalToConstant: 48),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: cardBackground.topAnchor, constant: 16),
            
            
            topicsCountLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            topicsCountLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            
            button.topAnchor.constraint(equalTo: containerView.topAnchor),
            button.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
    
    // MARK: RECENT MODULES
    
    
    // MARK: RECENT MODULES
        
    @objc private func SRseeAllButtonTapped() {
        performSegue(withIdentifier: "toSrListView", sender: nil)
    }

    @objc private func ARseeAllButtonTapped() {
        performSegue(withIdentifier: "toArListView", sender: nil)
    }

    @objc private func summaryseeAllButtonTapped() {
        performSegue(withIdentifier: "toSuListView", sender: nil)
    }

    private func createRecentModulesView() -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.08
        containerView.layer.shadowRadius = 8
        containerView.layer.shadowOffset = CGSize(width: 0, height: 3)
        
        // Section header with title and "See All" button
        let headerView = createSectionHeader(title: "Recent Modules")
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Standard segmented control instead of circular
        let segmentItems = ["Spaced Repetition", "Active Recall", "Summariser"]
        let segmentControl = UISegmentedControl(items: segmentItems)
        segmentControl.selectedSegmentIndex = 0
        
        // Improve segmented control appearance
        segmentControl.backgroundColor = UIColor.systemGray6
        segmentControl.selectedSegmentTintColor = AppTheme.primary
        segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.systemGray], for: .normal)
        segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        let selectedTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let normalTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
       
        
        if #available(iOS 13.0, *) {
            segmentControl.selectedSegmentTintColor = AppTheme.primary
        } else {
            segmentControl.tintColor = AppTheme.primary
        }
        
        segmentControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        
        // Container for module items
        let moduleItemsContainer = UIView()
        moduleItemsContainer.tag = 100 // Tag for referencing later
        moduleItemsContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Add all elements to container
        containerView.addSubview(headerView)
        containerView.addSubview(segmentControl)
        containerView.addSubview(moduleItemsContainer)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            segmentControl.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            segmentControl.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            segmentControl.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            segmentControl.heightAnchor.constraint(equalToConstant: 36),
            
            moduleItemsContainer.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 16),
            moduleItemsContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            moduleItemsContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            moduleItemsContainer.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
        
        // Initial load of Spaced Repetition content
        loadModuleItemsForType(.flashcards, container: moduleItemsContainer)
        
        return containerView
    }

    private func createSectionHeader(title: String) -> UIView {
        let headerView = UIView()
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Create a container for the See All buttons - we'll show/hide them as needed
        let buttonsContainer = UIView()
        buttonsContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Create separate buttons for each module type
        let srButton = createSeeAllButton(selector: #selector(SRseeAllButtonTapped), tag: 201)
        srButton.translatesAutoresizingMaskIntoConstraints = false
        
        let arButton = createSeeAllButton(selector: #selector(ARseeAllButtonTapped), tag: 202)
        arButton.translatesAutoresizingMaskIntoConstraints = false
        arButton.isHidden = true
        
        let summaryButton = createSeeAllButton(selector: #selector(summaryseeAllButtonTapped), tag: 203)
        summaryButton.translatesAutoresizingMaskIntoConstraints = false
        summaryButton.isHidden = true
        
        // Add all buttons to the container
        buttonsContainer.addSubview(srButton)
        buttonsContainer.addSubview(arButton)
        buttonsContainer.addSubview(summaryButton)
        
        // Position all buttons in the same spot
        NSLayoutConstraint.activate([
            srButton.topAnchor.constraint(equalTo: buttonsContainer.topAnchor),
            srButton.leadingAnchor.constraint(equalTo: buttonsContainer.leadingAnchor),
            srButton.trailingAnchor.constraint(equalTo: buttonsContainer.trailingAnchor),
            srButton.bottomAnchor.constraint(equalTo: buttonsContainer.bottomAnchor),
            
            arButton.topAnchor.constraint(equalTo: buttonsContainer.topAnchor),
            arButton.leadingAnchor.constraint(equalTo: buttonsContainer.leadingAnchor),
            arButton.trailingAnchor.constraint(equalTo: buttonsContainer.trailingAnchor),
            arButton.bottomAnchor.constraint(equalTo: buttonsContainer.bottomAnchor),
            
            summaryButton.topAnchor.constraint(equalTo: buttonsContainer.topAnchor),
            summaryButton.leadingAnchor.constraint(equalTo: buttonsContainer.leadingAnchor),
            summaryButton.trailingAnchor.constraint(equalTo: buttonsContainer.trailingAnchor),
            summaryButton.bottomAnchor.constraint(equalTo: buttonsContainer.bottomAnchor)
        ])
        
        headerView.addSubview(titleLabel)
        headerView.addSubview(buttonsContainer)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            
            buttonsContainer.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            buttonsContainer.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            buttonsContainer.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        return headerView
    }

    private func createSeeAllButton(selector: Selector, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("See All", for: .normal)
        button.setTitleColor(AppTheme.primary, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.tag = tag
        return button
    }

    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        // Update the visible "See All" button based on the selected segment
        if let srButton = view.viewWithTag(201),
           let arButton = view.viewWithTag(202),
           let summaryButton = view.viewWithTag(203) {
            
            srButton.isHidden = sender.selectedSegmentIndex != 0
            arButton.isHidden = sender.selectedSegmentIndex != 1
            summaryButton.isHidden = sender.selectedSegmentIndex != 2
        }
        
        // Update the module items
        if let container = view.viewWithTag(100) {
            let topicType: TopicsType
            
            switch sender.selectedSegmentIndex {
            case 0:
                topicType = .flashcards  // Spaced Repetition
            case 1:
                topicType = .quizzes     // Active Recall
            case 2:
                topicType = .summary     // Summariser
            default:
                topicType = .flashcards
            }
            
            loadModuleItemsForType(topicType, container: container)
        }
    }

    // Load items based on selected type
    private func loadModuleItemsForType(_ type: TopicsType, container: UIView) {
        // Clear existing content
        container.subviews.forEach { $0.removeFromSuperview() }
        
        // Filter topics by type
        let filteredTopics = allTopics.filter { $0.type == type }.prefix(3)
        
        if filteredTopics.isEmpty {
            let emptyView = createEmptyModuleView(for: type)
            container.addSubview(emptyView)
            
            NSLayoutConstraint.activate([
                emptyView.topAnchor.constraint(equalTo: container.topAnchor),
                emptyView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                emptyView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                emptyView.heightAnchor.constraint(equalToConstant: 80),
                emptyView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
        } else {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 12
            stackView.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(stackView)
            
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: container.topAnchor),
                stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
            
            // Convert topics to schedule items and add to stack
            for (index, topic) in filteredTopics.enumerated() {
                let iconName = type == .flashcards ? "clock" : type == .quizzes ? "brain.head.profile" : "doc.text"
                
                let item = ScheduleItem(
                    iconName: iconName,
                    title: topic.title,
                    subtitle: topic.subtitle,
                    progress: Float.random(in: 0...1), // Keeping this for data structure compatibility
                    topicType: type,
                    topicId: topic.id
                )
                
                let itemView = createModuleItemView(for: item, index: index)
                stackView.addArrangedSubview(itemView)
            }
        }
    }

    private func createEmptyModuleView(for type: TopicsType) -> UIView {
        let emptyContainer = UIView()
        emptyContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let iconName: String
        let message: String
        
        switch type {
        case .flashcards:
            iconName = "clock"
            message = "No modules yet.\n"
        case .quizzes:
            iconName = "brain.head.profile"
            message = "No modules yet.\n"
        case .summary:
            iconName = "doc.text"
            message = "No modules yet.\n"
        }
        
        let emptyIcon = UIImageView(image: UIImage(systemName: iconName))
        emptyIcon.tintColor = AppTheme.primary
        emptyIcon.contentMode = .scaleAspectFit
        emptyIcon.translatesAutoresizingMaskIntoConstraints = false
        
        let emptyLabel = UILabel()
        emptyLabel.text = message
        emptyLabel.font = .systemFont(ofSize: 15, weight: .medium)
        emptyLabel.textColor = .darkGray
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let createButton = UIButton()
        createButton.setTitle("Create New", for: .normal)
        createButton.setTitleColor(AppTheme.primary, for: .normal)
        createButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        createButton.layer.cornerRadius = 14
        createButton.contentEdgeInsets = UIEdgeInsets(top: 5, left:0, bottom: 5, right: 10)
        createButton.addTarget(self, action: #selector(uploadPDFButtonTapped), for: .touchUpInside)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [emptyIcon, emptyLabel, createButton])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        emptyContainer.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: emptyContainer.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: emptyContainer.centerYAnchor),
            
            emptyIcon.widthAnchor.constraint(equalToConstant: 24),
            emptyIcon.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        return emptyContainer
    }

    private func createModuleItemView(for item: ScheduleItem, index: Int) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let isPrimary = index % 2 == 0
        let mainColor = isPrimary ? AppTheme.primary : AppTheme.secondary
        
        let cardBackground = UIView()
        cardBackground.layer.cornerRadius = 12
        cardBackground.clipsToBounds = true
        cardBackground.backgroundColor = mainColor.withAlphaComponent(0.1)
        cardBackground.translatesAutoresizingMaskIntoConstraints = false
        
        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.layer.cornerRadius = 24
        iconContainer.clipsToBounds = true
        iconContainer.backgroundColor = mainColor
        
        let iconView = UIImageView()
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .white
        iconView.image = UIImage(systemName: item.iconName)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = item.title
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .darkText
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = item.subtitle
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.textColor = mainColor.withAlphaComponent(0.8)
        
        let subjectTag = UILabel()
        subjectTag.font = .systemFont(ofSize: 12, weight: .medium)
        subjectTag.text = " "
        subjectTag.textColor = mainColor.withAlphaComponent(0.8)
        subjectTag.backgroundColor = mainColor.withAlphaComponent(0.1)
        subjectTag.layer.cornerRadius = 8
        subjectTag.clipsToBounds = true
        subjectTag.translatesAutoresizingMaskIntoConstraints = false
        subjectTag.setPadding(horizontal: 12, vertical: 4)
        
        // Add views to hierarchy
        containerView.addSubview(cardBackground)
        cardBackground.addSubview(iconContainer)
        iconContainer.addSubview(iconView)
        cardBackground.addSubview(titleLabel)
        cardBackground.addSubview(subtitleLabel)
        cardBackground.addSubview(subjectTag)
        
        NSLayoutConstraint.activate([
            // Card background constraints
            cardBackground.topAnchor.constraint(equalTo: containerView.topAnchor),
            cardBackground.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            cardBackground.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            cardBackground.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            cardBackground.heightAnchor.constraint(equalToConstant: 95),
            
            // Icon container constraints
            iconContainer.topAnchor.constraint(equalTo: cardBackground.topAnchor, constant: 16),
            iconContainer.leadingAnchor.constraint(equalTo: cardBackground.leadingAnchor, constant: 16),
            iconContainer.widthAnchor.constraint(equalToConstant: 48),
            iconContainer.heightAnchor.constraint(equalToConstant: 48),
            
            // Icon view constraints
            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            
            // Title label constraints
            titleLabel.topAnchor.constraint(equalTo: cardBackground.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardBackground.trailingAnchor, constant: -16),
            
            // Subtitle label constraints
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            // Subject tag constraints
            subjectTag.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 8),
            subjectTag.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor)
        ])
        
        // Add tap gesture recognizer with animation
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(moduleItemTapped(_:)))
        cardBackground.addGestureRecognizer(tapGesture)
        cardBackground.isUserInteractionEnabled = true
        viewTopicIds[cardBackground] = item.topicId
        
        // Asynchronously load subject name
        Task {
            let alltopics = try await topicsDb.findAll(where: ["id": item.topicId])
            if let topic = alltopics.first {
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

    // Handle module item tap
    @objc private func moduleItemTapped(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        // Animate tap
        UIView.animate(withDuration: 0.1) {
            view.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        } completion: { _ in
            UIView.animate(withDuration: 0.1) {
                view.transform = .identity
            }
        }
        // Find topic by ID and navigate
        if let tappedView = sender.view, let topicId = viewTopicIds[tappedView] {
            Task {
                let topic = try await topicsDb.findAll(where: ["id": topicId]).first
                
                if let topic = topic {
                    let segueIdentifier = topic.type == .flashcards ? "toFLS" :
                    topic.type == .quizzes ? "toQTS" : "toSummary"
                    self.performSegue(withIdentifier: segueIdentifier, sender: topic)
                }
            }
        }
    }
    
    
}
