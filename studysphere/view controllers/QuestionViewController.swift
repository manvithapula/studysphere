import UIKit
import FirebaseCore
import FirebaseFirestore

class QuestionViewController: UIViewController {
    // MARK: - Properties
    private var currentQuestionIndex = 0
    private var score = 0
     var topic: Topics?
     var questions: [Questions] = []
     var schedule: Schedule?
    private var selectedButton: UIButton?
    
    // MARK: - UI Components
    private let progressBar = UIProgressView(progressViewStyle: .default)
    private let progressLabel = UILabel()
    private let questionCardView = UIView()
    private let questionNumberLabel = UILabel()
    private let questionTextLabel = UILabel()
    private let optionStackView = UIStackView()
    private let optionButtons: [UIButton] = (0..<4).map { _ in UIButton(type: .system) }
    private let nextButton = UIButton(type: .system)
    
    // MARK: - Colors
    private let backgroundColor = AppTheme.secondary
    private let correctColor = UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 0.15) // Softer correct green
    private let incorrectColor = UIColor(red: 0.95, green: 0.3, blue: 0.25, alpha: 0.15) // Softer incorrect red
    private let cardColor = UIColor.white
    private let textColor = UIColor(red: 0.15, green: 0.2, blue: 0.3, alpha: 1.0) // Dark blue-gray
    private let buttonBorderColor = UIColor.systemGray4.cgColor
    private let shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupUI()
        
        Task {
            if let topic = topic {
                questions = try await questionsDb.findAll(where: ["topic": topic.id])
                loadQuestion()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.isTabBarHidden = true
    }
    
    // MARK: - Background Setup
    private func setupBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor(red: 0.94, green: 0.97, blue: 1.0, alpha: 1.0).cgColor,
            UIColor(red: 0.97, green: 0.99, blue: 1.0, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupProgressBar()
        setupQuestionCard()
        setupOptionStack()
        setupNextButton()
        applyConstraints()
    }
    
    
    private func setupProgressBar() {
        progressBar.progressTintColor = AppTheme.secondary
        progressBar.trackTintColor = AppTheme.primary.withAlphaComponent(0.2)
        progressBar.progress = 0.0
        progressBar.layer.cornerRadius = 6
        progressBar.clipsToBounds = true
        progressBar.layer.masksToBounds = true
        progressBar.transform = progressBar.transform.scaledBy(x: 1.0, y: 1.5)
        view.addSubview(progressBar)
        
        progressLabel.textAlignment = .center
        progressLabel.textColor = textColor.withAlphaComponent(0.7)
        progressLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        progressLabel.text = "0%"
        view.addSubview(progressLabel)
    }
    
    private func setupQuestionCard() {
        // Setup card view
        questionCardView.backgroundColor = cardColor
        questionCardView.layer.cornerRadius = 20
        questionCardView.layer.shadowColor = shadowColor
        questionCardView.layer.shadowOffset = CGSize(width: 0, height: 8)
        questionCardView.layer.shadowOpacity = 0.2
        questionCardView.layer.shadowRadius = 12
        questionCardView.layer.masksToBounds = false
        view.addSubview(questionCardView)
        
        // Question number label with accent bar
        let questionNumberContainer = UIView()
        questionNumberContainer.backgroundColor = AppTheme.primary.withAlphaComponent(0.1)
        questionNumberContainer.layer.cornerRadius = 12
        questionCardView.addSubview(questionNumberContainer)
        
        questionNumberLabel.textAlignment = .left
        questionNumberLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        questionNumberLabel.textColor = AppTheme.primary
        questionNumberLabel.text = "Question 1/10"
        questionNumberContainer.addSubview(questionNumberLabel)
        
        // Question text
        questionTextLabel.textAlignment = .left
        questionTextLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        questionTextLabel.numberOfLines = 0
        questionTextLabel.textColor = textColor
        questionTextLabel.text = "Loading question..."
        questionCardView.addSubview(questionTextLabel)
        
        // Make everything use auto layout
        questionNumberContainer.translatesAutoresizingMaskIntoConstraints = false
        questionNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Constraints for question number container and label
        NSLayoutConstraint.activate([
            questionNumberContainer.topAnchor.constraint(equalTo: questionCardView.topAnchor, constant: 20),
            questionNumberContainer.leadingAnchor.constraint(equalTo: questionCardView.leadingAnchor, constant: 20),
            questionNumberContainer.heightAnchor.constraint(equalToConstant: 34),
            
            questionNumberLabel.topAnchor.constraint(equalTo: questionNumberContainer.topAnchor),
            questionNumberLabel.bottomAnchor.constraint(equalTo: questionNumberContainer.bottomAnchor),
            questionNumberLabel.leadingAnchor.constraint(equalTo: questionNumberContainer.leadingAnchor, constant: 14),
            questionNumberLabel.trailingAnchor.constraint(equalTo: questionNumberContainer.trailingAnchor, constant: -14)
        ])
    }
    
    private func setupOptionStack() {
        optionStackView.axis = .vertical
        optionStackView.spacing = 12
        // Change distribution from fillEqually to fill so buttons can have different heights
        optionStackView.distribution = .fill
        view.addSubview(optionStackView)
        
        for (index, button) in optionButtons.enumerated() {
            button.tag = index
            button.setTitle("Option \(index + 1)", for: .normal)
            button.setTitleColor(textColor, for: .normal)
            
            // Set font size a bit smaller
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            
            // Allow title label to wrap text
            button.titleLabel?.numberOfLines = 0
            button.titleLabel?.lineBreakMode = .byWordWrapping
            
            button.contentHorizontalAlignment = .left
            // Adjust insets to provide more space for text
            button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 40)
            button.layer.cornerRadius = 16
            button.backgroundColor = .white
            
            // Add subtle border
            button.layer.borderWidth = 1.5
            button.layer.borderColor = UIColor.systemGray5.cgColor
            
            // Add shadow
            button.layer.shadowColor = shadowColor
            button.layer.shadowOffset = CGSize(width: 0, height: 3)
            button.layer.shadowOpacity = 0.15
            button.layer.shadowRadius = 6
            button.layer.masksToBounds = false
            
            // Show option letter (A, B, C, D)
            let optionLetterView = UIView()
            optionLetterView.backgroundColor = AppTheme.primary.withAlphaComponent(0.1)
            optionLetterView.layer.cornerRadius = 14
            optionLetterView.translatesAutoresizingMaskIntoConstraints = false
            button.addSubview(optionLetterView)
            
            let optionLetter = UILabel()
            optionLetter.text = String(Character(UnicodeScalar(65 + index)!)) // A, B, C, D
            optionLetter.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            optionLetter.textColor = AppTheme.primary
            optionLetter.textAlignment = .center
            optionLetter.translatesAutoresizingMaskIntoConstraints = false
            optionLetterView.addSubview(optionLetter)
            
            // Constraints for option letters
            NSLayoutConstraint.activate([
                optionLetterView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 20),
                optionLetterView.topAnchor.constraint(equalTo: button.topAnchor, constant: 18),
                optionLetterView.widthAnchor.constraint(equalToConstant: 28),
                optionLetterView.heightAnchor.constraint(equalToConstant: 28),
                
                optionLetter.centerXAnchor.constraint(equalTo: optionLetterView.centerXAnchor),
                optionLetter.centerYAnchor.constraint(equalTo: optionLetterView.centerYAnchor)
            ])
            
            // Adjust text position
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 38, bottom: 0, right: 20)
            
            button.addTarget(self, action: #selector(optionButtonTapped(_:)), for: .touchUpInside)
            button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
            button.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpOutside, .touchCancel])
            
            optionStackView.addArrangedSubview(button)
        }
    }
    
    private func setupNextButton() {
        nextButton.setTitle("Continue", for: .normal)
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        
        // Create gradient layer for button
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors =  [AppTheme.secondary.cgColor, AppTheme.primary.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = 20
        nextButton.layer.insertSublayer(gradientLayer, at: 0)
        
        nextButton.layer.cornerRadius = 20
        nextButton.clipsToBounds = true
        nextButton.isEnabled = false
        nextButton.alpha = 0.7
        
        // Add shadow view behind button
        let shadowView = UIView()
        shadowView.backgroundColor = .clear
        shadowView.layer.shadowColor = AppTheme.primary.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 4)
        shadowView.layer.shadowOpacity = 0.3
        shadowView.layer.shadowRadius = 8
        shadowView.layer.cornerRadius = 20
        view.addSubview(shadowView)
        view.addSubview(nextButton)
        
        // Add touch animations
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        nextButton.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpOutside, .touchCancel])
        
        // Make shadow view use auto layout
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add constraints for shadow view to match button
        nextButton.addObserver(self, forKeyPath: "frame", options: .new, context: nil)
        self.nextButtonShadowView = shadowView
    }
    
    private var nextButtonShadowView: UIView?
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let button = object as? UIButton, button == nextButton, keyPath == "frame" {
            nextButtonShadowView?.frame = button.frame
            if let gradientLayer = button.layer.sublayers?.first as? CAGradientLayer {
                gradientLayer.frame = button.bounds
            }
        }
    }
    
    private func applyConstraints() {
        // Make all views use auto layout
        for view in [progressBar, progressLabel, questionCardView, questionTextLabel, optionStackView, nextButton] {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // Safe area and margins
        let safeArea = view.safeAreaLayoutGuide
        let margins = view.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            
            // Progress bar
            progressBar.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 30),
            progressBar.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 8),
            progressBar.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -8),
            progressBar.heightAnchor.constraint(equalToConstant: 8),
            
            // Progress label
            progressLabel.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 6),
            progressLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Question card
            questionCardView.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 16),
            questionCardView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 4),
            questionCardView.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -4),
            
            // Question text
            questionTextLabel.topAnchor.constraint(equalTo: questionNumberLabel.bottomAnchor, constant: 16),
            questionTextLabel.leadingAnchor.constraint(equalTo: questionCardView.leadingAnchor, constant: 20),
            questionTextLabel.trailingAnchor.constraint(equalTo: questionCardView.trailingAnchor, constant: -20),
            questionTextLabel.bottomAnchor.constraint(equalTo: questionCardView.bottomAnchor, constant: -20),
            
            // Option stack
            optionStackView.topAnchor.constraint(equalTo: questionCardView.bottomAnchor, constant: 20),
            optionStackView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 4),
            optionStackView.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -4),
            
            // Next button
            nextButton.topAnchor.constraint(equalTo: optionStackView.bottomAnchor, constant: 24),
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: 200),
            nextButton.heightAnchor.constraint(equalToConstant: 56),
            nextButton.bottomAnchor.constraint(lessThanOrEqualTo: safeArea.bottomAnchor, constant: -20)
        ])
        
        // Set minimum height for option buttons instead of fixed height
        for button in optionButtons {
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: 64).isActive = true
        }
    }
    
    // MARK: - Button Touch Animations
    @objc private func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }
    }
    
    @objc private func buttonTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = .identity
        }
    }
    
    // MARK: - Quiz Logic
    private func loadQuestion() {
        if currentQuestionIndex >= questions.count {
            showFinalScore()
            return
        }
        
        let currentQuestion = questions[currentQuestionIndex]
        
        // Update UI with question data
        questionNumberLabel.text = "Question \(currentQuestionIndex + 1)/\(questions.count)"
        questionTextLabel.text = currentQuestion.question
        
        // Update option buttons
        let options = [
            currentQuestion.option1,
            currentQuestion.option2,
            currentQuestion.option3,
            currentQuestion.option4
        ]
        
        // Reset all buttons before setting new content
        for (index, button) in optionButtons.enumerated() {
            resetButtonState(button)  // This should now do a complete reset
            button.setTitle(options[index], for: .normal)
        }
        
        // Reset next button
        nextButton.isEnabled = false
        nextButton.alpha = 0.7
        selectedButton = nil
        
        // Update progress bar
        updateProgress()
    }
    
    private func resetButtonState(_ button: UIButton){
        // Reset visual properties
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.systemGray5.cgColor
        button.layer.borderWidth = 1.5
        button.setTitleColor(textColor, for: .normal)
        button.isEnabled = true
        button.transform = .identity
        
        // Reset option letter view
        for subview in button.subviews {
            if let optionView = subview as? UIView,
               (optionView.backgroundColor == AppTheme.primary.withAlphaComponent(0.1) ||
                optionView.backgroundColor == UIColor.systemGreen.withAlphaComponent(0.2) ||
                optionView.backgroundColor == UIColor.systemRed.withAlphaComponent(0.2)) {
                
                optionView.backgroundColor = AppTheme.primary.withAlphaComponent(0.1)
                
                // Reset the label inside option view
                for labelView in optionView.subviews {
                    if let label = labelView as? UILabel {
                        label.textColor = AppTheme.primary
                    }
                }
            }
        }
        for subview in button.subviews {
            if subview is UIImageView {
                subview.removeFromSuperview()
            }
        }
    }


    private func resetAllButtonStates() {
        optionButtons.forEach { resetButtonState($0) }
    }

    private func updateProgress() {
        let progress = Float(currentQuestionIndex) / Float(questions.count)
        progressBar.setProgress(progress, animated: true)

        let percentage = Int(progress * 100)
        progressLabel.text = "\(percentage)%"
    }

    private func showFinalScore() {
        Task {
            schedule?.completed = Timestamp()
            if var scheduleTemp = schedule {
                try await schedulesDb.update(&scheduleTemp)
            }
            var score = Score(id: "", score: score, total: questions.count, scheduleId: schedule!.id, topicId: schedule!.topic, createdAt: Timestamp(), updatedAt: Timestamp())
            let _ = scoreDb.create(&score)
            
        }
        performSegue(withIdentifier: "toARAnimation", sender: self)
    }

    // MARK: - Actions
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func optionButtonTapped(_ sender: UIButton) {
        if currentQuestionIndex >= questions.count {
            showFinalScore()
            return
        }
        // Store selected button
        selectedButton = sender
        
        // Disable all buttons
        optionButtons.forEach { $0.isEnabled = false }

        let currentQuestion = questions[currentQuestionIndex]

        // Get selected option index
        let selectedOptionIndex = sender.tag
        let selectedOption: String
        switch selectedOptionIndex {
        case 0: selectedOption = currentQuestion.option1
        case 1: selectedOption = currentQuestion.option2
        case 2: selectedOption = currentQuestion.option3
        case 3: selectedOption = currentQuestion.option4
        default: selectedOption = ""
        }

        // Check answer
        if selectedOption == currentQuestion.correctanswer {
            // Correct answer
            UIView.animate(withDuration: 0.2) {
                sender.backgroundColor = self.correctColor
                sender.layer.borderColor = UIColor.systemGreen.cgColor
                sender.layer.borderWidth = 2
                
                // Update option letter view
                if let optionView = sender.subviews.first(where: { $0.backgroundColor == AppTheme.primary.withAlphaComponent(0.1) }) {
                    optionView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
                    if let label = optionView.subviews.first as? UILabel {
                        label.textColor = UIColor.systemGreen
                    }
                }
            }
            
            // Add checkmark
            let checkmarkImage = UIImageView(image: UIImage(systemName: "checkmark.circle.fill")?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal))
            checkmarkImage.translatesAutoresizingMaskIntoConstraints = false
            sender.addSubview(checkmarkImage)
            
            NSLayoutConstraint.activate([
                checkmarkImage.trailingAnchor.constraint(equalTo: sender.trailingAnchor, constant: -20),
                checkmarkImage.centerYAnchor.constraint(equalTo: sender.centerYAnchor),
                checkmarkImage.widthAnchor.constraint(equalToConstant: 24),
                checkmarkImage.heightAnchor.constraint(equalToConstant: 24)
            ])
            
            score += 1
        } else {
            // Incorrect answer
            UIView.animate(withDuration: 0.2) {
                sender.backgroundColor = self.incorrectColor
                sender.layer.borderColor = UIColor.systemRed.cgColor
                sender.layer.borderWidth = 2
                
                // Update option letter view
                if let optionView = sender.subviews.first(where: { $0.backgroundColor == AppTheme.primary.withAlphaComponent(0.1) }) {
                    optionView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.2)
                    if let label = optionView.subviews.first as? UILabel {
                        label.textColor = UIColor.systemRed
                    }
                }
            }
            
            // Add X mark
            let xmarkImage = UIImageView(image: UIImage(systemName: "xmark.circle.fill")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal))
            xmarkImage.translatesAutoresizingMaskIntoConstraints = false
            sender.addSubview(xmarkImage)
            
            NSLayoutConstraint.activate([
                xmarkImage.trailingAnchor.constraint(equalTo: sender.trailingAnchor, constant: -20),
                xmarkImage.centerYAnchor.constraint(equalTo: sender.centerYAnchor),
                xmarkImage.widthAnchor.constraint(equalToConstant: 24),
                xmarkImage.heightAnchor.constraint(equalToConstant: 24)
            ])

            // Highlight correct answer
            for (index, button) in optionButtons.enumerated() {
                let option: String
                switch index {
                case 0: option = currentQuestion.option1
                case 1: option = currentQuestion.option2
                case 2: option = currentQuestion.option3
                case 3: option = currentQuestion.option4
                default: option = ""
                }

                if option == currentQuestion.correctanswer {
                    UIView.animate(withDuration: 0.2) {
                        button.backgroundColor = self.correctColor
                        button.layer.borderColor = UIColor.systemGreen.cgColor
                        button.layer.borderWidth = 2
                        
                        // Update option letter view
                        if let optionView = button.subviews.first(where: { $0.backgroundColor == AppTheme.primary.withAlphaComponent(0.1) }) {
                            optionView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
                            if let label = optionView.subviews.first as? UILabel {
                                label.textColor = UIColor.systemGreen
                            }
                        }
                    }
                    
                    // Add checkmark to correct answer
                    let correctMark = UIImageView(image: UIImage(systemName: "checkmark.circle.fill")?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal))
                    correctMark.translatesAutoresizingMaskIntoConstraints = false
                    button.addSubview(correctMark)
                    
                    NSLayoutConstraint.activate([
                        correctMark.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -20),
                        correctMark.centerYAnchor.constraint(equalTo: button.centerYAnchor),
                        correctMark.widthAnchor.constraint(equalToConstant: 24),
                        correctMark.heightAnchor.constraint(equalToConstant: 24)
                    ])
                    
                    break
                }
            }
        }

        // Enable next button with animation
        UIView.animate(withDuration: 0.3) {
            self.nextButton.isEnabled = true
            self.nextButton.alpha = 1.0
            
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1){
                self.nextButtonTapped()
            }
        }
    }

    @objc private func nextButtonTapped() {
        // Animate transition to next question
        UIView.animate(withDuration: 0.3, animations: {
            self.questionCardView.alpha = 0.7
            self.optionStackView.alpha = 0.7
            self.questionCardView.transform = CGAffineTransform(translationX: -30, y: 0)
            self.optionStackView.transform = CGAffineTransform(translationX: -30, y: 0)
        }, completion: { _ in
            // Completely reset all buttons
            self.optionButtons.forEach { self.resetButtonState($0) }
            
            self.currentQuestionIndex += 1
            self.loadQuestion()
            
            self.questionCardView.transform = CGAffineTransform(translationX: 30, y: 0)
            self.optionStackView.transform = CGAffineTransform(translationX: 30, y: 0)
            
            UIView.animate(withDuration: 0.3) {
                self.questionCardView.alpha = 1.0
                self.optionStackView.alpha = 1.0
                self.questionCardView.transform = .identity
                self.optionStackView.transform = .identity
            }
        })
    }

    // MARK: - Public Configuration
    func configure(with topic: Topics, schedule: Schedule? = nil) {
        self.topic = topic
        self.schedule = schedule
    }
    
    // MARK: - Cleanup
    deinit {
        nextButton.removeObserver(self, forKeyPath: "frame")
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let destination = segue.destination as? ARTestResultViewController {
            destination.correct = score
            destination.incorrect = questions.count - score
        }
    }
}

// Add extension for text padding
extension UILabel {
    private struct AssociatedKeys {
        static var padding = UIEdgeInsets()
    }

    var textInsets: UIEdgeInsets {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.padding) as? UIEdgeInsets ?? UIEdgeInsets.zero
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.padding, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    override open func draw(_ rect: CGRect) {
        let insets = textInsets
        super.draw(rect.inset(by: insets))
    }

    override open var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        let insets = textInsets
        return CGSize(width: size.width + insets.left + insets.right,
                      height: size.height + insets.top + insets.bottom)
    }

    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        let insets = textInsets
        var newSize = CGSize(width: size.width - insets.left - insets.right,
                             height: size.height - insets.top - insets.bottom)
        newSize = super.sizeThatFits(newSize)
        newSize.width += insets.left + insets.right
        newSize.height += insets.top + insets.bottom
        return newSize
    }
}

// Extension for tab bar hiding
extension UITabBarController {
    var isTabBarHidden: Bool {
        get {
            return tabBar.isHidden
        }
        set {
            tabBar.isHidden = newValue
        }
    }
}
