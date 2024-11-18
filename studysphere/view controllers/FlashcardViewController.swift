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
    var flashcards: [Flashcard] = flashcards1
    var schedule:Schedule?
    
    var currentCardIndex = 0
    var isShowingAnswer = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialCard()
    }
    
    private func setupInitialCard() {
        answerLabel?.text = self.flashcards[0].question
        updateCountLabels()
    }
    
    // Handle tap to reveal answer
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        UIView.transition(with: cardView, duration: 0.3, options: .transitionFlipFromRight) {
            self.isShowingAnswer.toggle()
            self.answerLabel.text = self.isShowingAnswer ?
            self.flashcards[self.currentCardIndex].answer :
            self.flashcards[self.currentCardIndex].question
        }
    }
    
    // Handle swipe left (Practice count)
    @IBAction func handleSwipeLeft(_ sender: UISwipeGestureRecognizer) {
        guard currentCardIndex < flashcards.count - 1 else {
            updateCompletion()
            // navigate to TestResultViewController after animation
            memorisedNumCount += 1
            updateCountLabels()
            animateOut(direction: .left)
            return
            
        }
        memorisedNumCount += 1
        animateCardTransition(direction: .left)
    }
    
    // Handle swipe right (Memorised count)
    fileprivate func updateCompletion() {
        schedule?.completed = true
        schedulesDb.update(schedule!)
    }
    
    @IBAction func handleSwipeRight(_ sender: UISwipeGestureRecognizer) {
        guard currentCardIndex < flashcards.count - 1 else {
            updateCompletion()
            // navigate to TestResultViewController after animation
            practiceNumCount += 1
            updateCountLabels()
            animateOut(direction: .right)
            return
            
        }
        practiceNumCount += 1
        animateCardTransition(direction: .right)
    }
    
    // Card transition animation
    private func animateCardTransition(direction: UIRectEdge) {
        let translation = direction == .left ? -cardView.frame.width : cardView.frame.width
        let rotation = direction == .left ? Double.pi/6 : -Double.pi/6

        UIView.animate(withDuration: 0.3,
                      delay: 0,
                      usingSpringWithDamping: 0.8,  // Add springiness
                      initialSpringVelocity: 0.5,
                      options: [.curveEaseOut],
                      animations: {
            let transform = CGAffineTransform(translationX: -translation, y: 0)
                .rotated(by: rotation)
            self.cardView.transform = transform
            self.cardView.alpha = 0
        }) { _ in
            // Update card content
            self.currentCardIndex += 1
            self.isShowingAnswer = false
            self.answerLabel.text = self.flashcards[self.currentCardIndex].question
            
            // Reset position with opposite rotation
            let entranceTransform = CGAffineTransform(translationX: translation, y: 0)
                .rotated(by: -rotation)
            self.cardView.transform = entranceTransform
            
            // Animate card coming back with spring effect
            UIView.animate(withDuration: 0.3,
                          delay: 0,
                          usingSpringWithDamping: 0.7,
                          initialSpringVelocity: 0.5,
                          options: [.curveEaseOut],
                          animations: {
                self.cardView.transform = .identity
                self.cardView.alpha = 1
            })
            
            self.updateCountLabels()
        }
    }
    
    private func updateCountLabels() {
        needsPracticeCount?.text = "\(practiceNumCount)"
        memorisedCount?.text = "\(memorisedNumCount)"
    }
    private func animateOut(direction: UIRectEdge){
        let translation = direction == .left ? -cardView.frame.width : cardView.frame.width
        let rotation = direction == .left ? Double.pi/6 : -Double.pi/6
        UIView.animate(withDuration: 0.3,
                      delay: 0,
                      usingSpringWithDamping: 0.8,  // Add springiness
                      initialSpringVelocity: 0.5,
                      options: [.curveEaseOut],
                      animations: {
            let transform = CGAffineTransform(translationX: -translation, y: 0)
                .rotated(by: rotation)
            self.cardView.transform = transform
            self.cardView.alpha = 0
        }) { _ in
            self.isShowingAnswer = false
            self.answerLabel.text = self.flashcards[self.currentCardIndex].question
            self.updateCompletion()
            self.performSegue(withIdentifier: "TestResultViewController", sender: nil)
        }
    }

    
    // MARK: - Optional: Button Actions for arrow buttons
    
    @IBAction func previousCardButton(_ sender: UIButton) {
        if currentCardIndex > 0 {
            animateCardTransition(direction: .right)
        }
    }
    
    @IBAction func nextCardButton(_ sender: UIButton) {
        if currentCardIndex < flashcards.count - 1 {
            animateCardTransition(direction: .left)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let destination = segue.destination as? TestResultViewController {
            destination.memorised = Float(memorisedNumCount)
            destination.needPractice = Float(practiceNumCount)
        }
    }
}
