//
//  FlashcardViewController.swift
//  studysphere
//
//  Created by dark on 04/11/24.
//

import UIKit
import FirebaseCore

class FlashcardViewController: UIViewController {
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var needsPracticeCount: UILabel!
    @IBOutlet weak var memorisedCount: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var subjectLabel: UILabel!
    private var practiceNumCount: Int = 0
        private var memorisedNumCount: Int = 0
        var flashcards: [Flashcard] = []
        var schedule: Schedule?
    var topic:String = ""
    var score:Score?
        
        var currentCardIndex = 0
        var isShowingAnswer = false
        
        // New properties for drag interaction
        private var initialTouchPoint: CGPoint = .zero
        private var cardInitialCenter: CGPoint = .zero
        private let dragThreshold: CGFloat = 100 // Distance to trigger card change
        private var isDragging = false
    
    private let tutorialKey = AuthManager.shared.id! + "fltut"
        private var tutorialView: UIView?
        private var demoCard: UIView?
    // Declare the label as a property in your class
    // OR create it programmatically in viewDidLoad
    private func setupSubjectLabel() {
        Task{
            let topics = try await topicsDb.findAll(where: ["id":schedule!.topic])
            if let topic = topics.first{
                let subjects = try await subjectDb.findAll(where: ["id":topic.subject])
                if let subject = subjects.first{
                    subjectLabel.text = subject.name
                }
            }
        }
    }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            Task{
                self.flashcards = try await flashCardDb.findAll(where: ["topic":topic])
                setupInitialCard()
                setupPanGesture()
                setupSubjectLabel()
                if !UserDefaults.standard.bool(forKey: tutorialKey) {
                                showTutorial()
                            }
            }
            // hide tabbar
        }
    
   

        private func setupPanGesture() {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            cardView.addGestureRecognizer(panGesture)
        }
        
        @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
            let translation = gesture.translation(in: view)
            
            switch gesture.state {
            case .began:
                // Store initial touch and card position
                initialTouchPoint = gesture.location(in: view)
                cardInitialCenter = cardView.center
                isDragging = true
            
            case .changed:
                guard isDragging else { return }
                
                // Move the card with the drag
                cardView.center = CGPoint(
                    x: cardInitialCenter.x + translation.x,
                    y: cardInitialCenter.y + translation.y
                )
                
                // Rotate the card based on drag
                let rotationStrength = translation.x / view.bounds.width
                let rotation = rotationStrength * (Double.pi / 6)
                cardView.transform = CGAffineTransform(rotationAngle: rotation)
                
                // Change opacity and background based on drag direction
                let absoluteTranslation = abs(translation.x)
                cardView.alpha = 1 - (absoluteTranslation / (view.bounds.width / 2))
                
            
            case .ended:
                isDragging = false
                let velocity = gesture.velocity(in: view)
                
                // Determine if card should be swiped away
                if abs(translation.x) > dragThreshold || abs(velocity.x) > 500 {
                    // Swipe away
                    performCardSwipe(direction: translation.x > 0 ? .left : .right)
                } else {
                    // Snap back to original position
                    UIView.animate(withDuration: 0.3) {
                        self.cardView.center = self.cardInitialCenter
                        self.cardView.transform = .identity
                        self.cardView.alpha = 1
                    }
                }
            
            default:
                break
            }
        }
        
        private func performCardSwipe(direction: UIRectEdge) {
            let translation = direction == .left ? -cardView.frame.width : cardView.frame.width
            let rotation = direction == .left ? Double.pi/6 : -Double.pi/6
            
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0.5,
                           options: [.curveEaseOut],
                           animations: {
                let transform = CGAffineTransform(translationX: -translation, y: 0)
                    .rotated(by: rotation)
                self.cardView.transform = transform
                self.cardView.alpha = 0
            }) { _ in
                // Update counts based on swipe direction
                if direction == .left {
                    self.memorisedNumCount += 1
                } else {
                    self.practiceNumCount += 1
                }
                
                // Move to next card or finish session
                if self.currentCardIndex < self.flashcards.count - 1 {
                    self.currentCardIndex += 1
                    self.isShowingAnswer = false
                    self.answerLabel.text = self.flashcards[self.currentCardIndex].question
                    self.updateCountLabels()
                    let progress = Float(self.currentCardIndex) / Float(self.flashcards.count)
                    self.progressView.setProgress(progress, animated: true)
                    // Reset card position
                    self.cardView.center = self.cardInitialCenter
                    self.cardView.transform = .identity
                    self.cardView.alpha = 1
                } else {
                    // Last card - navigate to result screen
                    self.updateCompletion()
                    self.performSegue(withIdentifier: "TestResultViewController", sender: nil)
                }
            }
        }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.isTabBarHidden = true
        subjectLabel.backgroundColor = AppTheme.secondary.withAlphaComponent(0.1)
        //add padding to text
        subjectLabel.layer.cornerRadius = 16
        progressView.progressTintColor = AppTheme.primary
        progressView.trackTintColor = AppTheme.secondary.withAlphaComponent(0.2)
        cardView.backgroundColor = AppTheme.primary.withAlphaComponent(0.2)
    }
        // Existing methods (setupInitialCard, updateCompletion, etc.) remain the same
        private func setupInitialCard() {
            answerLabel?.text = self.flashcards[0].question
            updateCountLabels()
        }
        
        private func updateCompletion() {
            progressView.setProgress(1, animated: true)
            score = Score(id: "", score: memorisedNumCount, total: flashcards.count, scheduleId: schedule!.id, topicId: schedule!.topic, createdAt: Timestamp(), updatedAt: Timestamp())
            Task{
                let _ = scoreDb.create(&score!)
                schedule?.completed = Timestamp()
                var scheduleTemp = schedule
                try await schedulesDb.update(&scheduleTemp!)
            }
        }
        
        private func updateCountLabels() {
            needsPracticeCount?.text = "\(practiceNumCount)"
            memorisedCount?.text = "\(memorisedNumCount)"
        }
        
        // Existing prepare for segue method
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            super.prepare(for: segue, sender: sender)
            if let destination = segue.destination as? FlashcardResultViewController {
                destination.score = score
            }
        }
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
            UIView.transition(with: cardView, duration: 0.3, options: .transitionFlipFromRight) {
                self.isShowingAnswer.toggle()
                self.answerLabel.text = self.isShowingAnswer ?
                self.flashcards[self.currentCardIndex].answer :
                self.flashcards[self.currentCardIndex].question
                self.cardView.backgroundColor = self.isShowingAnswer ? AppTheme.secondary.withAlphaComponent(0.2) : AppTheme.primary.withAlphaComponent(0.2)
            }
        }
    }
//Tutorial
extension FlashcardViewController{
    private func showTutorial() {
            // Create tutorial container
            let tutorialView = UIView(frame: view.bounds)
            tutorialView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            view.addSubview(tutorialView)
            self.tutorialView = tutorialView
            
            // Container for tutorial content
            let contentContainer = UIView(frame: CGRect(x: 20, y: 0, width: view.bounds.width - 40, height: view.bounds.height-300))
            contentContainer.backgroundColor = .white
            contentContainer.layer.cornerRadius = 12
            contentContainer.center = view.center
            tutorialView.addSubview(contentContainer)
            
            // Title
            let titleLabel = UILabel()
            titleLabel.text = "How to Use Flashcards"
            titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
            titleLabel.textAlignment = .center
            titleLabel.frame = CGRect(x: 20, y: 20, width: contentContainer.bounds.width - 40, height: 30)
            contentContainer.addSubview(titleLabel)
            
            // Demo card
            let demoCard = RoundNShadow(frame: CGRect(x: 0, y: 70, width: 280, height: 180))
            demoCard.center.x = contentContainer.bounds.width / 2
            demoCard.backgroundColor = .systemGray6
            demoCard.layer.cornerRadius = 12
            demoCard.layer.borderWidth = 1
            demoCard.layer.borderColor = UIColor.systemGray4.cgColor
            contentContainer.addSubview(demoCard)
            self.demoCard = demoCard
            
            // Sample text in demo card
            let sampleText = UILabel()
            sampleText.text = "Sample Card"
            sampleText.textAlignment = .center
            sampleText.frame = demoCard.bounds
            demoCard.addSubview(sampleText)
            
            // Instructions container
            let instructionsContainer = UIStackView()
            instructionsContainer.axis = .vertical
            instructionsContainer.spacing = 20
            instructionsContainer.frame = CGRect(x: 20,
                                              y: demoCard.frame.maxY + 30,
                                              width: contentContainer.bounds.width - 40,
                                              height: 150)
            contentContainer.addSubview(instructionsContainer)
            
            // Left swipe instruction
            let leftSwipeStack = createInstructionStack(
                symbol: "arrow.right",
                title: "Swipe Right",
                description: "if you know the answer",
                color: .systemGreen
            )
            instructionsContainer.addArrangedSubview(leftSwipeStack)
            
            // Right swipe instruction
            let rightSwipeStack = createInstructionStack(
                symbol: "arrow.left",
                title: "Swipe Left",
                description: "to practice more",
                color: .systemRed
            )
            instructionsContainer.addArrangedSubview(rightSwipeStack)
            
            // Tap instruction
            let tapStack = createInstructionStack(
                symbol: "hand.tap",
                title: "Tap Card",
                description: "to see the answer",
                color: .systemBlue
            )
            instructionsContainer.addArrangedSubview(tapStack)
            
            // Got it button
            let gotItButton = UIButton(type: .system)
            gotItButton.setTitle("Got it!", for: .normal)
            gotItButton.backgroundColor = AppTheme.primary
            gotItButton.setTitleColor(.white, for: .normal)
            gotItButton.layer.cornerRadius = 16
            gotItButton.frame = CGRect(x: 20,
                                     y: contentContainer.bounds.height - 60,
                                     width: contentContainer.bounds.width - 40,
                                     height: 44)
            gotItButton.addTarget(self, action: #selector(dismissTutorial), for: .touchUpInside)
            contentContainer.addSubview(gotItButton)
            
            // Start animation sequence
            animateTutorialSequence()
        }
        
        private func createInstructionStack(symbol: String, title: String, description: String, color: UIColor) -> UIStackView {
            let stack = UIStackView()
            stack.axis = .horizontal
            stack.spacing = 12
            stack.alignment = .center
            
            // Symbol
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
            let symbolImage = UIImageView(image: UIImage(systemName: symbol, withConfiguration: symbolConfig))
            symbolImage.tintColor = color
            symbolImage.contentMode = .scaleAspectFit
            symbolImage.widthAnchor.constraint(equalToConstant: 30).isActive = true
            
            // Text stack
            let textStack = UIStackView()
            textStack.axis = .vertical
            textStack.spacing = 2
            
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
            
            let descLabel = UILabel()
            descLabel.text = description
            descLabel.font = .systemFont(ofSize: 14)
            descLabel.textColor = .systemGray
            
            textStack.addArrangedSubview(titleLabel)
            textStack.addArrangedSubview(descLabel)
            
            stack.addArrangedSubview(symbolImage)
            stack.addArrangedSubview(textStack)
            
            return stack
        }
        
        private func animateTutorialSequence() {
            // Swipe left animation
            UIView.animate(withDuration: 0.8, delay: 1.0, options: .curveEaseInOut) {
                self.demoCard?.transform = CGAffineTransform(translationX: 100, y: 0)
                    .rotated(by: CGFloat.pi / 30)
                self.demoCard?.alpha = 0.8
            } completion: { _ in
                // Reset
                UIView.animate(withDuration: 0.5) {
                    self.demoCard?.transform = .identity
                    self.demoCard?.alpha = 1
                } completion: { _ in
                    // Swipe right animation
                    UIView.animate(withDuration: 0.8, delay: 0.5, options: .curveEaseInOut) {
                        self.demoCard?.transform = CGAffineTransform(translationX: -100, y: 0)
                            .rotated(by: -CGFloat.pi / 30)
                        self.demoCard?.alpha = 0.8
                    } completion: { _ in
                        // Reset
                        UIView.animate(withDuration: 0.5) {
                            self.demoCard?.transform = .identity
                            self.demoCard?.alpha = 1
                        } completion: { _ in
                            // Flip animation
                            self.animateCardFlip()
                        }
                    }
                }
            }
        }
        
        private func animateCardFlip() {
            UIView.transition(with: self.demoCard!, duration: 0.6,
                             options: .transitionFlipFromRight,
                             animations: nil) { _ in
                // Repeat sequence after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.animateTutorialSequence()
                }
            }
        }
        
        @objc private func dismissTutorial() {
            UIView.animate(withDuration: 0.3) {
                self.tutorialView?.alpha = 0
            } completion: { _ in
                self.tutorialView?.removeFromSuperview()
                UserDefaults.standard.set(true, forKey: self.tutorialKey)
            }
        }
}
