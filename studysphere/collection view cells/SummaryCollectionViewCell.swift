import UIKit

class SummaryCollectionViewCell: UICollectionViewCell {
    // MARK: - UI Elements
    private let containerView: GradientView = {
        let view = GradientView()
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subjectTag: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .black
        label.backgroundColor = AppTheme.primary.withAlphaComponent(0.1)
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Loading..."
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
        containerView.addSubview(titleLabel)
        containerView.addSubview(subjectTag)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            subjectTag.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subjectTag.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            subjectTag.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            subjectTag.widthAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ])

        subjectTag.layoutIfNeeded()
        subjectTag.layer.cornerRadius = 8
        subjectTag.setPadding(horizontal: 12, vertical: 4)

        // Apply gradient background and shadow to containerView
        CardBackgroundHelper.applyGradient(to: containerView, index: 0) // Adjust index dynamically if needed
        CardBackgroundHelper.applyShadow(to: containerView)
    }
    
    func configure(title: String, itemCount: Int, time: String, subject: String, index: Int) {
        titleLabel.text = title
        subjectTag.text = subject

        // Apply gradient background based on index
        if let gradientView = containerView as? GradientView {
            CardBackgroundHelper.applyGradient(to: gradientView, index: index)
        }
        
        // Apply shadow
        CardBackgroundHelper.applyShadow(to: containerView)
    }

    
    func updateSubject(topic: Topics) {
        titleLabel.text = topic.title
        
        // Fetch subject name asynchronously
        Task {
            let allSubjects = try await subjectDb.findAll(where: ["id": topic.subject])
            if let subject = allSubjects.first {
                await MainActor.run {
                    self.subjectTag.text = subject.name
                }
            }
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


class CardBackgroundHelper {
    static func applyGradient(to view: GradientView, index: Int) {
        let colorSchemes: [(start: UIColor, end: UIColor)] = [
            (AppTheme.primary.withAlphaComponent(0.15), AppTheme.primary.withAlphaComponent(0.05)),
            (AppTheme.secondary.withAlphaComponent(0.15), AppTheme.secondary.withAlphaComponent(0.05))
        ]
        
        let colorIndex = index % colorSchemes.count
        let colors = colorSchemes[colorIndex]
        
        view.setGradient(
            startColor: colors.start,
            endColor: colors.end,
            startPoint: CGPoint(x: 0.0, y: 0.0),
            endPoint: CGPoint(x: 1.0, y: 1.0)
        )
    }
    
    static func applyShadow(to view: UIView) {
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
    }
}

