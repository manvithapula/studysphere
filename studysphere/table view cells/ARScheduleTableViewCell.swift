import UIKit

class ARScheduleTableViewCell: UITableViewCell {
    // MARK: - UI Components
    private let statusBar: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let statusIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let retentionContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let starIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "star.fill"))
        imageView.tintColor = .systemYellow
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let retentionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let startReviewButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Review", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let upcomingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.text = "Upcoming"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .systemBackground
        selectionStyle = .none
        
        contentView.addSubview(statusBar)
        contentView.addSubview(statusIcon)
        contentView.addSubview(dayLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(retentionContainer)
        contentView.addSubview(startReviewButton)
        contentView.addSubview(upcomingLabel)
        
        retentionContainer.addArrangedSubview(starIcon)
        retentionContainer.addArrangedSubview(retentionLabel)
        
        NSLayoutConstraint.activate([
            statusBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            statusBar.topAnchor.constraint(equalTo: contentView.topAnchor),
            statusBar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            statusBar.widthAnchor.constraint(equalToConstant: 4),
            
            statusIcon.leadingAnchor.constraint(equalTo: statusBar.trailingAnchor, constant: 16),
            statusIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            statusIcon.widthAnchor.constraint(equalToConstant: 24),
            statusIcon.heightAnchor.constraint(equalToConstant: 24),
            
            dayLabel.leadingAnchor.constraint(equalTo: statusIcon.trailingAnchor, constant: 12),
            dayLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            
            dateLabel.leadingAnchor.constraint(equalTo: dayLabel.leadingAnchor),
            dateLabel.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 4),
            
            retentionContainer.leadingAnchor.constraint(equalTo: dayLabel.leadingAnchor),
            retentionContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            starIcon.widthAnchor.constraint(equalToConstant: 16),
            starIcon.heightAnchor.constraint(equalToConstant: 16),
            
            startReviewButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            startReviewButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            startReviewButton.widthAnchor.constraint(equalToConstant: 110),
            startReviewButton.heightAnchor.constraint(equalToConstant: 32),
            
            upcomingLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            upcomingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    // MARK: - Configuration
    func configure(with model: ActiveRecallDay) {
        dayLabel.text = "Day \(model.day)"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        dateLabel.text = formatter.string(from: model.date)
        
        switch model.status {
        case .completed(let retention):
            statusBar.backgroundColor = UIColor.systemGreen
            statusIcon.image = UIImage(systemName: "checkmark.circle.fill")
            statusIcon.tintColor = .systemGreen
            retentionContainer.isHidden = false
            retentionLabel.text = "\(retention)% retained"
            startReviewButton.isHidden = true
            upcomingLabel.isHidden = true
            
        case .current:
            statusBar.backgroundColor = UIColor.systemBlue
            statusIcon.image = UIImage(systemName: "questionmark.circle.fill")
            statusIcon.tintColor = .systemBlue
            retentionContainer.isHidden = true
            startReviewButton.isHidden = false
            upcomingLabel.isHidden = true
            
        case .locked:
            statusBar.backgroundColor = .systemGray4
            statusIcon.image = UIImage(systemName: "lock.circle.fill")
            statusIcon.tintColor = .systemGray3
            retentionContainer.isHidden = true
            startReviewButton.isHidden = true
            upcomingLabel.isHidden = false
        }
    }
}

// MARK: - Models
struct ActiveRecallDay {
    let day: Int
    let date: Date
    let status: ActiveRecallStatus
}

enum ActiveRecallStatus {
    case completed(retention: Int)
    case current
    case locked
}

class ActiveRecallViewController: UITableViewController {
    private let cellId = "ARScheduleCell"
    private var recallDays: [ActiveRecallDay] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupData()
    }
    
    private func setupTableView() {
        tableView.register(ARScheduleTableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemBackground
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    }
    
    private func setupData() {
        let today = Date()
        let calendar = Calendar.current
        
        // Define the recall schedule
        let schedule: [(day: Int, offset: Int)] = [
            (1, 0), (3, 2), (7, 6), (14, 13), (30, 29), (90, 89)
        ]
        
        // Create recall days with proper status
        recallDays = schedule.map { day, offset in
            let date = calendar.date(byAdding: .day, value: offset, to: today)!
            let status: ActiveRecallStatus
            
            if calendar.isDate(date, inSameDayAs: today) {
                status = .current
            } else if date < today {
                // Completed days (just the first two in this case)
                if day == 1 {
                    status = .completed(retention: 89)
                } else if day == 3 {
                    status = .completed(retention: 86)
                } else {
                    status = .locked
                }
            } else {
                status = .locked
            }
            
            return ActiveRecallDay(day: day, date: date, status: status)
        }
    }
    
    // MARK: - Table View Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recallDays.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? ARScheduleTableViewCell else {
            return UITableViewCell()
        }
        
        let recallDay = recallDays[indexPath.row]
        cell.configure(with: recallDay)
        
        return cell
    }
}
