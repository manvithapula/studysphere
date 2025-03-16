import UIKit

class TodaysLearningTableViewCell: UITableViewCell {
    private let containerView = UIView()
    private let cardBackground: GradientView = {
        let view = GradientView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconContainer: GradientView = {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 22
        view.clipsToBounds = true
        return view
    }()
    
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let statusTagButton = UIButton()
    
    // Add a property to store the current date offset
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
        
        // Enhanced container view with more pronounced shadow
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.08
        containerView.layer.shadowRadius = 8
        containerView.layer.shadowOffset = CGSize(width: 0, height: 3)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white // Now using white for the icon
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Enhanced title label
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.numberOfLines = 2 // Allow two lines for longer titles
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Create the status tag button
        configureStatusTagButton()
        
        contentView.addSubview(containerView)
        containerView.addSubview(cardBackground)
        cardBackground.addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        cardBackground.addSubview(titleLabel)
        cardBackground.addSubview(statusTagButton)
        
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
            titleLabel.trailingAnchor.constraint(equalTo: statusTagButton.leadingAnchor, constant: -10),
            titleLabel.centerYAnchor.constraint(equalTo: cardBackground.centerYAnchor),
            
            statusTagButton.trailingAnchor.constraint(equalTo: cardBackground.trailingAnchor, constant: -16),
            statusTagButton.centerYAnchor.constraint(equalTo: cardBackground.centerYAnchor),
            statusTagButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    private func configureStatusTagButton() {
        // Configure the tag button with rounded corners and padding
        statusTagButton.layer.cornerRadius = 12
        statusTagButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        statusTagButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        statusTagButton.isUserInteractionEnabled = false // Disable user interaction if it's just an indicator
        statusTagButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configure(with item: ScheduleItem, dateOffset: Int = 0) {
        iconImageView.image = UIImage(systemName: item.iconName)
        titleLabel.text = item.title
        currentDateOffset = dateOffset
        
        // Setup colors based on a consistent index (using hash of title for consistency)
        let colorIndex = abs(item.title.hashValue) % 2
        setupColors(for: colorIndex)
        
        // Update status tag button based on completion status
        if item.progress == 1 {
            // Task is completed
            statusTagButton.setTitle("Completed", for: .normal)
            statusTagButton.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
            statusTagButton.setTitleColor(UIColor.black, for: .normal)
        } else {
            // Task is incomplete
            // If dateOffset is 0, it's today; otherwise, it's a future date
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
        
        // Make sure the button width adjusts to accommodate the text
        statusTagButton.sizeToFit()
        
        // Add a subtle animation when the cell appears
        statusTagButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.3, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.statusTagButton.transform = .identity
        })
    }
    
    private func setupColors(for index: Int) {
        // Define color schemes
        let colorSchemes: [(start: UIColor, end: UIColor)] = [
            (AppTheme.primary.withAlphaComponent(0.15), AppTheme.primary.withAlphaComponent(0.05)),
            (AppTheme.secondary.withAlphaComponent(0.15), AppTheme.secondary.withAlphaComponent(0.05))
        ]
        
        let iconColorSchemes: [(start: UIColor, end: UIColor)] = [
            (AppTheme.primary, AppTheme.primary.adjustBrightness(by: 0.2)),
            (AppTheme.secondary, AppTheme.secondary.adjustBrightness(by: 0.2))
        ]
        
        // Ensure index is within bounds
        let safeIndex = index % colorSchemes.count
        
        // Get colors
        let colors = colorSchemes[safeIndex]
        let iconColors = iconColorSchemes[safeIndex]
        
        // Set card background gradient
        cardBackground.setGradient(startColor: colors.start,
                                 endColor: colors.end,
                                 startPoint: CGPoint(x: 0.0, y: 0.0),
                                 endPoint: CGPoint(x: 1.0, y: 1.0))
        
        // Set icon container gradient
        iconContainer.setGradient(startColor: iconColors.start,
                                endColor: iconColors.end,
                                startPoint: CGPoint(x: 0.0, y: 0.0),
                                endPoint: CGPoint(x: 1.0, y: 1.0))
        
        // Update title label color based on the theme
        titleLabel.textColor = iconColors.start.withAlphaComponent(0.8)
    }
    
    // Animation for highlighted state
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
    
    // Update trait collection handling
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // Check for specific trait changes
        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                updateAppearance()
            }
        }
    }
    
    private func updateAppearance() {
        // Update shadow color for dark mode support
        containerView.layer.shadowColor = UIColor.black.cgColor
        
        // Re-apply colors for the current theme
        if let title = titleLabel.text {
            let colorIndex = abs(title.hashValue) % 2
            setupColors(for: colorIndex)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset text and images
        titleLabel.text = nil
        iconImageView.image = nil
        statusTagButton.setTitle(nil, for: .normal)
        
        // Reset appearance
        statusTagButton.backgroundColor = nil
        containerView.transform = .identity
        containerView.layer.shadowOpacity = 0.08
        
        // Reset gradients
        cardBackground.setGradient(startColor: .clear,
                                 endColor: .clear,
                                 startPoint: CGPoint(x: 0.0, y: 0.0),
                                 endPoint: CGPoint(x: 1.0, y: 1.0))
        
        iconContainer.setGradient(startColor: .clear,
                                endColor: .clear,
                                startPoint: CGPoint(x: 0.0, y: 0.0),
                                endPoint: CGPoint(x: 1.0, y: 1.0))
    }
}
