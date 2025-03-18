import UIKit

class ProgressViewController: UIViewController {
    private var studyProgress: StudyProgress?
    private let itemsPerLevel = 10 //
    private var allTopics:[Schedule] = []
    private var totalCompletedTopics:[Schedule]{
        return allTopics.filter { card in
            let matchesSegment = card.completed != nil
            return matchesSegment
        }
    }
    private var totalQuestions:[Schedule] {
        return allTopics.filter { card in
            let matchesSegment = card.topicType  == TopicsType.quizzes
            return matchesSegment
        }
    }
    private var totalflashcards:[Schedule] {
        return allTopics.filter { card in
            let matchesSegment = card.topicType  == TopicsType.flashcards
            return matchesSegment
        }
    }
    private var totalSummary:[Schedule] {
        return allTopics.filter { card in
            let matchesSegment = card.topicType  == TopicsType.summary
            return matchesSegment
        }
    }
    
    private var completedQuestions:[Schedule]{
        return totalQuestions.filter { card in
            let matchesSegment = card.completed != nil
            return matchesSegment
        }
    }
    private var completedFlashcards:[Schedule]{
        return totalflashcards.filter { card in
            let matchesSegment = card.completed != nil
            return matchesSegment
        }
    }
    private var completedSummary:[Schedule]{
        return totalSummary.filter { card in
            let matchesSegment = card.completed != nil
            return matchesSegment
        }
    }
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let statsCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private let statsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let badgesTitle: UILabel = {
        let label = UILabel()
        label.text = "Your Badges"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let badgesContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.borderWidth = 1
        view.layer.borderColor = AppTheme.secondary.withAlphaComponent(0.2).cgColor
        return view
    }()
    
    private let badgesGridView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Fullscreen container for badge celebration
    private let badgeCelebrationView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Confetti emitter layer
    private var confettiLayer: CAEmitterLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupData()
        setupConstraints()
    }
    
    private func setupView() {
        view.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.99, alpha: 1.0)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(statsCardView)
        statsCardView.addSubview(statsStackView)
        
        contentView.addSubview(badgesTitle)
        contentView.addSubview(badgesContainerView)
        badgesContainerView.addSubview(badgesGridView)
        
        // Add badge celebration view to main view (not scroll view)
        view.addSubview(badgeCelebrationView)
        
        statsCardView.layer.borderWidth = 1
        statsCardView.layer.borderColor = AppTheme.secondary.withAlphaComponent(0.2).cgColor
    }
    
    private func setupData() {
        studyProgress = StudyProgress(
            flashcardsCompleted: 10,
            quizzesCompleted: 10,
            summarizersCompleted: 2,
            firstModuleCompleted: true
        )
        
        createProgressStats()
        createBadges()
    }
    
    private func setupConstraints() {
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
            
            statsCardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            statsCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statsCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            statsStackView.topAnchor.constraint(equalTo: statsCardView.topAnchor, constant: 20),
            statsStackView.leadingAnchor.constraint(equalTo: statsCardView.leadingAnchor, constant: 20),
            statsStackView.trailingAnchor.constraint(equalTo: statsCardView.trailingAnchor, constant: -20),
            statsStackView.bottomAnchor.constraint(equalTo: statsCardView.bottomAnchor, constant: -20),
            
            badgesTitle.topAnchor.constraint(equalTo: statsCardView.bottomAnchor, constant: 30),
            badgesTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 25),
            
            badgesContainerView.topAnchor.constraint(equalTo: badgesTitle.bottomAnchor, constant: 15),
            badgesContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            badgesContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            badgesContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            badgesGridView.topAnchor.constraint(equalTo: badgesContainerView.topAnchor, constant: 15),
            badgesGridView.leadingAnchor.constraint(equalTo: badgesContainerView.leadingAnchor, constant: 15),
            badgesGridView.trailingAnchor.constraint(equalTo: badgesContainerView.trailingAnchor, constant: -15),
            badgesGridView.bottomAnchor.constraint(equalTo: badgesContainerView.bottomAnchor, constant: -15),
            
            // Badge celebration view covers the entire screen
            badgeCelebrationView.topAnchor.constraint(equalTo: view.topAnchor),
            badgeCelebrationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            badgeCelebrationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            badgeCelebrationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func createProgressStats() {
        guard let progress = studyProgress else { return }
        Task{
            allTopics = try await schedulesDb.findAll()
            let totalItems = totalCompletedTopics.count
            let nextLevelProgress = Float(totalItems % itemsPerLevel) / Float(itemsPerLevel)
            
            let statsViews = [
                createStatView(icon: "rectangle.on.rectangle.fill", title: "Flashcards Completed", value: "\(completedFlashcards.count)"),
                createStatView(icon: "doc.questionmark.fill", title: "Quizzes Completed", value: "\(completedQuestions.count)"),
                createStatView(icon: "doc.text.fill", title: "Summaries Completed", value: "\(completedSummary.count)"),
                
                createProgressBar(title: "Progress for next badge", value: nextLevelProgress)
            ]
            
            statsViews.forEach { statsStackView.addArrangedSubview($0) }
        }
    }
    
    private func createStatView(icon: String, title: String, value: String) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = AppTheme.secondary.withAlphaComponent(0.05)
        backgroundView.layer.cornerRadius = 12
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView()
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = AppTheme.primary
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconBackground = UIView()
        iconBackground.backgroundColor = AppTheme.primary.withAlphaComponent(0.1)
        iconBackground.layer.cornerRadius = 20
        iconBackground.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .darkGray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        valueLabel.textColor = AppTheme.primary
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(backgroundView)
        containerView.addSubview(iconBackground)
        iconBackground.addSubview(iconView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalToConstant: 60),
            
            backgroundView.topAnchor.constraint(equalTo: containerView.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            iconBackground.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            iconBackground.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconBackground.widthAnchor.constraint(equalToConstant: 40),
            iconBackground.heightAnchor.constraint(equalToConstant: 40),
            
            iconView.centerXAnchor.constraint(equalTo: iconBackground.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBackground.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconBackground.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            
            valueLabel.leadingAnchor.constraint(equalTo: iconBackground.trailingAnchor, constant: 16),
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4)
        ])
        
        return containerView
    }
    
    private func createProgressBar(title: String, value: Float) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = AppTheme.secondary.withAlphaComponent(0.05)
        backgroundView.layer.cornerRadius = 12
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let percentageLabel = UILabel()
        percentageLabel.text = "\(Int(value * 100))%"
        percentageLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        percentageLabel.textColor = AppTheme.primary
        percentageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let progressBar = UIProgressView()
        progressBar.progressTintColor = AppTheme.primary
        progressBar.trackTintColor = AppTheme.secondary.withAlphaComponent(0.2)
        progressBar.progress = value
        progressBar.layer.cornerRadius = 6
        progressBar.clipsToBounds = true
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.transform = CGAffineTransform(scaleX: 1, y: 2)
        
        containerView.addSubview(backgroundView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(percentageLabel)
        containerView.addSubview(progressBar)
        
        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalToConstant: 90),
            
            backgroundView.topAnchor.constraint(equalTo: containerView.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            percentageLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15),
            percentageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 16),
            percentageLabel.leadingAnchor.constraint(equalTo:    titleLabel.trailingAnchor, constant: 16),
            
            
            progressBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
                        progressBar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
                        progressBar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
                        progressBar.heightAnchor.constraint(equalToConstant: 12),
                    ])
                    
                    return containerView
                }
                
                private func createBadges() {
                    // Define badges with their level requirements
                    let badgeDefinitions = [
                        (name: "Beginner", icon: "star.fill", level: 1, color: AppTheme.primary),
                        (name: "Intermediate", icon: "star.leadinghalf.filled", level: 2, color: AppTheme.secondary),
                        (name: "Advanced", icon: "star.circle.fill", level: 3, color: UIColor(red: 0.2, green: 0.6, blue: 0.4, alpha: 1.0)),
                        (name: "Expert", icon: "star.square.fill", level: 4, color: UIColor(red: 0.8, green: 0.4, blue: 0.2, alpha: 1.0)),
                        (name: "Master", icon: "star.circle", level: 5, color: UIColor(red: 0.6, green: 0.2, blue: 0.8, alpha: 1.0)),
                        (name: "Grandmaster", icon: "rosette", level: 6, color: UIColor(red: 0.8, green: 0.7, blue: 0.2, alpha: 1.0))
                    ]
                    
                    // Calculate badge size and spacing
                    let containerWidth = UIScreen.main.bounds.width - 70 // Accounting for padding
                    let badgeSize: CGFloat = containerWidth / 3 - 10
                    let spacing: CGFloat = 16
                    
                    // Calculate user's current level
                    guard let progress = studyProgress else { return }
                    let totalItems = totalCompletedTopics.count
                    let userLevel = (totalItems / itemsPerLevel) + (progress.firstModuleCompleted ? 1 : 0)
                    
                    // Create and position each badge
                    for (index, badge) in badgeDefinitions.enumerated() {
                        let row = index / 3
                        let col = index % 3
                        let isUnlocked = userLevel >= badge.level
                        
                        let badgeView = createBadgeView(
                            name: badge.name,
                            icon: badge.icon,
                            level: badge.level,
                            color: badge.color,
                            unlocked: isUnlocked,
                            size: badgeSize
                        )
                        
                        badgesGridView.addSubview(badgeView)
                        
                        badgeView.translatesAutoresizingMaskIntoConstraints = false
                        NSLayoutConstraint.activate([
                            badgeView.topAnchor.constraint(equalTo: badgesGridView.topAnchor, constant: CGFloat(row) * (badgeSize + spacing)),
                            badgeView.leadingAnchor.constraint(equalTo: badgesGridView.leadingAnchor, constant: CGFloat(col) * (badgeSize + spacing)),
                            badgeView.widthAnchor.constraint(equalToConstant: badgeSize),
                            badgeView.heightAnchor.constraint(equalToConstant: badgeSize)
                        ])
                        
                        // Set the bottom constraint for the last row
                        if row == badgeDefinitions.count / 3 - 1 || index == badgeDefinitions.count - 1 {
                            badgeView.bottomAnchor.constraint(equalTo: badgesGridView.bottomAnchor).isActive = true
                        }
                        
                        // Add tap gesture to unlocked badges
                        if isUnlocked {
                            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(badgeTapped(_:)))
                            badgeView.isUserInteractionEnabled = true
                            badgeView.addGestureRecognizer(tapGesture)
                            badgeView.tag = badge.level // Store the badge level in the tag
                        }
                    }
                }
                
                private func createBadgeView(name: String, icon: String, level: Int, color: UIColor, unlocked: Bool, size: CGFloat) -> UIView {
                    let containerView = UIView()
                    containerView.layer.cornerRadius = size / 4
                    containerView.clipsToBounds = true
                    
                    // Badge background
                    containerView.backgroundColor = unlocked ? color.withAlphaComponent(0.15) : UIColor.lightGray.withAlphaComponent(0.1)
                    
                    // Badge icon
                    let iconView = UIImageView()
                    iconView.image = UIImage(systemName: icon)
                    iconView.tintColor = unlocked ? color : UIColor.gray.withAlphaComponent(0.5)
                    iconView.contentMode = .scaleAspectFit
                    iconView.translatesAutoresizingMaskIntoConstraints = false
                    
                    // Badge name label
                    let nameLabel = UILabel()
                    nameLabel.text = name
                    nameLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
                    nameLabel.textColor = unlocked ? color : UIColor.gray.withAlphaComponent(0.6)
                    nameLabel.textAlignment = .center
                    nameLabel.numberOfLines = 1
                    nameLabel.translatesAutoresizingMaskIntoConstraints = false
                    
                    // Level label
                    let levelLabel = UILabel()
                    levelLabel.text = "Level \(level)"
                    levelLabel.font = UIFont.systemFont(ofSize: 10, weight: .regular)
                    levelLabel.textColor = unlocked ? color : UIColor.gray.withAlphaComponent(0.6)
                    levelLabel.textAlignment = .center
                    levelLabel.translatesAutoresizingMaskIntoConstraints = false
                    
                    // Lock icon for locked badges
                    let lockView = UIImageView()
                    lockView.tintColor = UIColor.gray.withAlphaComponent(0.7)
                    lockView.contentMode = .scaleAspectFit
                    lockView.translatesAutoresizingMaskIntoConstraints = false
                    lockView.isHidden = unlocked
                    
                    containerView.addSubview(iconView)
                    containerView.addSubview(nameLabel)
                    containerView.addSubview(levelLabel)
                    containerView.addSubview(lockView)
                    
                    NSLayoutConstraint.activate([
                        iconView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
                        iconView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                        iconView.widthAnchor.constraint(equalToConstant: size / 2.5),
                        iconView.heightAnchor.constraint(equalToConstant: size / 2.5),
                        
                        nameLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 6),
                        nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 4),
                        nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -4),
                        
                        levelLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
                        levelLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 4),
                        levelLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -4),
                        
                        lockView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                        lockView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                        lockView.widthAnchor.constraint(equalToConstant: size / 3),
                        lockView.heightAnchor.constraint(equalToConstant: size / 3)
                    ])
                    
                    return containerView
                }
                
                @objc private func badgeTapped(_ gesture: UITapGestureRecognizer) {
                    guard let badgeView = gesture.view else { return }
                    
                    // Create a snapshot of the badge to animate
                    guard let badgeSnapshot = badgeView.snapshotView(afterScreenUpdates: false) else { return }
                    
                    // Calculate coordinates for placing the snapshot in the main view
                    let badgeFrameInWindow = badgeView.convert(badgeView.bounds, to: nil)
                    
                    badgeCelebrationView.alpha = 0
                    badgeCelebrationView.isHidden = false
                    
                    // Add the badge snapshot to the celebration container
                    badgeCelebrationView.addSubview(badgeSnapshot)
                    badgeSnapshot.frame = badgeFrameInWindow
                    
                    // Configure badge level label
                    let levelLabel = UILabel()
                    levelLabel.text = "Level \(badgeView.tag)"
                    levelLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
                    levelLabel.textColor = .black
                    levelLabel.textAlignment = .center
                    levelLabel.translatesAutoresizingMaskIntoConstraints = false
                    
                    // Configure badge description label
                    let descriptionLabel = UILabel()
                    descriptionLabel.text = "Congratulations! You've achieved this badge."
                    descriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
                    descriptionLabel.textColor = .black
                    descriptionLabel.textAlignment = .center
                    descriptionLabel.numberOfLines = 0
                    descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
                    
                    // Configure close button
                    let closeButton = UIButton(type: .system)
                    closeButton.setTitle("Close", for: .normal)
                    closeButton.setTitleColor(.white, for: .normal)
                    closeButton.backgroundColor = AppTheme.primary
                    closeButton.layer.cornerRadius = 20
                    closeButton.translatesAutoresizingMaskIntoConstraints = false
                    closeButton.addTarget(self, action: #selector(dismissBadgeCelebration), for: .touchUpInside)
                    
                    badgeCelebrationView.addSubview(levelLabel)
                    badgeCelebrationView.addSubview(descriptionLabel)
                    badgeCelebrationView.addSubview(closeButton)
                    
                    NSLayoutConstraint.activate([
                        levelLabel.topAnchor.constraint(equalTo: badgeCelebrationView.centerYAnchor, constant: 80),
                        levelLabel.centerXAnchor.constraint(equalTo: badgeCelebrationView.centerXAnchor),
                        
                        descriptionLabel.topAnchor.constraint(equalTo: levelLabel.bottomAnchor, constant: 20),
                        descriptionLabel.leadingAnchor.constraint(equalTo: badgeCelebrationView.leadingAnchor, constant: 40),
                        descriptionLabel.trailingAnchor.constraint(equalTo: badgeCelebrationView.trailingAnchor, constant: -40),
                        
                        closeButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 30),
                        closeButton.centerXAnchor.constraint(equalTo: badgeCelebrationView.centerXAnchor),
                        closeButton.widthAnchor.constraint(equalToConstant: 120),
                        closeButton.heightAnchor.constraint(equalToConstant: 44)
                    ])
                    
                    // Animate showing the celebration view
                    UIView.animate(withDuration: 0.3) {
                        self.badgeCelebrationView.alpha = 1
                    }
                    
                    // Animate the badge snapshot to the center and make it larger
                    UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
                        let targetSize = CGSize(width: 150, height: 150)
                        badgeSnapshot.frame = CGRect(
                            x: (self.view.bounds.width - targetSize.width) / 2,
                            y: (self.view.bounds.height - targetSize.height) / 2 - 80,
                            width: targetSize.width,
                            height: targetSize.height
                        )
                    }, completion: { _ in
                        self.showConfetti()
                    })
                }
                
                @objc private func dismissBadgeCelebration() {
                    // Remove confetti
                    confettiLayer?.removeFromSuperlayer()
                    confettiLayer = nil
                    
                    // Animate hiding the celebration view
                    UIView.animate(withDuration: 0.3, animations: {
                        self.badgeCelebrationView.alpha = 0
                    }, completion: { _ in
                        // Remove all subviews when hidden
                        for subview in self.badgeCelebrationView.subviews {
                            subview.removeFromSuperview()
                        }
                        self.badgeCelebrationView.isHidden = true
                    })
                }
                
                private func showConfetti() {
                    // Create a new emitter layer
                    let emitterLayer = CAEmitterLayer()
                    confettiLayer = emitterLayer
                    
                    emitterLayer.emitterPosition = CGPoint(x: view.bounds.width / 2, y: -50)
                    emitterLayer.emitterShape = .line
                    emitterLayer.emitterSize = CGSize(width: view.bounds.width, height: 1)
                    
                    // Create confetti particles
                    var cells = [CAEmitterCell]()
                    let colors = [UIColor.red, UIColor.green, UIColor.blue, UIColor.yellow, UIColor.purple, UIColor.orange]
                    
                    for color in colors {
                        let cell = CAEmitterCell()
                        cell.birthRate = 5
                        cell.lifetime = 8
                        cell.velocity = 150
                        cell.velocityRange = 100
                        cell.emissionLongitude = .pi
                        cell.emissionRange = .pi / 4
                        cell.spin = 3.5
                        cell.spinRange = 1
                        cell.scaleRange = 0.25
                        cell.scaleSpeed = -0.1
                        
                        // Create a small rectangle shape for confetti
                        let size = CGSize(width: 10, height: 5)
                        UIGraphicsBeginImageContext(size)
                        let context = UIGraphicsGetCurrentContext()!
                        context.setFillColor(color.cgColor)
                        context.fill(CGRect(origin: .zero, size: size))
                        let image = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext()
                        
                        cell.contents = image?.cgImage
                        cells.append(cell)
                    }
                    
                    emitterLayer.emitterCells = cells
                    badgeCelebrationView.layer.addSublayer(emitterLayer)
                    
                    // Stop emitting after 2 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        emitterLayer.birthRate = 0
                    }
                }
            }

           
