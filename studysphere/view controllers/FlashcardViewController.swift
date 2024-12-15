//
//  FlashcardViewController.swift
//  studysphere
//
//  Created by dark on 04/11/24.
//

import UIKit

class FlashcardViewController: UIViewController {
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var needsPracticeCount: UILabel!
    @IBOutlet weak var memorisedCount: UILabel!
    private var practiceNumCount: Int = 0
        private var memorisedNumCount: Int = 0
        var flashcards: [Flashcard] = []
        var schedule: Schedule?
        
        var currentCardIndex = 0
        var isShowingAnswer = false
        
        // New properties for drag interaction
        private var initialTouchPoint: CGPoint = .zero
        private var cardInitialCenter: CGPoint = .zero
        private let dragThreshold: CGFloat = 100 // Distance to trigger card change
        private var isDragging = false
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupInitialCard()
            setupPanGesture()
            // hide tabbar
            tabBarController?.isTabBarHidden = true
        }
      override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.isTabBarHidden = false
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
                
                if translation.x > 0 {
                    view.backgroundColor = .systemGreen.withAlphaComponent((absoluteTranslation / view.bounds.width)+0.2)
                } else {
                    view.backgroundColor = .systemRed.withAlphaComponent((absoluteTranslation / view.bounds.width)+0.2)
                }
            
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
                        self.view.backgroundColor = .button
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
                    
                    // Reset card position
                    self.cardView.center = self.cardInitialCenter
                    self.cardView.transform = .identity
                    self.cardView.alpha = 1
                    self.view.backgroundColor = .button
                } else {
                    // Last card - navigate to result screen
                    self.updateCompletion()
                    self.performSegue(withIdentifier: "TestResultViewController", sender: nil)
                }
            }
        }
        
        // Existing methods (setupInitialCard, updateCompletion, etc.) remain the same
        private func setupInitialCard() {
            answerLabel?.text = self.flashcards[0].question
            updateCountLabels()
        }
        
        private func updateCompletion() {
            schedule?.completed = Date()
            schedulesDb.update(&schedule!)
        }
        
        private func updateCountLabels() {
            needsPracticeCount?.text = "\(practiceNumCount)"
            memorisedCount?.text = "\(memorisedNumCount)"
        }
        
        // Existing prepare for segue method
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            super.prepare(for: segue, sender: sender)
            if let destination = segue.destination as? TestResultViewController {
                destination.memorised = Float(memorisedNumCount)
                destination.needPractice = Float(practiceNumCount)
            }
        }
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
            UIView.transition(with: cardView, duration: 0.3, options: .transitionFlipFromRight) {
                self.isShowingAnswer.toggle()
                self.answerLabel.text = self.isShowingAnswer ?
                self.flashcards[self.currentCardIndex].answer :
                self.flashcards[self.currentCardIndex].question
            }
        }
    }
