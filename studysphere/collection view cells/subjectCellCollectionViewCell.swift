import UIKit

class SubjectCellCollectionViewCell: UICollectionViewCell {
    // MARK: - UI Elements
    private let containerView = UIView()
    private let cardBackground = UIView()
    private let iconContainerView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = DesignManager.cellTitleLabel()
    private let subtitleLabel = UILabel()
    private let continueButton = UIButton(type: .system)
    
    // Empty State Views
    private let emptyStateContainer = UIView()
    private let emptyStateLabel = UILabel()
    private let createActionLabel = UILabel()
    
    // MARK: - Properties
    var buttonTapped: (() -> Void)?
    var createActionTapped: (() -> Void)?
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupConstraints()
        setupActions()
    }
    
    private func setupViews() {
        // Container view setup (with shadow like in TableViewCell)
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.08
        containerView.layer.shadowRadius = 8
        containerView.layer.shadowOffset = CGSize(width: 0, height: 3)
        contentView.addSubview(containerView)
        
        // Card background setup
        cardBackground.layer.cornerRadius = 12
        cardBackground.clipsToBounds = true
        containerView.addSubview(cardBackground)
        
        iconContainerView.layer.cornerRadius = 20
        cardBackground.addSubview(iconContainerView)
        
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white
        iconContainerView.addSubview(iconImageView)
        
        cardBackground.addSubview(titleLabel)
        
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        cardBackground.addSubview(subtitleLabel)
        
        continueButton.setTitleColor(AppTheme.primary, for: .normal)
        continueButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        cardBackground.addSubview(continueButton)
        
        // Empty state views setup
        contentView.addSubview(emptyStateContainer)
        emptyStateContainer.addSubview(emptyStateLabel)
        emptyStateContainer.addSubview(createActionLabel)
        
        emptyStateLabel.text = "No modules yet"
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        emptyStateLabel.textColor = .gray
        
        createActionLabel.text = "Create New Module"
        createActionLabel.textAlignment = .center
        createActionLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        createActionLabel.textColor = AppTheme.primary
        createActionLabel.isUserInteractionEnabled = true
         
        // Initially hide empty state
        emptyStateContainer.isHidden = true
    }
    
    private func setupConstraints() {
        // Setup auto layout constraints
        containerView.translatesAutoresizingMaskIntoConstraints = false
        cardBackground.translatesAutoresizingMaskIntoConstraints = false
        iconContainerView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Empty state constraints
        emptyStateContainer.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        createActionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Container view constraints
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 72),
            
            // Card background constraints
            cardBackground.topAnchor.constraint(equalTo: containerView.topAnchor),
            cardBackground.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            cardBackground.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            cardBackground.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            iconContainerView.leadingAnchor.constraint(equalTo: cardBackground.leadingAnchor, constant: 16),
            iconContainerView.centerYAnchor.constraint(equalTo: cardBackground.centerYAnchor),
            iconContainerView.widthAnchor.constraint(equalToConstant: 40),
            iconContainerView.heightAnchor.constraint(equalToConstant: 40),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: cardBackground.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: cardBackground.topAnchor, constant: 16),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: cardBackground.trailingAnchor, constant: -16),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            
            // Empty state constraints
            emptyStateContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emptyStateContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            emptyStateContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emptyStateContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: emptyStateContainer.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: emptyStateContainer.centerYAnchor),
            
            createActionLabel.topAnchor.constraint(equalTo: emptyStateLabel.bottomAnchor, constant: 8),
            createActionLabel.centerXAnchor.constraint(equalTo: emptyStateContainer.centerXAnchor)
        ])
    }
    
    private func setupActions() {
        continueButton.addTarget(self, action: #selector(didTapContinueButton), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCreateAction))
        createActionLabel.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @objc private func didTapContinueButton() {
        buttonTapped?()
    }
    
    @objc private func didTapCreateAction() {
        createActionTapped?()
    }
    
    func showEmptyState(_ show: Bool) {
        containerView.isHidden = show
        cardBackground.isHidden = show
        iconContainerView.isHidden = show
        emptyStateContainer.isHidden = !show
    }
    
    // Updated configure method using the setupColors approach
    func configure(title: String, subtitle: String, iconName: String = "book", index: Int) {
        showEmptyState(false)
        
        titleLabel.text = title
        subtitleLabel.text = subtitle
        iconImageView.image = UIImage(systemName: iconName)
        
        setupColors(for: index)
    }
    
    // Implementing setupColors from TableViewCell
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
        iconContainerView.backgroundColor = iconColor
        subtitleLabel.textColor = iconColor.withAlphaComponent(0.8)
    }
    
    // MARK: - Highlight handling for UICollectionViewCell
    // UICollectionViewCell uses these methods instead of setHighlighted
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.containerView.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
                self.containerView.layer.shadowOpacity = self.isHighlighted ? 0.12 : 0.08
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.containerView.transform = self.isSelected ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
                self.containerView.layer.shadowOpacity = self.isSelected ? 0.12 : 0.08
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        subtitleLabel.text = nil
        iconImageView.image = nil
        showEmptyState(false)
        // Reset transform and shadow when reusing the cell
        containerView.transform = .identity
        containerView.layer.shadowOpacity = 0.08
    }
}
