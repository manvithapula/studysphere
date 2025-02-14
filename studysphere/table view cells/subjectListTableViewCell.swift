//
//  subjectListTableViewCell.swift
//  studysphere
//
//  Created by admin64 on 05/11/24.
//

import UIKit

class subjectListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var subjectListButton: UIButton!

        
        private let containerView: UIView = {
            let view = UIView()
            view.backgroundColor = .white
            view.layer.cornerRadius = 12
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 0.05
            view.layer.shadowRadius = 5
            view.layer.shadowOffset = CGSize(width: 0, height: 2)
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        private let iconContainer: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.layer.cornerRadius = 20
            return view
        }()
        
        private let iconImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = AppTheme.primary
            imageView.image = UIImage(systemName: "book.fill")
            imageView.translatesAutoresizingMaskIntoConstraints = false
            return imageView
        }()
        
        private let titleLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 16, weight: .semibold)
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        private let dateLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 12)
            label.textColor = .secondaryLabel
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            setupCell()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupCell()
        }
        
        private func setupCell() {
            backgroundColor = .clear
            selectionStyle = .none
            
            contentView.addSubview(containerView)
            containerView.addSubview(iconContainer)
            iconContainer.addSubview(iconImageView)
            containerView.addSubview(titleLabel)
            containerView.addSubview(dateLabel)
            
            NSLayoutConstraint.activate([
                // Container view constraints
                containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
                
                // Icon container constraints
                iconContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
                iconContainer.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                iconContainer.widthAnchor.constraint(equalToConstant: 40),
                iconContainer.heightAnchor.constraint(equalToConstant: 40),
                
                // Icon image view constraints
                iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
                iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
                iconImageView.widthAnchor.constraint(equalToConstant: 20),
                iconImageView.heightAnchor.constraint(equalToConstant: 20),
                
                // Title label constraints
                titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
                titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
                titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
                
                // Date label constraints
                dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
                dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
            ])
        }
        
        func configure(with subject: Subject, index: Int) {
            titleLabel.text = subject.name
            
            // Format the date
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            let date = subject.createdAt.dateValue()
            dateLabel.text = "Created \(dateFormatter.string(from: date))"
            
            // Set the icon container background color based on the index
            iconContainer.backgroundColor = AppTheme.getSubjectColor(index).withAlphaComponent(0.1)
            iconImageView.tintColor = AppTheme.getSubjectColor(index)
        }
        
        override func setHighlighted(_ highlighted: Bool, animated: Bool) {
            super.setHighlighted(highlighted, animated: animated)
            UIView.animate(withDuration: 0.2) {
                self.containerView.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            }
        }
        
        override func prepareForReuse() {
            super.prepareForReuse()
            titleLabel.text = nil
            dateLabel.text = nil
            iconContainer.backgroundColor = nil
        }
    }
