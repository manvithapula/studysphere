
import UIKit

class FlashcardResultViewController: UIViewController {
    
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
    private let percentageL = UILabel()
    private let progressMessageLabel = UILabel()
    private let statsCardView = UIView()
    private let memorisedL = UILabel()
    private let needPracticeL = UILabel()
    private let memorisedIcon = UIImageView()
    private let needPracticeIcon = UIImageView()
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
        view.backgroundColor = .background
        
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
        
        percentageCardView.addSubview(percentageL)
        percentageCardView.addSubview(progressMessageLabel)
      
        
        statsCardView.addSubview(memorisedL)
        statsCardView.addSubview(needPracticeL)
        statsCardView.addSubview(memorisedIcon)
        statsCardView.addSubview(needPracticeIcon)
        
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
        title = "Flashcard Results"
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
        youGot.text = "You memorized"
    //   youGot.textColor = .black
        youGot.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        youGot.textAlignment = .center
        
        // Score label
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
    //    scoreLabel.textColor = .black
        scoreLabel.font = UIFont.systemFont(ofSize: 72, weight: .bold)
        scoreLabel.textAlignment = .center
        
        // Encouragement label
        encouragementLabel.translatesAutoresizingMaskIntoConstraints = false
        encouragementLabel.text = "Great progress!"
     //   encouragementLabel.textColor = .black
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
        percentageL.translatesAutoresizingMaskIntoConstraints = false
      //  percentageL.textColor = .black
        percentageL.font = UIFont.systemFont(ofSize: 38, weight: .bold)
        percentageL.textAlignment = .center
        
        // Progress message label
        progressMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        progressMessageLabel.text = "Keep up the consistent practice! 🌱"
      //  progressMessageLabel.textColor = .black
        progressMessageLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        progressMessageLabel.textAlignment = .center
        progressMessageLabel.numberOfLines = 0
        
      
        // Stats card view - with improved styling
        statsCardView.translatesAutoresizingMaskIntoConstraints = false
        setupCardGradient(for: statsCardView)
        statsCardView.layer.cornerRadius = 30
        statsCardView.layer.shadowColor = UIColor.black.cgColor
        statsCardView.layer.shadowOffset = CGSize(width: 0, height: 6)
        statsCardView.layer.shadowRadius = 10
        statsCardView.layer.shadowOpacity = 0.1
        
        // Icons for stats
        memorisedIcon.translatesAutoresizingMaskIntoConstraints = false
        needPracticeIcon.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 13.0, *) {
            let iconConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
            memorisedIcon.image = UIImage(systemName: "checkmark.circle", withConfiguration: iconConfig)
            needPracticeIcon.image = UIImage(systemName: "repeat.circle", withConfiguration: iconConfig)
        }
        
        memorisedIcon.tintColor = AppTheme.primary
        needPracticeIcon.tintColor = AppTheme.primary
        
        // Memorised label
        memorisedL.translatesAutoresizingMaskIntoConstraints = false
        memorisedL.text = "Cards memorized: 0"
      //  memorisedL.textColor = .black
        memorisedL.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        
        // Need Practice label
        needPracticeL.translatesAutoresizingMaskIntoConstraints = false
        needPracticeL.text = "Cards to review: 0"
       // needPracticeL.textColor = .black
        needPracticeL.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        
        // Next button - with secondary color gradient
        nextBtn.translatesAutoresizingMaskIntoConstraints = false
        nextBtn.setTitle("Continue Learning", for: .normal)
        nextBtn.setTitleColor(.white, for: .normal)
        nextBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        setupButtonGradient(for: nextBtn, isSecondary: true)
        nextBtn.layer.cornerRadius = 16
        nextBtn.layer.shadowColor = AppTheme.secondary.cgColor
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
            percentageL.topAnchor.constraint(equalTo: percentageCardView.topAnchor, constant: 20),
            percentageL.centerXAnchor.constraint(equalTo: percentageCardView.centerXAnchor),
        
            
            // Progress message label
            progressMessageLabel.topAnchor.constraint(equalTo: percentageL.bottomAnchor, constant: 8),
            progressMessageLabel.leadingAnchor.constraint(equalTo: percentageCardView.leadingAnchor, constant: 20),
            progressMessageLabel.trailingAnchor.constraint(equalTo: percentageCardView.trailingAnchor, constant: -20),
            progressMessageLabel.bottomAnchor.constraint(equalTo: percentageCardView.bottomAnchor, constant: -20),
            
            // Stats card view
            statsCardView.topAnchor.constraint(equalTo: percentageCardView.bottomAnchor, constant: 20),
            statsCardView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            statsCardView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.85),
            
            // Icon constraints
            memorisedIcon.leadingAnchor.constraint(equalTo: statsCardView.leadingAnchor, constant: 24),
            memorisedIcon.centerYAnchor.constraint(equalTo: memorisedL.centerYAnchor),
            memorisedIcon.widthAnchor.constraint(equalToConstant: 24),
            memorisedIcon.heightAnchor.constraint(equalToConstant: 24),
            
            needPracticeIcon.leadingAnchor.constraint(equalTo: statsCardView.leadingAnchor, constant: 24),
            needPracticeIcon.centerYAnchor.constraint(equalTo: needPracticeL.centerYAnchor),
            needPracticeIcon.widthAnchor.constraint(equalToConstant: 24),
            needPracticeIcon.heightAnchor.constraint(equalToConstant: 24),
            
            // Memorised label
            memorisedL.topAnchor.constraint(equalTo: statsCardView.topAnchor, constant: 20),
            memorisedL.leadingAnchor.constraint(equalTo: memorisedIcon.trailingAnchor, constant: 12),
            memorisedL.trailingAnchor.constraint(equalTo: statsCardView.trailingAnchor, constant: -24),
            
            // Need Practice label
            needPracticeL.topAnchor.constraint(equalTo: memorisedL.bottomAnchor, constant: 16),
            needPracticeL.leadingAnchor.constraint(equalTo: needPracticeIcon.trailingAnchor, constant: 12),
            needPracticeL.trailingAnchor.constraint(equalTo: statsCardView.trailingAnchor, constant: -24),
            needPracticeL.bottomAnchor.constraint(equalTo: statsCardView.bottomAnchor, constant: -20),
            
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
        scoreLabel.text = "\(Int(score!.score))"
        
        // Calculate percentage
            if score != nil {
                let total = score!.total
                let percentage = Float(score!.score) / Float(total)
                percentageL.text = "\(Int(percentage * 100))%"
                
                // Update with flashcard-specific message
                progressMessageLabel.text = "Building your memory one card at a time!"
                
                // Update memorised and need practice labels with counts
                memorisedL.text = "Cards memorized: \(Int(score!.score))"
                needPracticeL.text = "Cards to review: \(Int(total - score!.score))"
                
                // Update feedback text based on performance
                if percentage >= 0.8 {
                    encouragementLabel.text = "Amazing recall!"
                } else if percentage >= 0.6 {
                    encouragementLabel.text = "Good progress!"
                } else if percentage > 0 {
                    encouragementLabel.text = "Keep practicing!"
                } else {
                    encouragementLabel.text = "Let's try again!"
                }
                
              
            } else {
                percentageL.text = "0%"
                progressMessageLabel.text = "Start memorizing flashcards!"
                memorisedL.text = "Cards memorized: 0"
                needPracticeL.text = "Cards to review: 0"
              
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
        guard let score = score else { return }
        let percentage = Float(score.score) / Float(score.total) * 100
        guard percentage >= 85 else { return }
    
        let emitterLayer = CAEmitterLayer()
        emitterLayer.emitterPosition = CGPoint(x: view.bounds.width / 2, y: -50)
        emitterLayer.emitterShape = .line
        emitterLayer.emitterSize = CGSize(width: view.bounds.width, height: 1)
        
      
        var cells = [CAEmitterCell]()
        let colors = [UIColor.red, UIColor.green, UIColor.blue, UIColor.yellow, UIColor.purple, UIColor.orange]
        
        for color in colors {
            let cell = CAEmitterCell()
            cell.birthRate = 5
            cell.lifetime = 8
            cell.velocity = 150
            cell.velocityRange = 100
            cell.emissionLongitude = .pi
            cell.emissionRange = .pi / 4
            cell.spin = 3.5
            cell.spinRange = 1
            cell.scaleRange = 0.25
            cell.scaleSpeed = -0.1
       
            let size = CGSize(width: 10, height: 5)
            UIGraphicsBeginImageContext(size)
            let context = UIGraphicsGetCurrentContext()!
            context.setFillColor(color.cgColor)
            context.fill(CGRect(origin: .zero, size: size))
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            cell.contents = image?.cgImage
            cells.append(cell)
        }
        
        emitterLayer.emitterCells = cells
        view.layer.addSublayer(emitterLayer)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            emitterLayer.birthRate = 0
        }
    }
    // MARK: - Action Methods
    @objc private func backButtonTapped() {
        performSegue(withIdentifier: "toScheduleUnwind", sender: nil)
    }
    
    @objc private func goBack(_ sender: Any) {
        performSegue(withIdentifier: "toScheduleUnwind", sender: nil)
    }
}
