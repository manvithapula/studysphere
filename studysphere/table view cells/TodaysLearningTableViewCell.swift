import UIKit

class TodaysLearningTableViewCell: UITableViewCell {
    private let containerView = UIView()
    private let cardBackground = UIView()
    private let iconContainer = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let statusTagButton = UIButton()
    
 
    private let subjectTag: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .black
        label.backgroundColor = AppTheme.primary.withAlphaComponent(0.1)
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Loading..."
        return label
    }()
    
    var currentDateOffset: Int = 0
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }
    
    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none
        
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.08
        containerView.layer.shadowRadius = 8
        containerView.layer.shadowOffset = CGSize(width: 0, height: 3)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        cardBackground.layer.cornerRadius = 16
        cardBackground.translatesAutoresizingMaskIntoConstraints = false
        
        iconContainer.layer.cornerRadius = 22
        iconContainer.clipsToBounds = true
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        configureStatusTagButton()
        
        contentView.addSubview(containerView)
        containerView.addSubview(cardBackground)
        cardBackground.addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        cardBackground.addSubview(titleLabel)
        cardBackground.addSubview(statusTagButton)
        cardBackground.addSubview(subjectTag)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            cardBackground.topAnchor.constraint(equalTo: containerView.topAnchor),
            cardBackground.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            cardBackground.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            cardBackground.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            iconContainer.leadingAnchor.constraint(equalTo: cardBackground.leadingAnchor, constant: 16),
            iconContainer.centerYAnchor.constraint(equalTo: cardBackground.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 44),
            iconContainer.heightAnchor.constraint(equalToConstant: 44),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 22),
            iconImageView.heightAnchor.constraint(equalToConstant: 22),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusTagButton.leadingAnchor, constant: -10),
            titleLabel.topAnchor.constraint(equalTo: cardBackground.topAnchor, constant: 12),
            
            subjectTag.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subjectTag.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subjectTag.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            statusTagButton.trailingAnchor.constraint(equalTo: cardBackground.trailingAnchor, constant: -16),
            statusTagButton.topAnchor.constraint(equalTo: cardBackground.topAnchor, constant: 12),
            statusTagButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    private func configureStatusTagButton() {
        statusTagButton.layer.cornerRadius = 12
        statusTagButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        statusTagButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        statusTagButton.isUserInteractionEnabled = false
        statusTagButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
   

    func configure(with item: ScheduleItem, dateOffset: Int = 0) {
        iconImageView.image = UIImage(systemName: item.iconName)
        titleLabel.text = item.title
        currentDateOffset = dateOffset
        let colorIndex = abs(item.title.hashValue) % 2
        setupColors(for: colorIndex)
        if item.progress == 1 {
         
            statusTagButton.setTitle("Completed", for: .normal)
            statusTagButton.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
            statusTagButton.setTitleColor(UIColor.black, for: .normal)
        } else {
            if dateOffset == 0 {
                statusTagButton.setTitle("Yet to Complete", for: .normal)
                statusTagButton.backgroundColor = UIColor.white
                statusTagButton.setTitleColor(UIColor.black, for: .normal)
            } else {
                statusTagButton.setTitle("Upcoming", for: .normal)
                statusTagButton.backgroundColor = AppTheme.primary.withAlphaComponent(0.15)
                statusTagButton.setTitleColor(UIColor.black, for: .normal)
            }
        }
    
        statusTagButton.sizeToFit()
        statusTagButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.3, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.statusTagButton.transform = .identity
        })
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
    }
    
    private func setupColors(for index: Int) {
        let colors: [UIColor] = [
            AppTheme.primary.withAlphaComponent(0.15),
            AppTheme.secondary.withAlphaComponent(0.15)
        ]
        
        let iconColors: [UIColor] = [
            AppTheme.primary,
            AppTheme.secondary
        ]
        let safeIndex = index % 2
        cardBackground.backgroundColor = colors[safeIndex]
        iconContainer.backgroundColor = iconColors[safeIndex]
        titleLabel.textColor = .black
    }

    override var isHighlighted: Bool {
        didSet {
            animateHighlightState()
        }
    }
    
    private func animateHighlightState() {
        let transform: CGAffineTransform = isHighlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
        let shadowOpacity: Float = isHighlighted ? 0.12 : 0.08
        
        if #available(iOS 17.0, *) {
            containerView.layer.shadowOpacity = shadowOpacity
            UIView.animate(.bouncy) {
                self.containerView.transform = transform
            }
        } else {
            UIView.animate(withDuration: 0.2,
                         delay: 0,
                         options: [.allowUserInteraction, .beginFromCurrentState],
                         animations: {
                self.containerView.transform = transform
                self.containerView.layer.shadowOpacity = shadowOpacity
            })
        }
    }
    
    
    private func updateAppearance() {
        containerView.layer.shadowColor = UIColor.black.cgColor
        if let title = titleLabel.text {
            let colorIndex = abs(title.hashValue) % 2
            setupColors(for: colorIndex)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        iconImageView.image = nil
        statusTagButton.setTitle(nil, for: .normal)
        subjectTag.text = nil
        statusTagButton.backgroundColor = nil
        containerView.transform = .identity
        containerView.layer.shadowOpacity = 0.08
    }
}
