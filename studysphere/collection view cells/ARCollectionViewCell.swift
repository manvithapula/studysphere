import UIKit

class ARCollectionViewCell: UICollectionViewCell {
    
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
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .gray
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
        contentView.addSubview(containerView)
        containerView.addSubview(cardBackground)
        cardBackground.addSubview(titleLabel)
        cardBackground.addSubview(subtitleLabel)
        cardBackground.addSubview(subjectTag)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container View
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Card Background
            cardBackground.topAnchor.constraint(equalTo: containerView.topAnchor),
            cardBackground.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            cardBackground.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            cardBackground.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            // Title Label
            titleLabel.leadingAnchor.constraint(equalTo: cardBackground.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: cardBackground.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: cardBackground.topAnchor, constant: 16),
            
            // Subtitle Label
            subtitleLabel.leadingAnchor.constraint(equalTo: cardBackground.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: cardBackground.trailingAnchor, constant: -16),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            
            // Subject Tag
            subjectTag.leadingAnchor.constraint(equalTo: cardBackground.leadingAnchor, constant: 16),
            subjectTag.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 8),
            subjectTag.bottomAnchor.constraint(equalTo: cardBackground.bottomAnchor, constant: -16),
            subjectTag.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            subjectTag.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        // Add padding to the subject tag
        subjectTag.setPadding(horizontal: 12, vertical: 4)
    }
    
 

    // MARK: - Configuration
    func configure(topic: Topics, index: Int) {
        titleLabel.text = topic.title
        subtitleLabel.text = topic.subtitle
        subjectTag.text = "" // Temporary until data is fetched
        
        setupColors(for: index)
        
        // Fetch subject asynchronously
        fetchSubject(topic: topic)
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
  //      iconImageView.tintColor = iconColor
        subtitleLabel.textColor = iconColor.withAlphaComponent(0.8)
        subjectTag.backgroundColor = iconColor.withAlphaComponent(0.2)
    }

    // MARK: - Highlight Handling
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.containerView.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
                self.containerView.layer.shadowOpacity = self.isHighlighted ? 0.12 : 0.08
            }
        }
    }
    
    private func fetchSubject(topic: Topics) {
        Task {
            do {
                let subjects = try await subjectDb.findAll(where: ["id": topic.subject])
                if let subject = subjects.first {
                    await MainActor.run {
                        self.subjectTag.text = subject.name
                       
                    }
                }
            } catch {
                print("Error fetching subject: \(error)")
            }
        }
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        subtitleLabel.text = nil
        subjectTag.text = ""
    }
}
