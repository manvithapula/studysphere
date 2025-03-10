import UIKit

class DocumentCell: UICollectionViewCell {
    static let reuseIdentifier = "DocumentCell"
    
    // MARK: - UI Elements
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowRadius = 8
        view.layer.shadowOffset = CGSize(width: 0, height: 3)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Card background with gradient
    private let cardBackground: GradientView = {
        let view = GradientView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Icon container with animated gradient
    private let iconContainer: GradientView = {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        return view
    }()
    
    private let documentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .darkText
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = AppTheme.primary.withAlphaComponent(0.8)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let fileTypeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear
        contentView.addSubview(containerView)
        containerView.addSubview(cardBackground)
        cardBackground.addSubview(iconContainer)
        iconContainer.addSubview(documentImageView)
        cardBackground.addSubview(titleLabel)
        cardBackground.addSubview(dateLabel)
        cardBackground.addSubview(fileTypeLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 110),
            
            cardBackground.topAnchor.constraint(equalTo: containerView.topAnchor),
            cardBackground.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            cardBackground.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            cardBackground.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            iconContainer.leadingAnchor.constraint(equalTo: cardBackground.leadingAnchor, constant: 16),
            iconContainer.centerYAnchor.constraint(equalTo: cardBackground.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 48),
            iconContainer.heightAnchor.constraint(equalToConstant: 48),
            
            documentImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            documentImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            documentImageView.widthAnchor.constraint(equalToConstant: 24),
            documentImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: cardBackground.topAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: cardBackground.trailingAnchor, constant: -16),
            
            fileTypeLabel.topAnchor.constraint(equalTo: cardBackground.topAnchor, constant: 12),
            fileTypeLabel.trailingAnchor.constraint(equalTo: cardBackground.trailingAnchor, constant: -12),
            fileTypeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 32),
            fileTypeLabel.heightAnchor.constraint(equalToConstant: 20),
            
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            dateLabel.trailingAnchor.constraint(equalTo: cardBackground.trailingAnchor, constant: -16),
            dateLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardBackground.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Configuration
    func configure(with document: StudyDocument, index: Int) {
        titleLabel.text = document.title
        
        // Format date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateLabel.text = dateFormatter.string(from: document.dateAdded)
        
        // Set document type icon and file type label based on extension
        let fileExtension = document.fileURL.pathExtension.lowercased()
        setupDocumentType(fileExtension: fileExtension)
        setupColors(for: index)
    }
    
    private func setupDocumentType(fileExtension: String) {
        switch fileExtension {
        case "pdf":
            documentImageView.image = UIImage(systemName: "doc.fill")
            fileTypeLabel.text = "PDF"
        case "doc", "docx":
            documentImageView.image = UIImage(systemName: "doc.fill")
            fileTypeLabel.text = "DOC"
        default:
            documentImageView.image = UIImage(systemName: "doc.fill")
            fileTypeLabel.text = fileExtension.uppercased()
        }
        
        fileTypeLabel.sizeToFit()
        fileTypeLabel.layoutMargins = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
    }
    
    private func setupColors(for index: Int) {
        // Create a color scheme based on index using AppTheme colors
        let colorSchemes: [(start: UIColor, end: UIColor, pattern: UIColor)] = [
            (AppTheme.primary.withAlphaComponent(0.15), AppTheme.primary.withAlphaComponent(0.05), AppTheme.primary.withAlphaComponent(0.1)),
            (AppTheme.secondary.withAlphaComponent(0.15), AppTheme.secondary.withAlphaComponent(0.05), AppTheme.secondary.withAlphaComponent(0.1))
        ]
        
        let iconColorSchemes: [(start: UIColor, end: UIColor)] = [
            (AppTheme.primary, AppTheme.primary.adjustBrightness(by: 0.2)),
            (AppTheme.secondary, AppTheme.secondary.adjustBrightness(by: 0.2))
        ]
        
        let colorIndex = index % colorSchemes.count
        let colors = colorSchemes[colorIndex]
        let iconColors = iconColorSchemes[colorIndex]
        
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
        
        // Update labels colors
        dateLabel.textColor = iconColors.start.withAlphaComponent(0.8)
        fileTypeLabel.backgroundColor = iconColors.start
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
           
            if let document = (self.titleLabel.text).map({ StudyDocument(id: "", title: $0, dateAdded: Date(), fileURL: URL(fileURLWithPath: "")) }) {
                let index = abs(document.title.hashValue) % 2 // Consistent index based on title
                setupColors(for: index)
            }
        }
        
        // Update prepareForReuse to handle new properties
        override func prepareForReuse() {
            super.prepareForReuse()
            
            // Reset text and images
            titleLabel.text = nil
            dateLabel.text = nil
            documentImageView.image = nil
            fileTypeLabel.text = nil
            
            // Reset appearance
            fileTypeLabel.backgroundColor = nil
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
