import UIKit

class SummaryCollectionViewCell: UICollectionViewCell {
    // MARK: - UI Elements
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        contentView.addSubview(containerView)
        contentView.addSubview(cardBackground)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subjectTag)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            // Card Background
            cardBackground.topAnchor.constraint(equalTo: containerView.topAnchor),
            cardBackground.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            cardBackground.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            cardBackground.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            // Title Label
            titleLabel.leadingAnchor.constraint(equalTo: cardBackground.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: cardBackground.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: cardBackground.topAnchor, constant: 16),
            
            subjectTag.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subjectTag.leadingAnchor.constraint(equalTo: cardBackground.leadingAnchor, constant: 16),
            subjectTag.bottomAnchor.constraint(equalTo: cardBackground.bottomAnchor, constant: -16),
            subjectTag.widthAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ])

        subjectTag.layoutIfNeeded()
        subjectTag.layer.cornerRadius = 8
        subjectTag.setPadding(horizontal: 12, vertical: 4)
        setupColors(for: 0)
    }
    
    func configure(title: String, itemCount: Int, time: String, subject: String, index: Int) {
        titleLabel.text = title
        subjectTag.text = subject

        setupColors(for: index)
    }
    
    func updateSubject(topic: Topics) {
        titleLabel.text = topic.title
        
    
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
