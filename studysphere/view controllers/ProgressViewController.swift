import UIKit
import DGCharts
import Charts


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
    
    private let streakLineChartView = LineChartView()


    private let retentionChartTitle: UILabel = {
        let label = UILabel()
        label.text = "Retention Score"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
    
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let retentionChartView: UIView = {
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
    
    private let timeRangeSegmentedControl: UISegmentedControl = {
        let items = ["7 Days", "30 Days", "All Time"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let chartContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    struct RetentionData {
        let date: Date
        let score: Double
    } // move to datatype file later
    
    private var retentionData: [RetentionData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupData()
        setupConstraints()
        setupRetentionChart()
    }
    
    private func setupView() {
        view.backgroundColor = .systemGray6
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add stats card
        contentView.addSubview(statsCardView)
        statsCardView.addSubview(statsStackView)
        
        // Add badges section
        contentView.addSubview(badgesTitle)
        contentView.addSubview(badgesContainerView)
        badgesContainerView.addSubview(badgesGridView)
        
        // Add celebration view to main view (not scroll view)
        view.addSubview(badgeCelebrationView)
        
        statsCardView.layer.borderWidth = 1
        statsCardView.layer.borderColor = AppTheme.secondary.withAlphaComponent(0.2).cgColor
    }
    private func createChartContainer(
            title: String, chartView: UIView, container: UIView
        ) {
            container.backgroundColor = AppTheme.secondary.withAlphaComponent(0.1)
            container.layer.cornerRadius = 10
            container.layer.shadowColor = UIColor.black.cgColor
            container.layer.shadowOffset = CGSize(width: 0, height: 2)
            container.layer.shadowRadius = 4
            container.layer.shadowOpacity = 0.1

            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false

            chartView.translatesAutoresizingMaskIntoConstraints = false

            container.addSubview(chartView)

            NSLayoutConstraint.activate([
                chartView.topAnchor.constraint(
                    equalTo: container.topAnchor, constant: 8),
                chartView.leadingAnchor.constraint(
                    equalTo: container.leadingAnchor, constant: 8),
                chartView.trailingAnchor.constraint(
                    equalTo: container.trailingAnchor, constant: -8),
                chartView.bottomAnchor.constraint(
                    equalTo: container.bottomAnchor, constant: -16),
            ])

        }
    private func configureStreakLineChart(
            lineChart: LineChartView, topic: TopicsType
        ) async {
            lineChart.xAxis.drawGridLinesEnabled = false
            lineChart.leftAxis.drawGridLinesEnabled = false
            lineChart.rightAxis.drawGridLinesEnabled = false
            
            lineChart.xAxis.labelTextColor = .black
            lineChart.leftAxis.labelTextColor = .black
            lineChart.rightAxis.labelTextColor = .black
            lineChart.legend.textColor = .black
            

            do {
                let chartData = try await getStreakChartData(topic: topic)

                let questionsEntries = chartData.questions.enumerated().map {
                    index, value in
                    return ChartDataEntry(x: Double(index), y: Double(value))
                }

                let questionsDataSet = LineChartDataSet(
                    entries: questionsEntries, label: "Spaced Repetition     ")
                questionsDataSet.colors = [AppTheme.primary.withAlphaComponent(0.5)]
                questionsDataSet.circleColors = [
                    AppTheme.primary.withAlphaComponent(0.5)
                ]
                questionsDataSet.lineWidth = 2
                questionsDataSet.circleRadius = 4
                questionsDataSet.drawCircleHoleEnabled = false
                questionsDataSet.mode = .linear

                let flashcardsEntries = chartData.flashcards.enumerated().map {
                    index, value in
                    return ChartDataEntry(x: Double(index), y: Double(value))
                }

                let flashcardsDataSet = LineChartDataSet(
                    entries: flashcardsEntries, label: "Active Recall")
                flashcardsDataSet.colors = [AppTheme.primary]
                flashcardsDataSet.circleColors = [AppTheme.primary]
                flashcardsDataSet.lineWidth = 2
                flashcardsDataSet.circleRadius = 4
                flashcardsDataSet.drawCircleHoleEnabled = false
                flashcardsDataSet.mode = .linear

                questionsDataSet.drawValuesEnabled = false

                flashcardsDataSet.drawValuesEnabled = false

                let data = LineChartData(dataSets: [
                    questionsDataSet, flashcardsDataSet,
                ])
                data.setValueFont(.systemFont(ofSize: 10))

                lineChart.data = data
                lineChart.xAxis.valueFormatter = IndexAxisValueFormatter(
                    values: chartData.days)
                lineChart.xAxis.granularity = 1
                lineChart.xAxis.labelPosition = .bottom
                lineChart.rightAxis.enabled = false
                lineChart.legend.font = .systemFont(ofSize: 12)
                lineChart.animate(
                    xAxisDuration: 1.0, easingOption: .easeInOutSine)
            } catch {
                print("Error fetching streak chart data: \(error)")
            }
        }
    private func getStreakChartData(
            topic: TopicsType, for timeInterval: Calendar.Component = .day
        )
            async throws -> (days: [String], questions: [Int], flashcards: [Int])
        {
            let today = Calendar.current.startOfDay(for: Date())
            var dayLabels: [String] = []
            var questionValues: [Int] = []
            var flashcardValues: [Int] = []

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE"

            for dayOffset in (0...6).reversed() {
                let currentDate = Calendar.current.date(
                    byAdding: .day, value: -dayOffset, to: today)!

                let dayLabel = dateFormatter.string(from: currentDate)
                dayLabels.append(dayLabel)

                let startOfDay = Calendar.current.startOfDay(for: currentDate)
                let endOfDay = Calendar.current.date(
                    byAdding: .day, value: 1, to: startOfDay)!.addingTimeInterval(
                        -1)

                let questionCount = try await getCountForDay(
                    type: .flashcards,
                    startDate: startOfDay,
                    endDate: endOfDay,
                    completed: false
                )
                questionValues.append(questionCount)

                let flashcardCount = try await getCountForDay(
                    type: .quizzes,
                    startDate: startOfDay,
                    endDate: endOfDay,
                    completed: true
                )
                flashcardValues.append(flashcardCount)
            }

            return (
                days: dayLabels, questions: questionValues,
                flashcards: flashcardValues
            )
        }
    private func getCountForDay(
        type: TopicsType, startDate: Date, endDate: Date, completed: Bool
    ) async throws -> Int {
        let schedules = try await scoreDb.findAll()
        var count = 0
        var total = 0
        for schedule in schedules {
            let scheduleDate = schedule.createdAt.dateValue()
            
            // Skip if date is outside range
            guard scheduleDate >= startDate && scheduleDate <= endDate else {
                continue
            }
            
            guard let topic = try? await topicsDb.findAll(where: ["id": schedule.topicId]).first,
                  topic.type == type else {
                continue
            }
            
            count += schedule.score
            total += schedule.total
        }
        if(total == 0){
            return 0
        }
        return Int((Float(count)/Float(total)) * 100)
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
            // Scroll view constraints
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Stats card view constraints
            statsCardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            statsCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statsCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Stats stack view constraints
            statsStackView.topAnchor.constraint(equalTo: statsCardView.topAnchor, constant: 20),
            statsStackView.leadingAnchor.constraint(equalTo: statsCardView.leadingAnchor, constant: 20),
            statsStackView.trailingAnchor.constraint(equalTo: statsCardView.trailingAnchor, constant: -20),
            statsStackView.bottomAnchor.constraint(equalTo: statsCardView.bottomAnchor, constant: -20),
            
            // Badges title constraints
            badgesTitle.topAnchor.constraint(equalTo: statsCardView.bottomAnchor, constant: 30),
            badgesTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 25),
            
            // Badges container view constraints
            badgesContainerView.topAnchor.constraint(equalTo: badgesTitle.bottomAnchor, constant: 15),
            badgesContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            badgesContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Badges grid view constraints
            badgesGridView.topAnchor.constraint(equalTo: badgesContainerView.topAnchor, constant: 15),
            badgesGridView.leadingAnchor.constraint(equalTo: badgesContainerView.leadingAnchor, constant: 15),
            badgesGridView.trailingAnchor.constraint(equalTo: badgesContainerView.trailingAnchor, constant: -15),
            badgesGridView.bottomAnchor.constraint(equalTo: badgesContainerView.bottomAnchor, constant: -15),
            
            // Badge celebration view constraints (full screen)
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
                createStatView(icon: "clock", title: "Flashcards Completed", value: "\(completedFlashcards.count)"),
                createStatView(icon: "brain.head.profile", title: "Quizzes Completed", value: "\(completedQuestions.count)"),
                createStatView(icon: "doc.text", title: "Summaries Completed", value: "\(completedSummary.count)"),
                
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
     
        let badgeDefinitions = [
            (name: "Beginner", icon: "star.leadinghalf.filled", level: 1, color: AppTheme.primary),
            (name: "Intermediate", icon: "star.fill", level: 2, color: AppTheme.secondary),
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
        
        guard let badgeSnapshot = badgeView.snapshotView(afterScreenUpdates: false) else { return }
        let badgeLevel = badgeView.tag
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
    
    private func setupRetentionChart() {
        // Create a container view for the entire stats section
        let statsContainer = UIView()
        statsContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statsContainer)
        
        statsContainer.addSubview(retentionChartTitle)
        statsContainer.addSubview(retentionChartView)
        retentionChartView.addSubview(timeRangeSegmentedControl)
        retentionChartView.addSubview(chartContainer)
        
        timeRangeSegmentedControl.addTarget(self, action: #selector(timeRangeChanged), for: .valueChanged)
        
        // Update constraints to properly position everything
        NSLayoutConstraint.activate([
            // Stats container constraints - position it after badges container
            statsContainer.topAnchor.constraint(equalTo: badgesContainerView.bottomAnchor, constant: 30),
            statsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            statsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            statsContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // Retention chart title constraints
            retentionChartTitle.topAnchor.constraint(equalTo: statsContainer.topAnchor),
            retentionChartTitle.leadingAnchor.constraint(equalTo: statsContainer.leadingAnchor, constant: 25),
            
            // Retention chart view constraints
            retentionChartView.topAnchor.constraint(equalTo: retentionChartTitle.bottomAnchor, constant: 15),
            retentionChartView.leadingAnchor.constraint(equalTo: statsContainer.leadingAnchor, constant: 20),
            retentionChartView.trailingAnchor.constraint(equalTo: statsContainer.trailingAnchor, constant: -20),
            retentionChartView.heightAnchor.constraint(equalToConstant: 300),
            retentionChartView.bottomAnchor.constraint(equalTo: statsContainer.bottomAnchor, constant: -20),
            
            // Time range segmented control constraints
            timeRangeSegmentedControl.topAnchor.constraint(equalTo: retentionChartView.topAnchor, constant: 15),
            timeRangeSegmentedControl.leadingAnchor.constraint(equalTo: retentionChartView.leadingAnchor, constant: 15),
            timeRangeSegmentedControl.trailingAnchor.constraint(equalTo: retentionChartView.trailingAnchor, constant: -15),
            
            // Chart container constraints
            chartContainer.topAnchor.constraint(equalTo: timeRangeSegmentedControl.bottomAnchor, constant: 15),
            chartContainer.leadingAnchor.constraint(equalTo: retentionChartView.leadingAnchor, constant: 15),
            chartContainer.trailingAnchor.constraint(equalTo: retentionChartView.trailingAnchor, constant: -15),
            chartContainer.bottomAnchor.constraint(equalTo: retentionChartView.bottomAnchor, constant: -15)
        ])
        
        Task{
            createChartContainer(
                title: "Spaced Repetition", chartView: streakLineChartView,
                container: chartContainer)
            await configureStreakLineChart(
                lineChart: streakLineChartView, topic: TopicsType.flashcards)
        }
    }
    
    private func loadRetentionData() {
        // This is sample data - replace with your actual data source
        let calendar = Calendar.current
        var data: [RetentionData] = []
        let today = Date()
        
        for day in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -day, to: today) {
                let score = Double.random(in: 60...95)
                data.append(RetentionData(date: date, score: score))
            }
        }
        
        retentionData = data.sorted { $0.date < $1.date }
    }
    
    @objc private func timeRangeChanged() {
//        updateChart()

    }
    
    private func updateChart() {
        chartContainer.subviews.forEach { $0.removeFromSuperview() }
        
        let calendar = Calendar.current
        let today = Date()
        var filteredData: [RetentionData]
        
        switch timeRangeSegmentedControl.selectedSegmentIndex {
        case 0: // 7 Days
            filteredData = retentionData.filter {
                calendar.dateComponents([.day], from: $0.date, to: today).day ?? 0 <= 7
            }
        case 1: // 30 Days
            filteredData = retentionData.filter {
                calendar.dateComponents([.day], from: $0.date, to: today).day ?? 0 <= 30
            }
        default: // All Time
            filteredData = retentionData
        }
        
        createChart(with: filteredData)
    }
    
    private func createChart(with data: [RetentionData]) {
        let chartView = UIView()
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartContainer.addSubview(chartView)
        
        NSLayoutConstraint.activate([
            chartView.topAnchor.constraint(equalTo: chartContainer.topAnchor),
            chartView.leadingAnchor.constraint(equalTo: chartContainer.leadingAnchor),
            chartView.trailingAnchor.constraint(equalTo: chartContainer.trailingAnchor),
            chartView.bottomAnchor.constraint(equalTo: chartContainer.bottomAnchor)
        ])
        
        let path = UIBezierPath()
        let chartHeight = chartView.bounds.height
        let chartWidth = chartView.bounds.width
        
        // Fix: Use the array count instead of data.count
        let points = data.enumerated().map { index, dataPoint -> CGPoint in
            let x = CGFloat(index) / CGFloat(data.count - 1) * chartWidth
            let y = CGFloat(1 - (dataPoint.score / 100)) * chartHeight
            return CGPoint(x: x, y: y)
        }
        
        if let firstPoint = points.first {
            path.move(to: firstPoint)
            for point in points.dropFirst() {
                path.addLine(to: point)
            }
        }
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = AppTheme.primary.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 2
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = chartView.bounds
        gradientLayer.colors = [
            AppTheme.primary.withAlphaComponent(0.3).cgColor,
            AppTheme.primary.withAlphaComponent(0.0).cgColor
        ]
        
        let gradientMask = CAShapeLayer()
        let gradientPath = UIBezierPath(cgPath: path.cgPath)
        gradientPath.addLine(to: CGPoint(x: chartWidth, y: chartHeight))
        gradientPath.addLine(to: CGPoint(x: 0, y: chartHeight))
        gradientPath.close()
        gradientMask.path = gradientPath.cgPath
        
        gradientLayer.mask = gradientMask
        
        chartView.layer.addSublayer(gradientLayer)
        chartView.layer.addSublayer(shapeLayer)
        
        for (index, point) in points.enumerated() {
            let dotView = UIView(frame: CGRect(x: point.x - 4, y: point.y - 4, width: 8, height: 8))
            dotView.backgroundColor = AppTheme.primary
            dotView.layer.cornerRadius = 4
            chartView.addSubview(dotView)
            
            let scoreLabel = UILabel()
            scoreLabel.text = String(format: "%.0f%%", data[index].score)
            scoreLabel.font = UIFont.systemFont(ofSize: 10)
            scoreLabel.textColor = AppTheme.primary
            scoreLabel.translatesAutoresizingMaskIntoConstraints = false
            chartView.addSubview(scoreLabel)
            
            // Fix: Add proper constraints for the score label
            scoreLabel.frame = CGRect(
                x: point.x - 20,
                y: point.y - 20,
                width: 40,
                height: 16
            )
            scoreLabel.textAlignment = .center
        }
    }
}
