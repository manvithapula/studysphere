import UIKit

class SubjectCellCollectionViewCell: UICollectionViewCell {
    // MARK: - UI Elements
    private let containerView = UIView()
    private let iconContainerView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
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
        // Existing views setup
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = true
        contentView.addSubview(containerView)
        
        iconContainerView.layer.cornerRadius = 20
        contentView.addSubview(iconContainerView)
        
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white
        iconContainerView.addSubview(iconImageView)
        
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = UIColor.black
        containerView.addSubview(titleLabel)
        
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        containerView.addSubview(subtitleLabel)
        
        continueButton.setTitleColor(AppTheme.primary, for: .normal)
        continueButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        containerView.addSubview(continueButton)
        
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
        // Existing constraints
        containerView.translatesAutoresizingMaskIntoConstraints = false
        iconContainerView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Empty state constraints
        emptyStateContainer.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        createActionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Existing constraints
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 72),
            
            iconContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconContainerView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconContainerView.widthAnchor.constraint(equalToConstant: 40),
            iconContainerView.heightAnchor.constraint(equalToConstant: 40),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
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
        iconContainerView.isHidden = show
        emptyStateContainer.isHidden = !show
    }
    
    func configure(title: String, subtitle: String, iconName: String = "book", index: Int) {
        showEmptyState(false)
        
        titleLabel.text = title
        subtitleLabel.text = subtitle
        iconImageView.image = UIImage(systemName: iconName)

        // Define background colors based on the index
        let backgroundColors: [UIColor] = [
            AppTheme.primary.withAlphaComponent(0.15),
            AppTheme.secondary.withAlphaComponent(0.15),
        ]
        
        let iconBackgroundColors: [UIColor] = [
            AppTheme.primary,
            AppTheme.secondary,
        ]
        
        let colorIndex = index % backgroundColors.count
        let backgroundColor = backgroundColors[colorIndex]
        let iconBackgroundColor = iconBackgroundColors[colorIndex]

        containerView.backgroundColor = backgroundColor
        iconContainerView.backgroundColor = iconBackgroundColor
        subtitleLabel.textColor = iconBackgroundColor.withAlphaComponent(0.8)
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
    }
}
