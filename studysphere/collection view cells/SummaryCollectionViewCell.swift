//
//  SummaryCollectionViewCell.swift
//  studysphere
//
//  Created by admin64 on 07/11/24.
//

import UIKit


class SummaryCollectionViewCell: UICollectionViewCell {
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let itemCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let subjectTag: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .black
        label.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
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
        containerView.addSubview(itemCountLabel)
        containerView.addSubview(timeLabel)
        containerView.addSubview(subjectTag)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            itemCountLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            itemCountLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            timeLabel.centerYAnchor.constraint(equalTo: itemCountLabel.centerYAnchor),
            timeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            subjectTag.topAnchor.constraint(equalTo: itemCountLabel.bottomAnchor, constant: 8),
            subjectTag.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            subjectTag.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            subjectTag.widthAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ])
        
        subjectTag.layoutIfNeeded()
        subjectTag.layer.cornerRadius = 8
        subjectTag.setPadding(horizontal: 12, vertical: 4)
    }
    
    func updateSubject(topic: Topics) {
        titleLabel.text = topic.title
        
        if let completedDate = topic.completed {
            let timeAgo = completedDate.dateValue().timeAgoDisplay()
            timeLabel.text = timeAgo
        } else {
            timeLabel.text = "in 0 sec"
        }
        
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

// Helper extension for time ago display
extension Date {
    func timeAgoDisplay() -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day, .hour, .minute, .second], from: self, to: now)
        
        if let day = components.day, day > 0 {
            return "\(day) day\(day == 1 ? "" : "s") ago"
        } else if let hour = components.hour, hour > 0 {
            return "\(hour) hour\(hour == 1 ? "" : "s") ago"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute) minute\(minute == 1 ? "" : "s") ago"
        } else if let second = components.second {
            return "\(second) second\(second == 1 ? "" : "s") ago"
        }
        return "just now"
    }
}
