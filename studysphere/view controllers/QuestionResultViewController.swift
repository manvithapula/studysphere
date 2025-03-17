import UIKit

class QuestionResultViewController: UIViewController {
    
    // MARK: - Properties
    var memorised: Float = 0
    var needPractice: Float = 0
    var score:Score?
    
    // MARK: - UI Elements
    private let containerView = UIView()
    private let confettiImageView = UIImageView()
    private let trophyImageView = UIImageView()
    private let scoreCardView = UIView()
    private let youGot = UILabel()
    private let scoreLabel = UILabel()
    private let encouragementLabel = UILabel()
    private let percentageCardView = UIView()
    private let percentageLabel = UILabel()
    private let progressMessageLabel = UILabel()
    private let starImageView = UIImageView()
    private let statsCardView = UIView()
    private let learnedLabel = UILabel()
    private let reviewLabel = UILabel()
    private let learnedIcon = UIImageView()
    private let reviewIcon = UIImageView()
    private let nextBtn = UIButton(type: .system)
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
        configureUI()
        updateData()
        animateElements()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playConfettiAnimation()
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = .white
        
        // Add subviews
        view.addSubview(containerView)
        containerView.addSubview(confettiImageView)
        containerView.addSubview(trophyImageView)
        containerView.addSubview(scoreCardView)
        containerView.addSubview(percentageCardView)
        containerView.addSubview(statsCardView)
        containerView.addSubview(nextBtn)
        
        scoreCardView.addSubview(youGot)
        scoreCardView.addSubview(scoreLabel)
        scoreCardView.addSubview(encouragementLabel)
        
        percentageCardView.addSubview(percentageLabel)
        percentageCardView.addSubview(progressMessageLabel)
        percentageCardView.addSubview(starImageView)
        
        statsCardView.addSubview(learnedLabel)
        statsCardView.addSubview(reviewLabel)
        statsCardView.addSubview(learnedIcon)
        statsCardView.addSubview(reviewIcon)
        
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        let leftButton = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = leftButton
        navigationItem.leftBarButtonItem?.tintColor = AppTheme.primary
        
        // Set title with attributes
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: AppTheme.primary,
            .font: UIFont.systemFont(ofSize: 20, weight: .semibold)
        ]
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
        title = "Quiz Results"
    }
    
    private func configureUI() {
        // Container view
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Confetti background
        confettiImageView.translatesAutoresizingMaskIntoConstraints = false
        confettiImageView.contentMode = .scaleAspectFill
        confettiImageView.alpha = 0.3
        
        // Trophy image
        trophyImageView.translatesAutoresizingMaskIntoConstraints = false
        trophyImageView.contentMode = .scaleAspectFit
        trophyImageView.image = UIImage(named: "trophy") // Use asset image
        trophyImageView.tintColor = .systemYellow
        
        // Score card view - with improved styling
        scoreCardView.translatesAutoresizingMaskIntoConstraints = false
        setupCardGradient(for: scoreCardView)
        scoreCardView.layer.cornerRadius = 30
        scoreCardView.layer.shadowColor = UIColor.black.cgColor
        scoreCardView.layer.shadowOffset = CGSize(width: 0, height: 6)
        scoreCardView.layer.shadowRadius = 10
        scoreCardView.layer.shadowOpacity = 0.1
        
        // You got label
        youGot.translatesAutoresizingMaskIntoConstraints = false
        youGot.text = "You got"
        youGot.textColor = .black // Changed to black for visibility
        youGot.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        youGot.textAlignment = .center
        
        // Score label
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.textColor = .black // Changed to black for visibility
        scoreLabel.font = UIFont.systemFont(ofSize: 72, weight: .bold)
        scoreLabel.textAlignment = .center
        
        // Encouragement label (replacing "That's better")
        encouragementLabel.translatesAutoresizingMaskIntoConstraints = false
        encouragementLabel.text = "Let's try again! "
        encouragementLabel.textColor = .black // Changed to black for visibility
        encouragementLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        encouragementLabel.textAlignment = .center
        
        // Percentage card view - with improved styling
        percentageCardView.translatesAutoresizingMaskIntoConstraints = false
        setupCardGradient(for: percentageCardView)
        percentageCardView.layer.cornerRadius = 30
        percentageCardView.layer.shadowColor = UIColor.black.cgColor
        percentageCardView.layer.shadowOffset = CGSize(width: 0, height: 6)
        percentageCardView.layer.shadowRadius = 10
        percentageCardView.layer.shadowOpacity = 0.1
        
        // Percentage label
        percentageLabel.translatesAutoresizingMaskIntoConstraints = false
        percentageLabel.textColor = .black // Changed to black for visibility
        percentageLabel.font = UIFont.systemFont(ofSize: 38, weight: .bold)
        percentageLabel.textAlignment = .center
        
        // Progress message label (replacing comparison)
        progressMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        progressMessageLabel.text = "Every card mastered is progress! "
        progressMessageLabel.textColor = .black // Changed to black for visibility
        progressMessageLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        progressMessageLabel.textAlignment = .center
        progressMessageLabel.numberOfLines = 0
        
        // Star image view
        starImageView.translatesAutoresizingMaskIntoConstraints = false
        starImageView.contentMode = .scaleAspectFit
        if #available(iOS 13.0, *) {
            let starConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
            starImageView.image = UIImage(systemName: "star.fill", withConfiguration: starConfig)
        } else {
            starImageView.image = UIImage(named: "star")
        }
        starImageView.tintColor = .systemYellow
        
        // Stats card view - with improved styling
        statsCardView.translatesAutoresizingMaskIntoConstraints = false
        setupCardGradient(for: statsCardView)
        statsCardView.layer.cornerRadius = 30
        statsCardView.layer.shadowColor = UIColor.black.cgColor
        statsCardView.layer.shadowOffset = CGSize(width: 0, height: 6)
        statsCardView.layer.shadowRadius = 10
        statsCardView.layer.shadowOpacity = 0.1
        
        // Icons for stats - Use SF Symbols only
        learnedIcon.translatesAutoresizingMaskIntoConstraints = false
        reviewIcon.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 13.0, *) {
            let iconConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
            learnedIcon.image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: iconConfig)
            reviewIcon.image = UIImage(systemName: "repeat.circle.fill", withConfiguration: iconConfig)
        }
        
        learnedIcon.tintColor = AppTheme.primary
        reviewIcon.tintColor = AppTheme.primary
        
        // Learned label (replacing "memorised")
        learnedLabel.translatesAutoresizingMaskIntoConstraints = false
        learnedLabel.text = "Answered correctly: 0"
        learnedLabel.textColor = .black // Changed to black for visibility
        learnedLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        
        // Review label (replacing "need practice")
        reviewLabel.translatesAutoresizingMaskIntoConstraints = false
        reviewLabel.text = "Needs more practice: 0"
        reviewLabel.textColor = .black // Changed to black for visibility
        reviewLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        
        // Next button - with secondary color gradient
        nextBtn.translatesAutoresizingMaskIntoConstraints = false
        nextBtn.setTitle("Continue Learning", for: .normal)
        nextBtn.setTitleColor(.white, for: .normal)
        nextBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        setupButtonGradient(for: nextBtn, isSecondary: true) // Use secondary color
        nextBtn.layer.cornerRadius = 16
        nextBtn.layer.shadowColor = AppTheme.secondary.cgColor // Updated shadow color
        nextBtn.layer.shadowOffset = CGSize(width: 0, height: 4)
        nextBtn.layer.shadowRadius = 8
        nextBtn.layer.shadowOpacity = 0.3
        nextBtn.addTarget(self, action: #selector(goBack(_:)), for: .touchUpInside)
    }
    
    private func setupButtonGradient(for button: UIButton, isSecondary: Bool = false) {
        let gradientLayer = CAGradientLayer()
        if isSecondary {
            gradientLayer.colors = [
                AppTheme.secondary.cgColor,
                AppTheme.secondary.withAlphaComponent(0.8).cgColor
            ]
            gradientLayer.locations = [0.0, 1.0]
        } else {
            gradientLayer.colors = [
                AppTheme.primary.cgColor,
                AppTheme.primary.withAlphaComponent(0.8).cgColor
            ]
            gradientLayer.locations = [0.0, 1.0]
        }
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.frame = CGRect(x: 0, y: 0, width: view.frame.width * 0.85, height: 56)
        gradientLayer.cornerRadius = 28
        
        if let sublayers = button.layer.sublayers {
            for layer in sublayers {
                if layer is CAGradientLayer {
                    layer.removeFromSuperlayer()
                }
            }
        }
        
        button.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setupCardGradient(for cardView: UIView) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.white.cgColor,
            AppTheme.primary.withAlphaComponent(0.05).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.frame = cardView.bounds
        gradientLayer.cornerRadius = 30
        
        if let sublayers = cardView.layer.sublayers {
            for layer in sublayers {
                if layer is CAGradientLayer {
                    layer.removeFromSuperlayer()
                }
            }
        }
        
        cardView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container view
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Confetti background
            confettiImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            confettiImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            confettiImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            confettiImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            // Trophy image
            trophyImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            trophyImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            trophyImageView.heightAnchor.constraint(equalToConstant: 80),
            trophyImageView.widthAnchor.constraint(equalToConstant: 80),
            
            // Score card view
            scoreCardView.topAnchor.constraint(equalTo: trophyImageView.bottomAnchor, constant: 24),
            scoreCardView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            scoreCardView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.85),
            
            // You got label
            youGot.topAnchor.constraint(equalTo: scoreCardView.topAnchor, constant: 20),
            youGot.centerXAnchor.constraint(equalTo: scoreCardView.centerXAnchor),
            
            // Score label
            scoreLabel.topAnchor.constraint(equalTo: youGot.bottomAnchor, constant: 8),
            scoreLabel.centerXAnchor.constraint(equalTo: scoreCardView.centerXAnchor),
            
            // Encouragement label
            encouragementLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 8),
            encouragementLabel.centerXAnchor.constraint(equalTo: scoreCardView.centerXAnchor),
            encouragementLabel.bottomAnchor.constraint(equalTo: scoreCardView.bottomAnchor, constant: -20),
            
            // Percentage card view
            percentageCardView.topAnchor.constraint(equalTo: scoreCardView.bottomAnchor, constant: 20),
            percentageCardView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            percentageCardView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.85),
            
            // Percentage label
            percentageLabel.topAnchor.constraint(equalTo: percentageCardView.topAnchor, constant: 20),
            percentageLabel.centerXAnchor.constraint(equalTo: percentageCardView.centerXAnchor),
            
            // Star image view
            starImageView.centerYAnchor.constraint(equalTo: percentageLabel.centerYAnchor),
            starImageView.leadingAnchor.constraint(equalTo: percentageLabel.trailingAnchor, constant: 8),
            starImageView.heightAnchor.constraint(equalToConstant: 30),
            starImageView.widthAnchor.constraint(equalToConstant: 30),
            
            // Progress message label
            progressMessageLabel.topAnchor.constraint(equalTo: percentageLabel.bottomAnchor, constant: 8),
            progressMessageLabel.leadingAnchor.constraint(equalTo: percentageCardView.leadingAnchor, constant: 20),
            progressMessageLabel.trailingAnchor.constraint(equalTo: percentageCardView.trailingAnchor, constant: -20),
            progressMessageLabel.bottomAnchor.constraint(equalTo: percentageCardView.bottomAnchor, constant: -20),
            
            // Stats card view
            statsCardView.topAnchor.constraint(equalTo: percentageCardView.bottomAnchor, constant: 20),
            statsCardView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            statsCardView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.85),
            
            // Icon constraints
            learnedIcon.leadingAnchor.constraint(equalTo: statsCardView.leadingAnchor, constant: 24),
            learnedIcon.centerYAnchor.constraint(equalTo: learnedLabel.centerYAnchor),
            learnedIcon.widthAnchor.constraint(equalToConstant: 24),
            learnedIcon.heightAnchor.constraint(equalToConstant: 24),
            
            reviewIcon.leadingAnchor.constraint(equalTo: statsCardView.leadingAnchor, constant: 24),
            reviewIcon.centerYAnchor.constraint(equalTo: reviewLabel.centerYAnchor),
            reviewIcon.widthAnchor.constraint(equalToConstant: 24),
            reviewIcon.heightAnchor.constraint(equalToConstant: 24),
            
            // Learned label
            learnedLabel.topAnchor.constraint(equalTo: statsCardView.topAnchor, constant: 20),
            learnedLabel.leadingAnchor.constraint(equalTo: learnedIcon.trailingAnchor, constant: 12),
            learnedLabel.trailingAnchor.constraint(equalTo: statsCardView.trailingAnchor, constant: -24),
            
            // Review label
            reviewLabel.topAnchor.constraint(equalTo: learnedLabel.bottomAnchor, constant: 16),
            reviewLabel.leadingAnchor.constraint(equalTo: reviewIcon.trailingAnchor, constant: 12),
            reviewLabel.trailingAnchor.constraint(equalTo: statsCardView.trailingAnchor, constant: -24),
            reviewLabel.bottomAnchor.constraint(equalTo: statsCardView.bottomAnchor, constant: -20),
            
            // Next button
            nextBtn.topAnchor.constraint(equalTo: statsCardView.bottomAnchor, constant: 24),
            nextBtn.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            nextBtn.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.85),
            nextBtn.heightAnchor.constraint(equalToConstant: 56),
            nextBtn.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -24)
        ])
    }
    
    private func updateData() {
        // Update layout when view has been laid out
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.setupCardGradient(for: self.scoreCardView)
            self.setupCardGradient(for: self.percentageCardView)
            self.setupCardGradient(for: self.statsCardView)
            self.setupButtonGradient(for: self.nextBtn, isSecondary: true)
        }
        
        // Set score label
        scoreLabel.text = "\(Int(memorised))"
        
        // Calculate percentage
        if score != nil{
            let total = score!.total
            let percentage = Float(score!.score) / Float(total)
            percentageLabel.text = "\(Int(percentage * 100))%"
            
            // Update with non-comparative message
            progressMessageLabel.text = "Every Questions mastered is progress!"
            
            // Update learned and review labels with counts
            learnedLabel.text = "Questions mastered: \(Int(score!.score))"
            reviewLabel.text = "Questions to review: \(Int(total - score!.score))"
            
            // Update feedback text based on performance
            if percentage >= 0.8 {
                encouragementLabel.text = "Excellent work! "
            } else if percentage >= 0.6 {
                encouragementLabel.text = "Good progress! "
            } else if percentage > 0 {
                encouragementLabel.text = "Keep practicing! "
            } else {
                encouragementLabel.text = "Let's try again! "
            }
            
            // Show/hide star based on performance
            starImageView.isHidden = percentage < 0.7
        } else {
            percentageLabel.text = "0%"
            progressMessageLabel.text = "Start mastering more Questions!"
            learnedLabel.text = "Questions mastered: 0"
            reviewLabel.text = "Questions to review: 0"
            starImageView.isHidden = true
        }
    }
    
    // MARK: - Animation Methods
    private func animateElements() {
        // Initial state
        trophyImageView.transform = CGAffineTransform(translationX: 0, y: -50)
        trophyImageView.alpha = 0
        scoreCardView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        scoreCardView.alpha = 0
        percentageCardView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        percentageCardView.alpha = 0
        statsCardView.transform = CGAffineTransform(translationX: 0, y: 30)
        statsCardView.alpha = 0
        nextBtn.transform = CGAffineTransform(translationX: 0, y: 30)
        nextBtn.alpha = 0
        
        // Animate trophy with bouncing effect
        UIView.animate(withDuration: 0.6, delay: 0.1, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [], animations: {
            self.trophyImageView.transform = .identity
            self.trophyImageView.alpha = 1
        })
        
        // Animate score card with spring effect
        UIView.animate(withDuration: 0.6, delay: 0.3, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.scoreCardView.transform = .identity
            self.scoreCardView.alpha = 1
        })
        
        // Animate percentage card
        UIView.animate(withDuration: 0.6, delay: 0.5, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.percentageCardView.transform = .identity
            self.percentageCardView.alpha = 1
        })
        
        // Animate stats card
        UIView.animate(withDuration: 0.6, delay: 0.7, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
            self.statsCardView.transform = .identity
            self.statsCardView.alpha = 1
        })
        
        // Animate button with a longer spring for more bounce
        UIView.animate(withDuration: 0.8, delay: 0.9, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [], animations: {
            self.nextBtn.transform = .identity
            self.nextBtn.alpha = 1
        })
        
        // Add subtle trophy rotation animation
        UIView.animate(withDuration: 1.5, delay: 1.0, options: [.autoreverse, .repeat], animations: {
            self.trophyImageView.transform = CGAffineTransform(rotationAngle: 0.05)
        }, completion: nil)
    }
    
    private func playConfettiAnimation() {
        // Create more subtle confetti using CAEmitterLayer
        let emitterLayer = CAEmitterLayer()
        emitterLayer.emitterPosition = CGPoint(x: view.bounds.width / 2, y: -20)
        emitterLayer.emitterShape = .line
        emitterLayer.emitterSize = CGSize(width: view.bounds.width * 0.8, height: 1)
        
        let colors: [UIColor] = [
            AppTheme.primary.withAlphaComponent(0.7),
            AppTheme.secondary.withAlphaComponent(0.7),
            .systemYellow.withAlphaComponent(0.7),
            .systemPink.withAlphaComponent(0.7),
            .systemGreen.withAlphaComponent(0.7)
        ]
        
        var cells: [CAEmitterCell] = []
        
        for color in colors {
            let cell = CAEmitterCell()
            cell.birthRate = 2 // Reduced from 4
            cell.lifetime = 6  // Reduced from 8
            cell.velocity = 100 // Reduced from 150
            cell.velocityRange = 30 // Reduced from 50
            cell.emissionLongitude = .pi
            cell.emissionRange = .pi / 5
            cell.spin = 2.0 // Reduced from 3.5
            cell.spinRange = 0.5 // Reduced from 1
            cell.scaleRange = 0.2 // Reduced from 0.25
            cell.scaleSpeed = -0.05 // Reduced from -0.1
            cell.contents = createConfettiShape(color: color)?.cgImage
            cells.append(cell)
        }
        
        emitterLayer.emitterCells = cells
        view.layer.addSublayer(emitterLayer)
        
        // Clean up after animation finishes - shorter duration
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { // Reduced from 5
            emitterLayer.birthRate = 0
        }
    }

    private func createConfettiShape(color: UIColor) -> UIImage? {
        let size = CGSize(width: 8, height: 8) // Smaller confetti (was 12x12)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { ctx in
            color.setFill()
            
            // Create different shapes
            let shapeName = arc4random_uniform(3)
            
            if shapeName == 0 {
                // Rectangle
                ctx.fill(CGRect(origin: .zero, size: size))
            } else if shapeName == 1 {
                // Circle
                ctx.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
            } else {
                // Triangle
                let path = UIBezierPath()
                path.move(to: CGPoint(x: size.width/2, y: 0))
                path.addLine(to: CGPoint(x: size.width, y: size.height))
                path.addLine(to: CGPoint(x: 0, y: size.height))
                path.close()
                path.fill()
            }
        }
    }
    // MARK: - Action Methods
    @objc private func backButtonTapped() {
        performSegue(withIdentifier: "toQuestionBack", sender: nil)
    }
    
    @objc private func goBack(_ sender: Any) {
        performSegue(withIdentifier: "toQuestionBack", sender: nil)
    }
}

