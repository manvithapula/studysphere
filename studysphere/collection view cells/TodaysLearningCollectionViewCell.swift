//
//  TodaysLearningCollectionViewCell.swift
//  studysphere
//
//  Created by admin64 on 03/01/25.
//

import UIKit

class TodaysLearningCollectionViewCell: UICollectionViewCell {

        
        @IBOutlet weak var containerView: UIView!
        @IBOutlet weak var moduleIcon: UIImageView!
        @IBOutlet weak var titleLabel: UILabel!
        @IBOutlet weak var button: UIButton!
        @IBOutlet weak var subtitleLabel: UILabel!
        @IBOutlet weak var progressView: UIProgressView!

        override func awakeFromNib() {
            super.awakeFromNib()
            setupCell()
        }
        
        private func setupCell() {
            // Container View styling
            containerView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0)
            containerView.layer.cornerRadius = 10
            
            // Reset any existing constraints
            containerView.translatesAutoresizingMaskIntoConstraints = false
            moduleIcon.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
            progressView.translatesAutoresizingMaskIntoConstraints = false
            
            // Container View constraints
            NSLayoutConstraint.activate([
                containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
                containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                containerView.heightAnchor.constraint(equalToConstant: 80) // Fixed height for list-like appearance
            ])
            
            // Module Icon styling and constraints
            moduleIcon.tintColor = .white
            moduleIcon.contentMode = .scaleAspectFit
            NSLayoutConstraint.activate([
                moduleIcon.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
                moduleIcon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                moduleIcon.widthAnchor.constraint(equalToConstant: 24),
                moduleIcon.heightAnchor.constraint(equalToConstant: 24)
            ])
            
            // Title Label styling and constraints
            titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
            titleLabel.textColor = .white
            titleLabel.numberOfLines = 1
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
                titleLabel.leadingAnchor.constraint(equalTo: moduleIcon.trailingAnchor, constant: 12),
                titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
            ])
            
            // Subtitle Label styling and constraints
            subtitleLabel.font = .systemFont(ofSize: 12, weight: .regular)
            subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.7)
            NSLayoutConstraint.activate([
                subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 1),
                subtitleLabel.leadingAnchor.constraint(equalTo: moduleIcon.trailingAnchor, constant: 12),
                subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
            ])
            
            // Progress View styling and constraints
            progressView.trackTintColor = UIColor.white.withAlphaComponent(0.2)
            progressView.progressTintColor = .orange
            progressView.layer.cornerRadius = 3
            progressView.clipsToBounds = true
            NSLayoutConstraint.activate([
                progressView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 8),
                progressView.leadingAnchor.constraint(equalTo: moduleIcon.trailingAnchor, constant: 12),
                progressView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
                progressView.heightAnchor.constraint(equalToConstant: 6)
            ])
        }
        
        func configure(with module: ScheduleItem) {
            moduleIcon.image = UIImage(systemName: module.iconName)
            titleLabel.text = module.title
            subtitleLabel.text = module.subtitle
            progressView.progress = module.progress
            
        }
    }
