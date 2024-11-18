//
//  ARTestResultViewController.swift
//  studysphere
//
//  Created by Dev on 17/11/24.
//

import UIKit
import Lottie

class ARTestResultViewController: UIViewController {
    
    // MARK: - Properties
//    private var animationView: LottieAnimationView?
    private var tickAnimation: LottieAnimationView?
    
    @IBOutlet private weak var tickView: UIView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupAnimations()
        startAnimations()
//        scheduleNavigation()
    }
    
    // MARK: - Setup Methods
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
            self?.performSegue(withIdentifier: "gotoFlash", sender: nil)
        }
        
    }
    
    
    // MARK: - Navigation
    private func scheduleNavigation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 7) { [weak self] in
            self?.performSegue(withIdentifier: "gotoFlash", sender: nil)
        }
    }
    
}
