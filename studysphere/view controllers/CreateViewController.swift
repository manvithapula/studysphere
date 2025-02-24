import UIKit
import MobileCoreServices
import UniformTypeIdentifiers
import Foundation
import FirebaseCore
import GoogleGenerativeAI

// MARK: - Custom Views
class StyledTextField: UITextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStyle()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupStyle()
    }
    
    func setupStyle() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray5.cgColor
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: frame.height))
        leftViewMode = .always
        font = .systemFont(ofSize: 16)
        heightAnchor.constraint(equalToConstant: 50).isActive = true
        tintColor = .systemBlue
    }
}

class DropdownField: StyledTextField {
    private let chevronImageView = UIImageView(image: UIImage(systemName: "chevron.down"))
    
    override func setupStyle() {
        super.setupStyle()
        
        chevronImageView.tintColor = .systemGray2
        chevronImageView.contentMode = .center
        chevronImageView.frame = CGRect(x: 0, y: 0, width: 20, height: 40)
        
        rightView = chevronImageView
        rightViewMode = .always
        
        // Make the field non-editable
        isUserInteractionEnabled = true
        isEnabled = true
    }
}

class TechniqueButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStyle()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupStyle()
    }
    
    private func setupStyle() {
        backgroundColor = .systemBlue.withAlphaComponent(0.1)
        layer.cornerRadius = 20
        titleLabel?.font = .systemFont(ofSize: 16)
        setTitleColor(.systemBlue, for: .normal)
        contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
    }
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? .systemBlue.withAlphaComponent(0.2) : .systemBlue.withAlphaComponent(0.1)
        }
    }
}

class CreateViewController: UIViewController {
    // MARK: - Properties
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let unitNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Unit Name"
        label.font = .systemFont(ofSize: 17, weight: .medium)
        return label
    }()
    
    private let unitNameField = StyledTextField()
    
    private let subjectLabel: UILabel = {
        let label = UILabel()
        label.text = "Subject"
        label.font = .systemFont(ofSize: 17, weight: .medium)
        return label
    }()
    
    private let subjectField = DropdownField()
    
    private let techniqueLabel: UILabel = {
        let label = UILabel()
        label.text = "Learning Technique"
        label.font = .systemFont(ofSize: 17, weight: .medium)
        return label
    }()
    
    private let techniqueStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fillProportionally
        return stack
    }()
    
    private lazy var spacedRepetitionButton: TechniqueButton = {
        let button = TechniqueButton()
        let imageConfig = UIImage.SymbolConfiguration(scale: .medium)
        let clockImage = UIImage(systemName: "clock", withConfiguration: imageConfig)
        button.setImage(clockImage, for: .normal)
        button.setTitle(" Spaced Repetition", for: .normal)
        button.addTarget(self, action: #selector(techniqueTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var activeRecallButton: TechniqueButton = {
        let button = TechniqueButton()
        let imageConfig = UIImage.SymbolConfiguration(scale: .medium)
        let brainImage = UIImage(systemName: "brain", withConfiguration: imageConfig)
        button.setImage(brainImage, for: .normal)
        button.setTitle(" Active Recall", for: .normal)
        button.addTarget(self, action: #selector(techniqueTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var summariserButton: TechniqueButton = {
        let button = TechniqueButton()
        let imageConfig = UIImage.SymbolConfiguration(scale: .medium)
        let textImage = UIImage(systemName: "text.alignleft", withConfiguration: imageConfig)
        button.setImage(textImage, for: .normal)
        button.setTitle(" Summariser", for: .normal)
        button.addTarget(self, action: #selector(techniqueTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    private let uploadLabel: UILabel = {
        let label = UILabel()
        label.text = "Upload Document"
        label.font = .systemFont(ofSize: 17, weight: .medium)
        return label
    }()
    
    private let fileUploadView = DashedRectangle()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = .systemGray4
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }()
    
    private var dropdownTableView: UITableView?
    private var subjects: [Subject] = []
    private var selectedTechnique: String?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        
        Task {
            subjects = try await subjectDb.findAll()
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Setup scroll view and content
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [scrollView, contentView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // Add all components
        [unitNameLabel, unitNameField, subjectLabel, subjectField,
         techniqueLabel, techniqueStackView, uploadLabel,
         fileUploadView, createButton].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // Setup technique buttons
        techniqueStackView.addArrangedSubview(spacedRepetitionButton)
        techniqueStackView.addArrangedSubview(activeRecallButton)
        techniqueStackView.addArrangedSubview(summariserButton)
        
        // Setup text fields
        unitNameField.placeholder = "Enter unit name"
        subjectField.placeholder = "Select Subject"
        
        // Layout constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Unit Name
            unitNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            unitNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            unitNameField.topAnchor.constraint(equalTo: unitNameLabel.bottomAnchor, constant: 8),
            unitNameField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            unitNameField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Subject
            subjectLabel.topAnchor.constraint(equalTo: unitNameField.bottomAnchor, constant: 20),
            subjectLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            subjectField.topAnchor.constraint(equalTo: subjectLabel.bottomAnchor, constant: 8),
            subjectField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            subjectField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Technique
            techniqueLabel.topAnchor.constraint(equalTo: subjectField.bottomAnchor, constant: 20),
            techniqueLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            techniqueStackView.topAnchor.constraint(equalTo: techniqueLabel.bottomAnchor, constant: 8),
            techniqueStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            techniqueStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Upload
            uploadLabel.topAnchor.constraint(equalTo: techniqueStackView.bottomAnchor, constant: 20),
            uploadLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            fileUploadView.topAnchor.constraint(equalTo: uploadLabel.bottomAnchor, constant: 8),
            fileUploadView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            fileUploadView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            fileUploadView.heightAnchor.constraint(equalToConstant: 150),
            
            // Create Button
            createButton.topAnchor.constraint(equalTo: fileUploadView.bottomAnchor, constant: 30),
            createButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        // Setup file upload view
        fileUploadView.setup(in: self)
    }
    
    private func setupActions() {
        subjectField.addTarget(self, action: #selector(showSubjectDropdown), for: .touchDown)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func showSubjectDropdown() {
        dropdownTableView?.removeFromSuperview()
        
        let tableView = UITableView()
        tableView.backgroundColor = .systemBackground
        tableView.layer.cornerRadius = 12
        tableView.layer.borderWidth = 1
        tableView.layer.borderColor = UIColor.systemGray5.cgColor
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: subjectField.bottomAnchor, constant: 5),
            tableView.leadingAnchor.constraint(equalTo: subjectField.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: subjectField.trailingAnchor),
            tableView.heightAnchor.constraint(lessThanOrEqualToConstant: 200)
        ])
        
        dropdownTableView = tableView
        tableView.reloadData()
    }
    
    @objc private func techniqueTapped(_ sender: TechniqueButton) {
        // Toggle selection
        spacedRepetitionButton.isSelected = sender == spacedRepetitionButton
        activeRecallButton.isSelected = sender == activeRecallButton
        summariserButton.isSelected = sender == summariserButton
        selectedTechnique = sender.titleLabel?.text?.trimmingCharacters(in: .whitespaces)
        
        // Enable create button if all fields are filled
        updateCreateButtonState()
    }
    
    @objc private func createButtonTapped() {
        // Implement creation logic
    }
    
    private func updateCreateButtonState() {
        let isValid = !(unitNameField.text?.isEmpty ?? true) &&
                     !(subjectField.text?.isEmpty ?? true) &&
                     selectedTechnique != nil
        
        createButton.backgroundColor = isValid ? .systemBlue : .systemGray4
        createButton.isEnabled = isValid
    }
    
    private func hideDropdown() {
        dropdownTableView?.removeFromSuperview()
        dropdownTableView = nil
    }
}

// MARK: - UITableViewDelegate & DataSource
extension CreateViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "SubjectCell")
        cell.textLabel?.text = subjects[indexPath.row].name
        cell.textLabel?.font = .systemFont(ofSize: 16)
        cell.backgroundColor = .clear
        
        // Remove the selection style
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        subjectField.text = subjects[indexPath.row].name
        hideDropdown()
        updateCreateButtonState()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 44
        }
    }

    // MARK: - UITextFieldDelegate
    extension CreateViewController: UITextFieldDelegate {
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            // Only allow editing for unitNameField
            return textField == unitNameField
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            updateCreateButtonState()
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            if textField == subjectField {
                textField.resignFirstResponder()
                showSubjectDropdown()
            }
        }
    }

    // MARK: - Touch Handling
    extension CreateViewController {
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            super.touchesBegan(touches, with: event)
            
            // Hide dropdown when tapping outside
            if let touch = touches.first {
                let location = touch.location(in: view)
                if let dropdownTableView = dropdownTableView,
                   !dropdownTableView.frame.contains(location) && !subjectField.frame.contains(location) {
                    hideDropdown()
                }
            }
            
            view.endEditing(true)
        }
    }

    // MARK: - UIDocumentPickerDelegate
    extension CreateViewController: UIDocumentPickerDelegate {
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let selectedFileURL = urls.first else { return }
            
            // Handle the selected file
            let fileName = selectedFileURL.lastPathComponent
            // Update UI or store file reference as needed
            
            updateCreateButtonState()
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            // Handle cancelled picker if needed
        }
    }

    // MARK: - File Upload View
    class DashedRectangle: UIView {
        private let iconImageView: UIImageView = {
            let imageView = UIImageView()
            let config = UIImage.SymbolConfiguration(pointSize: 30)
            imageView.image = UIImage(systemName: "doc.badge.plus", withConfiguration: config)
            imageView.tintColor = .systemBlue
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()
        
        private let titleLabel: UILabel = {
            let label = UILabel()
            label.text = "Drop your files here"
            label.font = .systemFont(ofSize: 16, weight: .medium)
            label.textColor = .systemBlue
            return label
        }()
        
        private let subtitleLabel: UILabel = {
            let label = UILabel()
            label.text = "or click to browse"
            label.font = .systemFont(ofSize: 14)
            label.textColor = .systemGray
            return label
        }()
        
        private let supportLabel: UILabel = {
            let label = UILabel()
            label.text = "Supports PDF files"
            label.font = .systemFont(ofSize: 12)
            label.textColor = .systemGray
            return label
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupView()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupView()
        }
        
        private func setupView() {
            backgroundColor = .systemBackground
            layer.cornerRadius = 12
            
            // Add dashed border
            let borderLayer = CAShapeLayer()
            borderLayer.strokeColor = UIColor.systemGray4.cgColor
            borderLayer.lineDashPattern = [6, 6]
            borderLayer.frame = bounds
            borderLayer.fillColor = nil
            borderLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
            layer.addSublayer(borderLayer)
            
            // Add subviews
            [iconImageView, titleLabel, subtitleLabel, supportLabel].forEach {
                addSubview($0)
                $0.translatesAutoresizingMaskIntoConstraints = false
            }
            
            NSLayoutConstraint.activate([
                iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
                iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -20),
                
                titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 8),
                titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                
                subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
                subtitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                
                supportLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 4),
                supportLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
            ])
            
            // Update border layer when frame changes
            addObserver(self, forKeyPath: "bounds", options: .new, context: nil)
        }
        
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            if keyPath == "bounds" {
                // Update border layer path when bounds change
                if let borderLayer = layer.sublayers?.first as? CAShapeLayer {
                    borderLayer.frame = bounds
                    borderLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
                }
            }
        }
        
        func setup(in viewController: UIViewController) {
            // Add tap gesture
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            addGestureRecognizer(tapGesture)
            isUserInteractionEnabled = true
        }
        
        @objc private func handleTap() {
            let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf], asCopy: true)
            documentPicker.delegate = self.superview?.parentViewController as? UIDocumentPickerDelegate
            documentPicker.allowsMultipleSelection = false
            self.superview?.parentViewController?.present(documentPicker, animated: true)
        }
        
        deinit {
            removeObserver(self, forKeyPath: "bounds")
        }
    }

    // MARK: - Helper Extension
    extension UIView {
        var parentViewController: UIViewController? {
            var parentResponder: UIResponder? = self
            while parentResponder != nil {
                parentResponder = parentResponder?.next
                if let viewController = parentResponder as? UIViewController {
                    return viewController
                }
            }
            return nil
        }
    }
