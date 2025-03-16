//
//  spacedCollectionViewCell.swift
//  studysphere
//
//  Created by dark on 29/10/24.
//

import UIKit

class SRCollectionViewCell: UICollectionViewCell {
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
            label.backgroundColor = AppTheme.primary.withAlphaComponent(0.1)
            label.layer.cornerRadius = 10
            label.clipsToBounds = true
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "Loading..."
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
         containerView.addSubview(titleLabel)
         containerView.addSubview(subtitleLabel)
         containerView.addSubview(subjectTag)
     }
     
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container View
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            // Title Label
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),

            // Subtitle Label
            subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),

            // Subject Tag (Below Subtitle, Left-Aligned)
            subjectTag.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            subjectTag.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 8),
            subjectTag.heightAnchor.constraint(equalToConstant: 24),
            subjectTag.widthAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ])

        // Add padding to the subject tag
        subjectTag.setPadding(horizontal: 12, vertical: 4)
    }

        
   
        
        // MARK: - Configuration
        func configure(topic: Topics, index: Int) {
            titleLabel.text = topic.title
            subtitleLabel.text = topic.subtitle
            subjectTag.text = "Loading..." // Temporary until data is fetched

            // Apply gradient based on index
            let colorSchemes: [(start: UIColor, end: UIColor)] = [
                (AppTheme.primary.withAlphaComponent(0.15), AppTheme.primary.withAlphaComponent(0.05)),
                (AppTheme.secondary.withAlphaComponent(0.15), AppTheme.secondary.withAlphaComponent(0.05))
            ]
            
            let colorIndex = index % colorSchemes.count
            let colors = colorSchemes[colorIndex]
            
            containerView.setGradient(
                startColor: colors.start,
                endColor: colors.end,
                startPoint: CGPoint(x: 0.0, y: 0.0),
                endPoint: CGPoint(x: 1.0, y: 1.0)
            )
            
            subtitleLabel.textColor = colors.start.withAlphaComponent(0.8)

            // Fetch subject asynchronously
            fetchSubject(topic: topic)
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
            subjectTag.text = "Loading..."
        }
    }

   
