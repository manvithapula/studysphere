//
//  ScheduleTableViewCell.swift
//  studysphere
//
//  Created by admin64 on 03/01/25.
//

import UIKit

class ScheduleTableViewCell: UITableViewCell {
    private let containerView = UIView()
    private let iconContainer = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let progressIndicator = UIView()
    
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
        
        // Enhanced container view with more pronounced shadow
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16 // Increased corner radius
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.08 // Slightly increased shadow
        containerView.layer.shadowRadius = 8
        containerView.layer.shadowOffset = CGSize(width: 0, height: 3)
        
        // Enhanced icon container
        iconContainer.backgroundColor = AppTheme.primary.withAlphaComponent(0.15)
        iconContainer.layer.cornerRadius = 22 // Slightly larger icon container
        
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = AppTheme.primary
        
        // Enhanced title label
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold) // Slightly larger font
        titleLabel.numberOfLines = 2 // Allow two lines for longer titles
        
        // New progress indicator
        progressIndicator.layer.cornerRadius = 3
        progressIndicator.clipsToBounds = true
        
        [containerView, iconContainer, iconImageView, titleLabel, progressIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        contentView.addSubview(containerView)
        containerView.addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(progressIndicator)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            iconContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconContainer.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 44),
            iconContainer.heightAnchor.constraint(equalToConstant: 44),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 22),
            iconImageView.heightAnchor.constraint(equalToConstant: 22),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: progressIndicator.leadingAnchor, constant: -16),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            progressIndicator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            progressIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            progressIndicator.widthAnchor.constraint(equalToConstant: 6),
            progressIndicator.heightAnchor.constraint(equalToConstant: 6)
        ])
    }
    
    func configure(with item: ScheduleItem) {
        iconImageView.image = UIImage(systemName: item.iconName)
        titleLabel.text = item.title
        
        // Update progress indicator
        progressIndicator.backgroundColor = item.progress == 1
            ? UIColor.systemGreen
            : AppTheme.primary.withAlphaComponent(0.3)
        
        // Add subtle animation for progress update
        UIView.animate(withDuration: 0.3) {
            self.progressIndicator.transform = item.progress == 1
                ? CGAffineTransform(scaleX: 1.2, y: 1.2)
                : .identity
        }
    }
}
