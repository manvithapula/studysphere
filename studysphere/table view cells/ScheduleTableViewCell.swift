//
//  ScheduleTableViewCell.swift
//  studysphere
//
//  Created by admin64 on 03/01/25.
//

import UIKit

class ScheduleTableViewCell: UITableViewCell {
    private let containerView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let progressView = UIProgressView(progressViewStyle: .default)
    
    // Theme Colors
    private let themeDarkNavy = UIColor(red: 20/255, green: 20/255, blue: 40/255, alpha: 1)
    private let themeOrange = UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // Container styling
        containerView.backgroundColor = themeDarkNavy
        containerView.layer.cornerRadius = 12
        
        // Icon styling
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        
        // Label styling
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .white
        
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = .white.withAlphaComponent(0.7)
        
        // Progress view styling
        progressView.progressTintColor = themeOrange
        progressView.trackTintColor = UIColor.white.withAlphaComponent(0.2)
        
        // Add subviews
        contentView.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(progressView)
    }
    
    private func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Container constraints
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // Icon constraints
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // Title constraints
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            
            // Subtitle constraints
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            
            // Progress view constraints
            progressView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            progressView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 8),
            progressView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with item: ScheduleItem) {
        iconImageView.image = UIImage(systemName: item.iconName)
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        progressView.progress = item.progress
    }
}
