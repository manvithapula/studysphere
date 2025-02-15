//
//  SummaryCollectionViewCell.swift
//  studysphere
//
//  Created by admin64 on 07/11/24.
//

import UIKit

class SummaryCollectionViewCell: UICollectionViewCell {
        // MARK: - Outlets
        @IBOutlet weak var titleLabel: UILabel!
        @IBOutlet weak var subTitleLabel: UILabel!
        @IBOutlet weak var subjectButton: UIButton!
        @IBOutlet weak var containerView: RoundNShadow!
        
       
       // MARK: - Properties
       var cardTapped: (() -> Void)?
       
       // MARK: - Lifecycle
       override func awakeFromNib() {
           super.awakeFromNib()
           setupUI()
        //   setupConstraints()
           setupGestureRecognizer()
       }
       
       // MARK: - Setup
       private func setupUI() {
           // Container View (Rounded Card with Shadow)
           containerView.backgroundColor = .white
           containerView.layer.cornerRadius = 16
           containerView.layer.shadowColor = UIColor.black.cgColor
           containerView.layer.shadowOpacity = 0.05
           containerView.layer.shadowRadius = 5
           containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
           contentView.addSubview(containerView)
           
           // Title Label
           titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
           titleLabel.textColor = .black
           titleLabel.numberOfLines = 1
           
           // Subtitle Label
           subTitleLabel.font = .systemFont(ofSize: 14, weight: .regular)
           subTitleLabel.textColor = .gray
           subTitleLabel.numberOfLines = 1
           
           // Subject Button (Tag Style)
           subjectButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
           subjectButton.setTitleColor(.blue, for: .normal)
           subjectButton.backgroundColor = UIColor.blue.withAlphaComponent(0.1)
           subjectButton.layer.cornerRadius = 12
           subjectButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
           subjectButton.isUserInteractionEnabled = false
           
           containerView.addSubview(titleLabel)
           containerView.addSubview(subTitleLabel)
           containerView.addSubview(subjectButton)
       }
       
   private func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subjectButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Container View
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            // Title Label
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),

            // Subtitle Label
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subTitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subTitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            // Subject Button
            subjectButton.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 8),
            subjectButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subjectButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
   }


       
       private func setupGestureRecognizer() {
           let tap = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
           containerView.addGestureRecognizer(tap)
           containerView.isUserInteractionEnabled = true
       }
       
       // MARK: - Actions
       @objc private func cellTapped() {
           cardTapped?()
       }
       
        
        // MARK: - Public Methods
        func updateSubject(topic: Topics) {
            Task {
                let allSubjects = try await subjectDb.findAll(where: ["id": topic.subject])
                if let subject = allSubjects.first {
                    subjectButton.setTitle(subject.name, for: .normal)
                }
            }
        }
        
        override func prepareForReuse() {
            super.prepareForReuse()
            titleLabel.text = nil
            subTitleLabel.text = nil
            subjectButton.setTitle(nil, for: .normal)
        }
    }

