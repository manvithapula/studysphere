import UIKit

// Delegate protocol for handling edit and delete actions
protocol SummaryCollectionViewCellDelegate: AnyObject {
    func didTapEdit(for cell: SummaryCollectionViewCell, topic: Topics)
    func didTapDelete(for cell: SummaryCollectionViewCell, topic: Topics)
}

class SummaryCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    weak var delegate: SummaryCollectionViewCellDelegate?
    private var currentTopic: Topics?
    
    // MARK: - UI Elements
    private let containerView = DesignManager.cardView()
    
    private let cardBackground: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel = DesignManager.cellTitleLabel()
    
    private let subjectTag: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .black
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        return label
    }()
    
    // MARK: - Swipe Gesture Elements
    private lazy var swipeActionView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var editButton = DesignManager.editButton(selector: #selector(editButtonTapped))
    
    private lazy var deleteButton = DesignManager.deleteButton(selector: #selector(deleteButtonTapped))
    
    private var initialTouchPoint: CGPoint = .zero
    private var swipeViewRightConstraint: NSLayoutConstraint?
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupConstraints()
    }
    
    // MARK: - Setup
    private func setupViews() {
        contentView.addSubview(swipeActionView)
        swipeActionView.addSubview(editButton)
        swipeActionView.addSubview(deleteButton)
        
        contentView.addSubview(containerView)
        containerView.addSubview(cardBackground)
        cardBackground.addSubview(titleLabel)
        cardBackground.addSubview(subjectTag)
    }
    
    private func setupConstraints() {
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
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            deleteButton.centerYAnchor.constraint(equalTo: swipeActionView.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 60),
            deleteButton.heightAnchor.constraint(equalToConstant: 36),
            
            // Container View
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            // Card Background
            cardBackground.topAnchor.constraint(equalTo: containerView.topAnchor),
            cardBackground.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            cardBackground.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            cardBackground.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            // Title Label
            titleLabel.leadingAnchor.constraint(equalTo: cardBackground.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: cardBackground.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: cardBackground.topAnchor, constant: 16),
            
            // Subject Tag
            subjectTag.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subjectTag.leadingAnchor.constraint(equalTo: cardBackground.leadingAnchor, constant: 16),
            subjectTag.bottomAnchor.constraint(equalTo: cardBackground.bottomAnchor, constant: -16),
            subjectTag.widthAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ])
        
        // Initialize containerView right constraint
        swipeViewRightConstraint = containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        swipeViewRightConstraint?.isActive = true
        
        // Add padding to the subject tag
        subjectTag.layoutIfNeeded()
        subjectTag.layer.cornerRadius = 8
    }
    
    
    // MARK: - Configuration
    func configure(title: String, subject: String, index: Int, topic: Topics, isEditing:Bool) {
        titleLabel.text = title
        subjectTag.text = subject
        currentTopic = topic
        
        setupColors(for: index)
        resetSwipeState()
        if(isEditing){
            let newX = CGFloat(-150)// Limit swipe to -150 points
            swipeViewRightConstraint?.constant = newX
            layoutIfNeeded()
        }
    }
    
    func updateSubject(topic: Topics) {
        titleLabel.text = topic.title
        currentTopic = topic
        
        Task {
            let allSubjects = try await subjectDb.findAll(where: ["id": topic.subject])
            if let subject = allSubjects.first {
                await MainActor.run {
                    self.subjectTag.text = subject.name
                }
            }
        }
    }
    
    private func setupColors(for index: Int) {
        let colorSchemes: [UIColor] = [
            AppTheme.primary.withAlphaComponent(0.15),
            AppTheme.secondary.withAlphaComponent(0.15)
        ]
        let iconColorSchemes: [UIColor] = [
            AppTheme.primary,
            AppTheme.secondary
        ]
        
        let colorIndex = index % colorSchemes.count
        let backgroundColor = colorIndex < colorSchemes.count ?
                             colorSchemes[colorIndex] :
                             UIColor.systemGray.withAlphaComponent(0.15)
        
        let iconColor = colorIndex < iconColorSchemes.count ?
                       iconColorSchemes[colorIndex] :
                       UIColor.systemGray
        
        cardBackground.backgroundColor = backgroundColor
        subjectTag.backgroundColor = iconColor.withAlphaComponent(0.2)
    }
    
    // MARK: - Gesture Handling
    
    
    private func resetSwipeState() {
        UIView.animate(withDuration: 0.3) {
            self.swipeViewRightConstraint?.constant = -16 // Reset to original right margin
            self.layoutIfNeeded()
        }
    }
    
    // MARK: - Action Handlers
    @objc private func editButtonTapped() {
        guard let topic = currentTopic else { return }
        delegate?.didTapEdit(for: self, topic: topic)
    }
    
    @objc private func deleteButtonTapped() {
        guard let topic = currentTopic else { return }
        delegate?.didTapDelete(for: self, topic: topic)
    }
    
    // MARK: - Highlight Handling
    override var isHighlighted: Bool {
        didSet {
            animateHighlightState()
        }
    }
    
    private func animateHighlightState() {
        let transform: CGAffineTransform = isHighlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
        let shadowOpacity: Float = isHighlighted ? 0.12 : 0.08 // Shadow opacity changes on highlight

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
                self.containerView.layer.shadowOpacity = shadowOpacity // Animate shadow opacity
            })
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        subjectTag.text = nil
        currentTopic = nil
        resetSwipeState()
    }
}
