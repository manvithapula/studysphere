import UIKit
// Delegate protocol for handling edit and delete actions
protocol DocumentCellDelegate: AnyObject {
    func didTapEdit(for cell: DocumentCell, document: FileMetadata)
    func didTapDelete(for cell: DocumentCell, document: FileMetadata)
}

class DocumentCell: UICollectionViewCell {
    static let reuseIdentifier = "DocumentCell"
    
    // MARK: - Properties
    weak var delegate: DocumentCellDelegate?
    private var currentDocument: FileMetadata?
    
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
        startButton.tintColor = .black
        startButton.setTitleColor(.white, for: .normal)
        startButton.backgroundColor = .clear
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
    
    // MARK: - Swipe Gesture Elements
    private lazy var swipeActionView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Delete", for: .normal)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var initialTouchPoint: CGPoint = .zero
    private var swipeViewRightConstraint: NSLayoutConstraint?

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGestureRecognizers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        backgroundColor = .clear
        
        // Add swipe action view
        contentView.addSubview(swipeActionView)
        swipeActionView.addSubview(editButton)
        swipeActionView.addSubview(deleteButton)
        
        contentView.addSubview(containerView)
        containerView.addSubview(cardBackground)
        cardBackground.addSubview(iconContainer)
        iconContainer.addSubview(documentImageView)
        cardBackground.addSubview(titleLabel)
        cardBackground.addSubview(dateLabel)
        cardBackground.addSubview(previewButton)
        
        NSLayoutConstraint.activate([
            // Swipe Action View
            swipeActionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            swipeActionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            swipeActionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            swipeActionView.widthAnchor.constraint(equalToConstant: 150),
            
            // Edit Button
            editButton.leadingAnchor.constraint(equalTo: swipeActionView.leadingAnchor, constant: 8),
            editButton.centerYAnchor.constraint(equalTo: swipeActionView.centerYAnchor),
            editButton.widthAnchor.constraint(equalToConstant: 60),
            editButton.heightAnchor.constraint(equalToConstant: 36),
            
            // Delete Button
            deleteButton.leadingAnchor.constraint(equalTo: editButton.trailingAnchor, constant: 8),
            deleteButton.trailingAnchor.constraint(equalTo: swipeActionView.trailingAnchor, constant: -16),
            deleteButton.centerYAnchor.constraint(equalTo: swipeActionView.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 60),
            deleteButton.heightAnchor.constraint(equalToConstant: 36),
            
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
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
        
        // Initialize containerView right constraint
        swipeViewRightConstraint = containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        swipeViewRightConstraint?.isActive = true
    }
    
    private func setupGestureRecognizers() {
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
//        containerView.addGestureRecognizer(panGesture)
    }

    // MARK: - Configure Cell
    func configure(with document: FileMetadata, index: Int,isEditing:Bool) {
        titleLabel.text = document.title
        currentDocument = document
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateLabel.text = dateFormatter.string(from: document.createdAt.dateValue())
        
        setupColors(for: index)
        setupDocumentType(fileExtension: document.subjectId)
        resetSwipeState()
        if(isEditing){
            let newX = CGFloat(-150)// Limit swipe to -150 points
            swipeViewRightConstraint?.constant = newX
            layoutIfNeeded()
        }
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
    
    // MARK: - Swipe Gesture Handling
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: containerView)
        
        switch gesture.state {
        case .began:
            initialTouchPoint = containerView.frame.origin
            
        case .changed:
            if translation.x < 0 { // Only allow left swipe
                let newX = max(translation.x, -150) // Limit swipe to -150 points
                swipeViewRightConstraint?.constant = newX - 16 // Account for container right margin
                layoutIfNeeded()
            }
            
        case .ended, .cancelled:
            let velocity = gesture.velocity(in: containerView)
            
            if swipeViewRightConstraint?.constant ?? 0 < -75 || velocity.x < -200 {
                // Show action buttons
                UIView.animate(withDuration: 0.3) {
                    self.swipeViewRightConstraint?.constant = -150 - 16 // Account for container right margin
                    self.layoutIfNeeded()
                }
            } else {
                // Reset position
                resetSwipeState()
            }
            
        default:
            break
        }
    }
    
    private func resetSwipeState() {
        UIView.animate(withDuration: 0.3) {
            self.swipeViewRightConstraint?.constant = -16 // Reset to original right margin
            self.layoutIfNeeded()
        }
    }
    
    // MARK: - Action Handlers
    @objc private func editButtonTapped() {
        guard let document = currentDocument else { return }
        delegate?.didTapEdit(for: self, document: document)
    }
    
    @objc private func deleteButtonTapped() {
        guard let document = currentDocument else { return }
        delegate?.didTapDelete(for: self, document: document)
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
        currentDocument = nil
        resetSwipeState()
    }
}
