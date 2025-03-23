//
//  subjectListTableViewCell.swift
//  studysphere
//
//  Created by admin64 on 05/11/24.
//

import UIKit
protocol MySubjectListTableViewControllerDelegate: AnyObject {
    func didTapEdit(for cell: subjectListTableViewCell, topic: Subject)
    func didTapDelete(for cell: subjectListTableViewCell, topic: Subject)
}
class subjectListTableViewCell: UITableViewCell {
    weak var delegate:MySubjectListTableViewControllerDelegate?
    private var swipeViewRightConstraint: NSLayoutConstraint?
    private var currentSubject:Subject?

    private let containerView = DesignManager.cardView()
    
    
    private let cardBackground: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

  
    private let iconContainer = DesignManager.iconContainer()
    

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
  
    private let titleLabel = DesignManager.cellTitleLabel()
    
  
    
    private let topicsCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = AppTheme.primary.withAlphaComponent(0.8)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var swipeActionView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var editButton = DesignManager.editButton(selector: #selector(editButtonTapped))
    
    private lazy var deleteButton = DesignManager.deleteButton(selector: #selector(deleteButtonTapped))
  
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }
    
    // MARK: - Setup
    
    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(swipeActionView)
        swipeActionView.addSubview(editButton)
        swipeActionView.addSubview(deleteButton)
        
        contentView.addSubview(containerView)
        containerView.addSubview(cardBackground)
        cardBackground.addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        cardBackground.addSubview(titleLabel)
        cardBackground.addSubview(topicsCountLabel)
        
        NSLayoutConstraint.activate([
            swipeActionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            swipeActionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            swipeActionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -5),
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
            // Container view constraints
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 110),
            
            // Card background constraints
            cardBackground.topAnchor.constraint(equalTo: containerView.topAnchor),
            cardBackground.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            cardBackground.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            cardBackground.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            
            // Icon container constraints
            iconContainer.leadingAnchor.constraint(equalTo: cardBackground.leadingAnchor, constant: 16),
            iconContainer.centerYAnchor.constraint(equalTo: cardBackground.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 48),
            iconContainer.heightAnchor.constraint(equalToConstant: 48),
            
            // Icon image view constraints
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // Title label constraints
            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: cardBackground.topAnchor, constant: 10),
           
         
            // Topics count label constraints
            topicsCountLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            topicsCountLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            topicsCountLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardBackground.bottomAnchor, constant: -16)])
        swipeViewRightConstraint = containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        swipeViewRightConstraint?.isActive = true

            
    }
    
    // MARK: - Configuration
    
    func configure(with subject: Subject, index: Int,isEditing:Bool) {
        titleLabel.text = subject.name
        currentSubject = subject
        Task{
            let allTopics = try await topicsDb.findAll(where: ["subject":subject.id])
            let topicsCount = allTopics.count
            topicsCountLabel.text = "\(topicsCount) modules"
        }
        
       
        setupIcon(for: subject.name, at: index)
        setupColors(for: index)
        resetSwipeState()
        if(isEditing){
            let newX = CGFloat(-150)// Limit swipe to -150 points
            swipeViewRightConstraint?.constant = newX
            layoutIfNeeded()
        }
    }
    private func resetSwipeState() {
        UIView.animate(withDuration: 0.3) {
            self.swipeViewRightConstraint?.constant = 0
            self.layoutIfNeeded()
        }
    }
    
    // MARK: - Action Handlers
    @objc private func editButtonTapped() {
        guard let topic = currentSubject else { return }
        delegate?.didTapEdit(for: self, topic: topic)
    }
    
    @objc private func deleteButtonTapped() {
        guard let topic = currentSubject else { return }
        delegate?.didTapDelete(for: self, topic: topic)
    }
    
    // MARK: - Subject Icon Management

    // Create an enum for subject categories with associated icons
    

    // SubjectIconService class for managing subject icons
    

    // MARK: - Usage in Cell

    private func setupIcon(for subjectName: String, at index: Int) {
        let iconService = SubjectIconService()
        let result = iconService.getIconAndCategory(for: subjectName)
        
        // Set the icon
        let iconName = result.iconName
        iconImageView.image = UIImage(systemName: iconName)
    
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
        
      
        iconContainer.backgroundColor = iconColor
        
     
        topicsCountLabel.textColor = iconColor.withAlphaComponent(0.8)
    }
    
    // MARK: - Interaction
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.2) {
            self.containerView.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            self.containerView.layer.shadowOpacity = highlighted ? 0.12 : 0.08
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        topicsCountLabel.text = nil
        iconImageView.image = UIImage(systemName: "book")
        // Reset any other properties that need resetting
    }
}



