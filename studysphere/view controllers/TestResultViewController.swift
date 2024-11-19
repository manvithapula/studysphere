//
//  TestResultViewController.swift
//  studysphere
//
//  Created by dark on 08/11/24.
//

import UIKit
import Lottie

class TestResultViewController: UIViewController {
    
    //Properties
//    private var animationView: LottieAnimationView?
    private var tickAnimation: LottieAnimationView?
    var memorised:Float = 0
    var needPractice:Float = 0
    
    @IBOutlet private weak var tickView: UIView!
    
    //lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupAnimations()
        startAnimations()
    }
    
    //setup methods
    private func setupNavigationBar() {
        navigationItem.hidesBackButton = true
    }
    
    private func setupAnimations() {
        // Setup confetti animation
//        let confettiAnimation = LottieAnimationView(name: "confetti")
//        confettiAnimation.frame = view.bounds
//        confettiAnimation.contentMode = .scaleAspectFit
//        confettiAnimation.loopMode = .playOnce
//        confettiAnimation.animationSpeed = 0.5
//        view.addSubview(confettiAnimation)
//        animationView = confettiAnimation
        
        // Setup tick animation
        let tickAnim = LottieAnimationView(name: "tick")
        tickAnim.frame = tickView.bounds
        tickAnim.contentMode = .scaleAspectFit
        tickAnim.loopMode = .playOnce
        tickAnim.animationSpeed = 1.0
        tickView.addSubview(tickAnim)
        tickAnimation = tickAnim
    }
    
    private func startAnimations() {
//        animationView?.play()
        tickAnimation?.play()
        print(        tickAnimation?.animation?.duration as Any
)
        DispatchQueue.main.asyncAfter(deadline: .now() + (tickAnimation?.animation?.duration ?? 5) + 1) { [weak self] in
            self?.performSegue(withIdentifier: "toflresult", sender: nil)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let destination = segue.destination as? FlashcardResultViewController {
            destination.memorised = memorised
            destination.needPractice = needPractice
        }
    }
    
}
