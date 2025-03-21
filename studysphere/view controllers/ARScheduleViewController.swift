import UIKit
import FirebaseCore
import FirebaseFirestore

class ARScheduleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: - Properties
    private var mySchedules: [Schedule] = []
    var topic: Topics?
    
    private var completedSchedules: [Schedule] {
        mySchedules.filter { $0.completed != nil }
    }
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .bar)
        progress.trackTintColor = AppTheme.secondary.withAlphaComponent(0.2)
        progress.progressTintColor = AppTheme.primary
        progress.layer.cornerRadius = 4
        progress.clipsToBounds = true
        progress.translatesAutoresizingMaskIntoConstraints = false
        return progress
    }()
    
    private let statsContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let retentionView = StatView(title: "Average Retention")
    private let nextReviewView = StatView(title: "Next Review")
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .systemBackground
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    // Back button removed
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.isTabBarHidden = false
        setup() // Refresh data when view appears
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Add subviews (backButton removed)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(progressView)
        view.addSubview(statsContainer)
        statsContainer.addArrangedSubview(retentionView)
       // statsContainer.addArrangedSubview(nextReviewView)
        view.addSubview(tableView)
        
        // Layout constraints (backButton constraints removed)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16), // Updated to attach to safeAreaLayoutGuide instead of backButton
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            progressView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            progressView.heightAnchor.constraint(equalToConstant: 8),
            
            statsContainer.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 24),
            statsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            statsContainer.heightAnchor.constraint(equalToConstant: 80),
            
            tableView.topAnchor.constraint(equalTo: statsContainer.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ReviewCell.self, forCellReuseIdentifier: "ReviewCell")
    }
    
    private func setup() {
        Task {
            if let topicId = topic?.id {
                mySchedules = try await schedulesDb.findAll(where: ["topic": topicId])
                let sortedSchedules = mySchedules.sorted { $0.date.dateValue() < $1.date.dateValue() }
                mySchedules = sortedSchedules
                
                // Update UI
                titleLabel.text = topic?.title ?? "Topic"
                updateProgress()
               // updateStats()
                tableView.reloadData()
                
                // Update topic status
                let countDiff = mySchedules.count - completedSchedules.count
                if countDiff == 0 {
                    subtitleLabel.text = "All schedules completed"
                    topic?.subtitle = "All schedules completed"
                    topic?.completed = Timestamp()
                } else {
                    subtitleLabel.text = "\(countDiff) revision remaining"
                    topic?.subtitle = "\(countDiff) revision remaining"
                }
                let allScores = try await scoreDb.findAll(where: ["topicId": topic!.id])
                if allScores.count > 0 {
                    let totalScore = allScores.reduce(0) { $0 + $1.score}
                    let totalTotal = allScores.reduce(0) { $0 + $1.total }
                    let totalPercentage = Double(totalScore)/Double(totalTotal)*100
                    retentionView.setValue("\(Int(totalPercentage))%")
                }
                else {
                    retentionView.setValue("0")
                }
                var topicsTemp = topic
                try await topicsDb.update(&topicsTemp!)
            }
        }
    }
    
    private func updateProgress() {
        let progress = mySchedules.isEmpty ? 0 : Float(completedSchedules.count) / Float(mySchedules.count)
        progressView.setProgress(progress, animated: true)
        subtitleLabel.text = "\(completedSchedules.count)/\(mySchedules.count) completed"
    }
    
    private func updateStats() {
        // Calculate retention (this is a placeholder - implement your actual retention calculation)
        let retention = "0%"
        retentionView.setValue(retention)
        
        // Calculate next review
        if let nextSchedule = mySchedules.first(where: { $0.completed == nil }) {
            let timeUntil = calculateTimeUntil(nextSchedule.date.dateValue())
            nextReviewView.setValue(timeUntil)
        } else {
            nextReviewView.setValue("N/A")
        }
    }
    
    // MARK: - Actions
    // backButtonTapped method removed
    
    private func startQuiz(at index: IndexPath) {
        performSegue(withIdentifier: "toQuestionVC", sender: mySchedules[index.row])
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toQuestionVC" {
            if let destinationVC = segue.destination as? QuestionViewController {
                destinationVC.topic = topic
                if let schedule = sender as? Schedule {
                    destinationVC.schedule = schedule
                    return
                }
                destinationVC.schedule = mySchedules[completedSchedules.count]
            }
        }
        
    }
    @IBAction func comeHereNow(segue: UIStoryboardSegue) {
        setup()
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mySchedules.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! ReviewCell
        let schedule = mySchedules[indexPath.row]
        
        cell.configure(
            day: indexPath.row + 1,
            date: schedule.date.dateValue(),
            isCompleted: schedule.completed != nil,
            schedule: schedule.id
        )
        
        cell.startButton.removeTarget(nil, action: nil, for: .touchUpInside)
        cell.startButton.addAction(UIAction { [weak self] _ in
            self?.startQuiz(at: indexPath)
        }, for: .touchUpInside)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
}

// MARK: - Supporting Views
class StatView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(titleLabel)
        addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])
    }
    
    func setValue(_ value: String) {
        valueLabel.text = value
    }
}

class ReviewCell: UITableViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 8
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowRadius = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let statusBar: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let statusIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let retentionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .countLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Review", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.addSubview(statusBar)
        containerView.addSubview(statusIcon)
        containerView.addSubview(titleLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(retentionLabel)
        containerView.addSubview(startButton)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            statusBar.topAnchor.constraint(equalTo: containerView.topAnchor),
            statusBar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            statusBar.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            statusBar.widthAnchor.constraint(equalToConstant: 4),
            
            statusIcon.leadingAnchor.constraint(equalTo: statusBar.trailingAnchor, constant: 12),
            statusIcon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            statusIcon.widthAnchor.constraint(equalToConstant: 24),
            statusIcon.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: statusIcon.trailingAnchor, constant: 12),
            
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            retentionLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            retentionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            startButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            startButton.trailingAnchor.constraint(equalTo: retentionLabel.leadingAnchor, constant: -12),
            startButton.widthAnchor.constraint(equalToConstant: 100),
            startButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    func configure(day: Int, date: Date, isCompleted: Bool, schedule: String) {
        titleLabel.text = "Review \(day)"
        dateLabel.text = formatDate(date)
        
        Task {
            if isCompleted {
                statusBar.backgroundColor = .systemGreen
                statusIcon.image = UIImage(systemName: "checkmark.circle")
                statusIcon.tintColor = .systemGreen
                startButton.setTitle("Retake", for: .normal)
                startButton.isHidden = false
                retentionLabel.isHidden = false
                
                // Get scores from database
                let allscores = try await scoreDb.findAll(where: ["scheduleId": schedule])
                if let score = allscores.first {
                    let percentage = (Double(score.score) / Double(score.total)) * 100
                    retentionLabel.text = "\(Int(percentage))%"
                }
                NSLayoutConstraint.activate([
                    startButton.widthAnchor.constraint(equalToConstant: 60),
                ])
            } else {
                let isToday = Calendar.current.isDateInToday(date)
                statusBar.backgroundColor = isToday ? .systemBlue : .systemGray5
                statusIcon.image = isToday ? UIImage(systemName: "arrow.right.circle") : UIImage(systemName: "circle.dashed")
                statusIcon.tintColor = isToday ? .systemBlue : .systemGray3
                startButton.isHidden = !isToday
                retentionLabel.isHidden = true
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM yyyy"
        return dateFormatter.string(from: date)
    }
}

// MARK: - Helper Functions
private func calculateTimeUntil(_ date: Date) -> String {
    let calendar = Calendar.current
    let now = Date()
    let components = calendar.dateComponents([.day, .hour], from: now, to: date)
    
    if let days = components.day, let hours = components.hour {
        if days > 0 {
            return "\(days)d \(hours)h"
        } else {
            return "\(hours)h"
        }
    }
    
    return "N/A"
}
