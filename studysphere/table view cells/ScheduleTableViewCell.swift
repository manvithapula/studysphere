//
//  ScheduleTableViewCell.swift
//  studysphere
//
//  Created by admin64 on 03/01/25.
//

import UIKit

class ScheduleTableViewCell: UITableViewCell {
        // MARK: - Properties
        private let containerView: UIView = {
            let view = UIView()
            view.backgroundColor = .secondarySystemBackground
            view.layer.cornerRadius = 8
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        private let iconImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = .systemBlue
            imageView.translatesAutoresizingMaskIntoConstraints = false
            return imageView
        }()
        
        private let titleLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 16, weight: .medium)
            label.textColor = .label
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        private let subtitleLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 14)
            label.textColor = .secondaryLabel
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        private let progressView: UIProgressView = {
            let progress = UIProgressView(progressViewStyle: .default)
            progress.progressTintColor = .systemBlue
            progress.trackTintColor = .systemGray5
            progress.layer.cornerRadius = 2
            progress.clipsToBounds = true
            progress.translatesAutoresizingMaskIntoConstraints = false
            return progress
        }()
        
        // MARK: - Initialization
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            setupUI()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupUI()
        }
        
        // MARK: - Setup
        private func setupUI() {
            selectionStyle = .none
            backgroundColor = .clear
            contentView.backgroundColor = .clear
            
            contentView.addSubview(containerView)
            containerView.addSubview(iconImageView)
            containerView.addSubview(titleLabel)
            containerView.addSubview(subtitleLabel)
            containerView.addSubview(progressView)
            
            NSLayoutConstraint.activate([
                // Container view constraints
                containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
                
                // Icon image view constraints
                iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
                iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                iconImageView.widthAnchor.constraint(equalToConstant: 24),
                iconImageView.heightAnchor.constraint(equalToConstant: 24),
                
                // Title label constraints
                titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
                titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
                titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
                
                // Subtitle label constraints
                subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
                subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
                
                // Progress view constraints
                progressView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 8),
                progressView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                progressView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
                progressView.heightAnchor.constraint(equalToConstant: 4),
                progressView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
            ])
        }
        
        // MARK: - Configuration
        func configure(with item: ScheduleItem) {
            iconImageView.image = UIImage(systemName: item.iconName)
            titleLabel.text = item.title
            subtitleLabel.text = item.subtitle
            progressView.progress = item.progress
        }
    }

