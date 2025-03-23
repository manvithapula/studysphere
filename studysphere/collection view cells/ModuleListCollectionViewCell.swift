//
//  spacedCollectionViewCell.swift
//  studysphere
//
//  Created by dark on 29/10/24.
//

import UIKit

protocol SRCollectionViewCellDelegate: AnyObject {
    func didTapEdit(for cell: ModuleListCollectionViewCell, topic: Topics)
    func didTapDelete(for cell: ModuleListCollectionViewCell, topic: Topics)
}

class ModuleListCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    weak var delegate: SRCollectionViewCellDelegate?
    private var currentTopic: Topics?
    
    // MARK: - UI Elements
    private let containerView = DesignManager.cardView()
    
    private let cardBackground: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel = DesignManager.cellTitleLabel()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subjectTag  = DesignManager.subjectTag()
    
    // MARK: - Swipe Gesture Elements
    private lazy var swipeActionView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var editButton = DesignManager.editButton(selector: #selector(editButtonTapped))
    
    private lazy var deleteButton = DesignManager.deleteButton(selector: #selector(deleteButtonTapped))
    
    private var initialTouchPoint: CGPoint = .zero
    private var swipeViewRightConstraint: NSLayoutConstraint?
    
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
        contentView.addSubview(swipeActionView)
        swipeActionView.addSubview(editButton)
        swipeActionView.addSubview(deleteButton)
        
        contentView.addSubview(containerView)
        containerView.addSubview(cardBackground)
        cardBackground.addSubview(titleLabel)
        cardBackground.addSubview(subtitleLabel)
        cardBackground.addSubview(subjectTag)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Swipe Action View
            swipeActionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            swipeActionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            swipeActionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            swipeActionView.widthAnchor.constraint(equalToConstant: 150),
            
            // Edit Button
            editButton.leadingAnchor.constraint(equalTo: swipeActionView.leadingAnchor, constant: 8),
            editButton.centerYAnchor.constraint(equalTo: swipeActionView.centerYAnchor),
            editButton.widthAnchor.constraint(equalToConstant: 60),
            editButton.heightAnchor.constraint(equalToConstant: 36),
            
            // Delete Button
            deleteButton.leadingAnchor.constraint(equalTo: editButton.trailingAnchor, constant: 8),
            deleteButton.centerYAnchor.constraint(equalTo: swipeActionView.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 60),
            deleteButton.heightAnchor.constraint(equalToConstant: 36),
            
            // Container View
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            
            // Card Background
            cardBackground.topAnchor.constraint(equalTo: containerView.topAnchor),
            cardBackground.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            cardBackground.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            cardBackground.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            // Title Label
            titleLabel.leadingAnchor.constraint(equalTo: cardBackground.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: cardBackground.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: cardBackground.topAnchor, constant: 16),
            
            // Subtitle Label
            subtitleLabel.leadingAnchor.constraint(equalTo: cardBackground.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: cardBackground.trailingAnchor, constant: -16),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            
            // Subject Tag
            subjectTag.leadingAnchor.constraint(equalTo: cardBackground.leadingAnchor, constant: 16),
            subjectTag.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 8),
            subjectTag.bottomAnchor.constraint(equalTo: cardBackground.bottomAnchor, constant: -16),
            subjectTag.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            subjectTag.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        // Initialize containerView right constraint
        swipeViewRightConstraint = containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        swipeViewRightConstraint?.isActive = true
        
    }
    
    
    // MARK: - Configuration
    func configure(topic: Topics, index: Int,isEditing: Bool) {
        titleLabel.text = topic.title
        subtitleLabel.text = topic.subtitle
        subjectTag.text = "" // Temporary until data is fetched
        currentTopic = topic
        setupColors(for: index)
        fetchSubject(topic: topic)
        
        // Reset swipe state
        resetSwipeState()
        if(isEditing){
            let newX = CGFloat(-150)// Limit swipe to -150 points
            swipeViewRightConstraint?.constant = newX
            layoutIfNeeded()
        }
    }

    private func setupColors(for index: Int) {
        let colorSchemes: [UIColor] = [
            AppTheme.primary.withAlphaComponent(0.15),
            AppTheme.secondary.withAlphaComponent(0.15)
        ]
        let iconColorSchemes: [UIColor] = [
            AppTheme.primary,
            AppTheme.secondary
        ]
        
        let colorIndex = index % colorSchemes.count
        let backgroundColor = colorIndex < colorSchemes.count ?
                             colorSchemes[colorIndex] :
                             UIColor.systemGray.withAlphaComponent(0.15)
        
        let iconColor = colorIndex < iconColorSchemes.count ?
                       iconColorSchemes[colorIndex] :
                       UIColor.systemGray
        
        cardBackground.backgroundColor = backgroundColor
        subtitleLabel.textColor = iconColor.withAlphaComponent(0.8)
        subjectTag.backgroundColor = iconColor.withAlphaComponent(0.2)
    }

    // MARK: - Gesture Handling
    
    
    private func resetSwipeState() {
        UIView.animate(withDuration: 0.3) {
            self.swipeViewRightConstraint?.constant = 0
            self.layoutIfNeeded()
        }
    }
    
    // MARK: - Action Handlers
    @objc private func editButtonTapped() {
        guard let topic = currentTopic else { return }
        delegate?.didTapEdit(for: self, topic: topic)
    }
    
    @objc private func deleteButtonTapped() {
        guard let topic = currentTopic else { return }
        delegate?.didTapDelete(for: self, topic: topic)
    }

    // MARK: - Highlight Handling
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.containerView.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
                self.containerView.layer.shadowOpacity = self.isHighlighted ? 0.12 : 0.08
            }
        }
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
        subjectTag.text = " "
        currentTopic = nil
        resetSwipeState()
    }
}
