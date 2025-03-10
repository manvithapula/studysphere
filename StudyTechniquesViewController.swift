import UIKit

class StudyTechniquesViewController: UIViewController {
    
    // MARK: - Properties
    private let document: StudyDocument
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.text = "Learning Technique"
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Initialization
    init(document: StudyDocument) {
        self.document = document
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(titleLabel)
        view.addSubview(stackView)
        
        let techniques = [
            ("Spaced Repetition", "clock", UIColor.systemBlue),
            ("Active Recall", "brain.head.profile", UIColor.systemBlue),
            ("Summariser", "text.alignleft", UIColor.systemBlue)
        ]
        
        techniques.forEach { title, image, color in
            let button = createTechniqueButton(title: title, imageName: image, color: color)
            stackView.addArrangedSubview(button)
        }
        
        // Constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func createTechniqueButton(title: String, imageName: String, color: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        
        var config = UIButton.Configuration.filled()
        config.title = title
        config.image = UIImage(systemName: imageName)
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.baseBackgroundColor = UIColor.systemBlue.withAlphaComponent(0.1) // Light blue
        config.baseForegroundColor = color
        config.cornerStyle = .medium
    
        button.configuration = config
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        button.addTarget(self, action: #selector(techniqueTapped(_:)), for: .touchUpInside)
        return button
    }
    
    // MARK: - Actions
    @objc private func techniqueTapped(_ sender: UIButton) {
        guard let technique = sender.configuration?.title else { return }
        
    }
}
