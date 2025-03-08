import UIKit

class SubjectCellCollectionViewCell: UICollectionViewCell {
    // MARK: - UI Elements
    private let containerView = UIView()
    private let iconContainerView = UIView()
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
        // Container View - Light background like in the image
        containerView.backgroundColor = UIColor.systemGray6
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = true
        contentView.addSubview(containerView)
        
        // Icon Container - Circular blue background
        iconContainerView.backgroundColor = AppTheme.primary
        iconContainerView.layer.cornerRadius = 20
        containerView.addSubview(iconContainerView)
        
        // Icon Image View
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white
        iconContainerView.addSubview(iconImageView)
        
        // Title Label - Bold black text
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = UIColor.black
        containerView.addSubview(titleLabel)
        
        // Subtitle Label - Smaller blue text for topic count
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = AppTheme.primary
        containerView.addSubview(subtitleLabel)
        
        // Continue Button (if needed)
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
            // Container View - Full width with small padding on sides
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            containerView.heightAnchor.constraint(equalToConstant: 72), // Match the height in the image
            
            // Icon Container View - Left aligned with image
            iconContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconContainerView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconContainerView.widthAnchor.constraint(equalToConstant: 40),
            iconContainerView.heightAnchor.constraint(equalToConstant: 40),
            
            // Icon Image View
            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // Title Label - Positioned to match the image
            titleLabel.leadingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            
            // Subtitle Label - Positioned directly below title
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
    
    // MARK: - Public Methods
    func configure(title: String, subtitle: String, subjectName: String, iconName: String = "book.fill") {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        
        // Set icon based on the subject
        iconImageView.image = UIImage(systemName: iconName)
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
