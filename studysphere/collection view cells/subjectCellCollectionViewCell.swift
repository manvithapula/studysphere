import UIKit

class SubjectCellCollectionViewCell: UICollectionViewCell {
    // MARK: - UI Elements
    private let containerView = GradientView()
    private let iconContainerView = GradientView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let continueButton = UIButton(type: .system)
    
    // MARK: - Properties
    var buttonTapped: (() -> Void)?
    
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
    }
    
    private func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        iconContainerView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
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
        ])
    }
    
    private func setupActions() {
        continueButton.addTarget(self, action: #selector(didTapContinueButton), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func didTapContinueButton() {
        buttonTapped?()
    }
    
    func configure(title: String, subtitle: String, iconName: String = "book.fill", index: Int) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        iconImageView.image = UIImage(systemName: iconName)

        // Define gradient colors based on the index
        let colorSchemes: [(start: UIColor, end: UIColor)] = [
            (AppTheme.primary.withAlphaComponent(0.15), AppTheme.primary.withAlphaComponent(0.05)),
            (AppTheme.secondary.withAlphaComponent(0.15), AppTheme.secondary.withAlphaComponent(0.05))
        ]
        
        let iconColorSchemes: [(start: UIColor, end: UIColor)] = [
            (AppTheme.primary, AppTheme.primary.adjustBrightness(by: 0.2)),
            (AppTheme.secondary, AppTheme.secondary.adjustBrightness(by: 0.2))
        ]
        
        let colorIndex = index % colorSchemes.count
        let colors = colorSchemes[colorIndex]
        let iconColors = iconColorSchemes[colorIndex]

     
        containerView.setGradient(
            startColor: colors.start,
            endColor: colors.end,
            startPoint: CGPoint(x: 0.0, y: 0.0),
            endPoint: CGPoint(x: 1.0, y: 1.0)
        )

        // Apply gradient to iconContainerView
        iconContainerView.setGradient(
            startColor: iconColors.start,
            endColor: iconColors.end,
            startPoint: CGPoint(x: 0.0, y: 0.0),
            endPoint: CGPoint(x: 1.0, y: 1.0)
        )

        // Adjust subtitle text color
        subtitleLabel.textColor = iconColors.start.withAlphaComponent(0.8)
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Update any frame-dependent layouts here if needed
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        subtitleLabel.text = nil
        iconImageView.image = nil
    }
}

