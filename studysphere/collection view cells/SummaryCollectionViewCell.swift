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
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowRadius = 1.5
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
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
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        setupGestureRecognizers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupConstraints()
        setupGestureRecognizers()
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
        subjectTag.setPadding(horizontal: 12, vertical: 4)
    }
    
    private func setupGestureRecognizers() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        containerView.addGestureRecognizer(panGesture)
    }
    
    // MARK: - Configuration
    func configure(title: String, subject: String, index: Int, topic: Topics) {
        titleLabel.text = title
        subjectTag.text = subject
        currentTopic = topic
        
        setupColors(for: index)
        resetSwipeState()
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
        guard let topic = currentTopic else { return }
        delegate?.didTapEdit(for: self, topic: topic)
        resetSwipeState()
    }
    
    @objc private func deleteButtonTapped() {
        guard let topic = currentTopic else { return }
        delegate?.didTapDelete(for: self, topic: topic)
        resetSwipeState()
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

// Helper extension for padding
extension UILabel {
    func setPadding(horizontal: CGFloat, vertical: CGFloat) {
        let padding = UIEdgeInsets(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
        if let textString = text {
            let attributedString = NSAttributedString(
                string: textString,
                attributes: [
                    NSAttributedString.Key.font: font ?? .systemFont(ofSize: 14)
                ]
            )
            let rect = attributedString.boundingRect(
                with: CGSize(width: frame.size.width, height: .greatestFiniteMagnitude),
                options: .usesLineFragmentOrigin,
                context: nil
            )
            frame.size.height = rect.height + padding.top + padding.bottom
            frame.size.width = rect.width + padding.left + padding.right
        }
    }
}
