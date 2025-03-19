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
    
    private let cardBackground: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 24
        view.backgroundColor = AppTheme.primary
        view.clipsToBounds = true
        return view
    }()
    
    private let documentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "doc.text")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    let previewButton:UIButton = {
        let startButton = UIButton()
        startButton.setImage(UIImage(systemName: "eye"), for: .normal)
        startButton.tintColor = .white
        startButton.setTitleColor(.white, for: .normal)
        startButton.backgroundColor = AppTheme.primary
        startButton.layer.cornerRadius = 16
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.isUserInteractionEnabled = true
        return startButton
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .darkText
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
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
    
    // MARK: - Setup UI
    private func setupUI() {
        backgroundColor = .clear
        contentView.addSubview(containerView)
        containerView.addSubview(cardBackground)
        cardBackground.addSubview(iconContainer)
        iconContainer.addSubview(documentImageView)
        cardBackground.addSubview(titleLabel)
        cardBackground.addSubview(dateLabel)
        cardBackground.addSubview(previewButton)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
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
            
            previewButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,constant: 8),
            previewButton.trailingAnchor.constraint(equalTo: cardBackground.trailingAnchor, constant: -16),
            previewButton.widthAnchor.constraint(equalToConstant:32),
            previewButton.heightAnchor.constraint(equalToConstant: 32),
            
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            dateLabel.trailingAnchor.constraint(equalTo: cardBackground.trailingAnchor, constant: -16),
            dateLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardBackground.bottomAnchor, constant: -16)
        ])
    }

    // MARK: - Configure Cell
    func configure(with document: FileMetadata, index: Int) {
        titleLabel.text = document.title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateLabel.text = dateFormatter.string(from: document.createdAt.dateValue())
        
        setupColors(for: index)
        
        // Assuming file extension property exists on FileMetadata
        setupDocumentType(fileExtension: document.subjectId)

    }

    private func setupDocumentType(fileExtension: String) {
        Task{
            let allsubjects = try await subjectDb.findAll(where: ["id":fileExtension])
            if let subject = allsubjects.first{
                documentImageView.image = UIImage(systemName: SubjectIconService.shared.getIconName(for:subject.name ))?.withRenderingMode(.alwaysTemplate)
            }
            fileTypeLabel.sizeToFit()
            fileTypeLabel.layoutMargins = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        }
    }
    
    private func setupColors(for index: Int) {
        // Create a color scheme based on index using AppTheme colors
        let mainColor: UIColor
        let backgroundAlpha: CGFloat = 0.1
        
        // Determine which theme color to use based on index
        if index % 2 == 0 {
            mainColor = AppTheme.primary
        } else {
            mainColor = AppTheme.secondary
        }
        
        // Apply solid colors
        iconContainer.backgroundColor = mainColor
        cardBackground.backgroundColor = mainColor.withAlphaComponent(backgroundAlpha)
        dateLabel.textColor = mainColor.withAlphaComponent(0.8)
        fileTypeLabel.backgroundColor = mainColor
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
        containerView.layer.shadowColor = UIColor.black.cgColor
       
        if let title = self.titleLabel.text {
            let index = abs(title.hashValue) % 2
            setupColors(for: index)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        dateLabel.text = nil
        documentImageView.image = nil
        fileTypeLabel.text = nil
        fileTypeLabel.backgroundColor = nil
        containerView.transform = .identity
        containerView.layer.shadowOpacity = 0.08
    }
}
