import UIKit

class SRScheduleTableViewCell: UITableViewCell {
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
    
    private let setLabel: UILabel = {
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
        button.backgroundColor = .main
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
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
        contentView.addSubview(setLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(retentionContainer)
        contentView.addSubview(startReviewButton)
        contentView.addSubview(timeLabel)
        
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
            
            setLabel.leadingAnchor.constraint(equalTo: statusIcon.trailingAnchor, constant: 12),
            setLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            
            dateLabel.leadingAnchor.constraint(equalTo: setLabel.leadingAnchor),
            dateLabel.topAnchor.constraint(equalTo: setLabel.bottomAnchor, constant: 4),
            
            retentionContainer.leadingAnchor.constraint(equalTo: setLabel.leadingAnchor),
            retentionContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            starIcon.widthAnchor.constraint(equalToConstant: 16),
            starIcon.heightAnchor.constraint(equalToConstant: 16),
            
            startReviewButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            startReviewButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            startReviewButton.widthAnchor.constraint(equalToConstant: 110),
            startReviewButton.heightAnchor.constraint(equalToConstant: 32),
            
            timeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    // MARK: - Configuration
    func configure(with schedule: Schedule, index: Int) {
        setLabel.text = "Revision \(index + 1)"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        dateLabel.text = formatter.string(from: schedule.date.dateValue())
        timeLabel.text = schedule.time
        
        if let completed = schedule.completed {
            // Completed state
            statusBar.backgroundColor = .systemGreen
            statusIcon.image = UIImage(systemName: "checkmark.circle.fill")
            statusIcon.tintColor = .systemGreen
            retentionContainer.isHidden = false
            retentionLabel.text = "85% retained" // You can adjust this based on actual retention data
            startReviewButton.isHidden = true
            timeLabel.isHidden = true
        } else if Calendar.current.isDateInToday(schedule.date.dateValue()) {
            // Today's review
            statusBar.backgroundColor = .systemBlue
            statusIcon.image = UIImage(systemName: "books.vertical.circle.fill")
            statusIcon.tintColor = .systemBlue
            retentionContainer.isHidden = true
            startReviewButton.isHidden = false
            timeLabel.isHidden = false
        } else {
            // Upcoming review
            statusBar.backgroundColor = .systemGray4
            statusIcon.image = UIImage(systemName: "clock.circle.fill")
            statusIcon.tintColor = .systemGray3
            retentionContainer.isHidden = true
            startReviewButton.isHidden = true
            timeLabel.isHidden = false
        }
    }
}
