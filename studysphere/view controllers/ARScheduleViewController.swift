import UIKit
import FirebaseCore

class ARScheduleViewController: UIViewController, UITableViewDataSource {
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
        progress.trackTintColor = .main
        progress.progressTintColor = .systemOrange
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
    }
    private static func makeStatsStack(icon: String, title: String) -> UIStackView {
           let stack = UIStackView()
           stack.axis = .vertical
           stack.alignment = .center
           stack.spacing = 8
           
           let imageView = UIImageView(image: UIImage(systemName: icon))
           imageView.tintColor = .systemOrange
           imageView.contentMode = .scaleAspectFit
           imageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
           imageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
           
           let label = UILabel()
           label.text = title
           label.font = .systemFont(ofSize: 16)
           label.textColor = .secondaryLabel
           label.textAlignment = .center
           
           stack.addArrangedSubview(imageView)
           stack.addArrangedSubview(label)
           
           stack.translatesAutoresizingMaskIntoConstraints = false
           return stack
       }
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        
        // Add subviews
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(progressView)
        view.addSubview(statsContainer)
        statsContainer.addArrangedSubview(retentionView)
        statsContainer.addArrangedSubview(nextReviewView)
        view.addSubview(tableView)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
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
            print(topic)
            if var topic = topic{
                mySchedules = try await schedulesDb.findAll(where: ["topic": topic.id])
                let sortedSchedules = mySchedules.sorted { $0.date.dateValue() < $1.date.dateValue() }
                mySchedules = sortedSchedules
                
                // Update UI
                titleLabel.text = topic.title ?? "Sample Topic"
                updateProgress()
                updateStats()
                tableView.reloadData()
                
                // Update topic status
                let countDiff = mySchedules.count - completedSchedules.count
                if countDiff == 0 {
                    subtitleLabel.text = "All schedules completed"
                    topic.subtitle = "All schedules completed"
                    topic.completed = Timestamp()
                } else {
                    subtitleLabel.text = "\(countDiff) more to go"
                    topic.subtitle = "\(countDiff) more to go"
                }
                
                var topicsTemp = topic
                try await topicsDb.update(&topicsTemp)
            }
            
        }
    }
    
    private func updateProgress() {
        let progress = Float(completedSchedules.count) / Float(mySchedules.count)
        progressView.setProgress(progress, animated: true)
        subtitleLabel.text = "\(completedSchedules.count)/\(mySchedules.count) completed"
    }
    
    private func updateStats() {
        // Calculate retention (this is a placeholder - implement your actual retention calculation)
        let retention = "88%"
        retentionView.setValue(retention)
        
        // Calculate next review
        if let nextSchedule = mySchedules.first(where: { $0.completed == nil }) {
            let timeUntil = calculateTimeUntil(nextSchedule.date.dateValue())
            nextReviewView.setValue(timeUntil)
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toQuestionVCBtn" {
            if let destinationVC = segue.destination as? QuestionViewController {
                destinationVC.topic = topic
                if completedSchedules.count == mySchedules.count {
                    destinationVC.schedule = mySchedules.last!
                    return
                }
                destinationVC.schedule = mySchedules[completedSchedules.count]
            }
        }
        
        if segue.identifier == "toQuestionVC",
           let destinationVC = segue.destination as? QuestionViewController,
           let index = sender as? IndexPath {
            destinationVC.topic = topic
            destinationVC.schedule = mySchedules[index.row]
        }
    }
    
    @IBAction func comeHere(segue: UIStoryboardSegue) {
        setup()
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate & DataSource
extension ARScheduleViewController: UITableViewDelegate {
    @objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mySchedules.count
    }
    
    @objc(tableView:cellForRowAtIndexPath:) func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! ReviewCell
        let schedule = mySchedules[indexPath.row]
        
        cell.configure(
            day: indexPath.row + 1,
            date: schedule.date.dateValue(),
            isCompleted: schedule.completed != nil,
            retention: schedule.completed != nil ? "89% retained" : nil
        )
        cell.startButton.removeTarget(nil, action: nil, for: .touchUpInside)
        cell.startButton.addAction(UIAction { [weak self] _ in
            self?.performSegue(withIdentifier: "toQuestionVC", sender: indexPath)
            }, for: .touchUpInside)
        
        return cell
    }
    
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
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let statusBar: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
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
        label.textColor = .systemYellow
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
            startButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            startButton.widthAnchor.constraint(equalToConstant: 100),
            startButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
   func configure(day: Int, date: Date, isCompleted: Bool, retention: String?) {
        titleLabel.text = "Day \(day)"
        dateLabel.text = formatDate(date)
        
        if isCompleted {
            statusBar.backgroundColor = .systemGreen
            statusIcon.image = UIImage(systemName: "checkmark.circle.fill")
            statusIcon.tintColor = .systemGreen
            startButton.isHidden = true
            retentionLabel.isHidden = false
            retentionLabel.text = retention
        } else {
            let isToday = Calendar.current.isDateInToday(date)
            statusBar.backgroundColor = isToday ? .systemBlue : .systemGray5
            statusIcon.image = isToday ? UIImage(systemName: "arrow.right.circle.fill") : UIImage(systemName: "circle.dashed")
            statusIcon.tintColor = isToday ? .systemBlue : .systemGray3
            startButton.isHidden = !isToday
            retentionLabel.isHidden = true
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


