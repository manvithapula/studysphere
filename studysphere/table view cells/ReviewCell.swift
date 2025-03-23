//
//  ReviewCell.swift
//  studysphere
//
//  Created by dark on 23/03/25.
//
import UIKit

class ReviewCell: UITableViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 8
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowRadius = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let statusBar: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let statusIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let retentionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Review", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.addSubview(statusBar)
        containerView.addSubview(statusIcon)
        containerView.addSubview(titleLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(retentionLabel)
        containerView.addSubview(startButton)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            statusBar.topAnchor.constraint(equalTo: containerView.topAnchor),
            statusBar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            statusBar.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            statusBar.widthAnchor.constraint(equalToConstant: 4),
            
            statusIcon.leadingAnchor.constraint(equalTo: statusBar.trailingAnchor, constant: 12),
            statusIcon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            statusIcon.widthAnchor.constraint(equalToConstant: 24),
            statusIcon.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: statusIcon.trailingAnchor, constant: 12),
            
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            retentionLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            retentionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            startButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            startButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            startButton.widthAnchor.constraint(equalToConstant: 100),
            startButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    func configure(day: Int, date: Date, isCompleted: Bool, schedule: String) {
        titleLabel.text = "Review \(day)"
        dateLabel.text = formatDate(date)
        
        Task {
            if isCompleted {
                statusBar.backgroundColor = .systemGreen
                statusIcon.image = UIImage(systemName: "checkmark.circle.fill")
                statusIcon.tintColor = .systemGreen
                startButton.isHidden = true
                retentionLabel.isHidden = false
                
                // Get scores from database
                let allscores = try await scoreDb.findAll(where: ["scheduleId": schedule])
                if let score = allscores.first {
                    let percentage = (Double(score.score) / Double(score.total)) * 100
                    retentionLabel.text = "\(Int(percentage))%"
                }
            } else {
                let isToday = Calendar.current.isDateInToday(date)
                statusBar.backgroundColor = isToday ? .systemBlue : .systemGray5
                statusIcon.image = isToday ? UIImage(systemName: "arrow.right.circle.fill") : UIImage(systemName: "circle.dashed")
                statusIcon.tintColor = isToday ? .systemBlue : .systemGray3
                startButton.isHidden = !isToday
                retentionLabel.isHidden = true
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM yyyy"
        return dateFormatter.string(from: date)
    }
}

