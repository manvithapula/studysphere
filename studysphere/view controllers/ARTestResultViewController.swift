//
//  ARTestResultViewController.swift
//  studysphere
//
//  Created by Dev on 17/11/24.
//

import UIKit
import Lottie

class ARTestResultViewController: UIViewController {

    private var tickAnimation: LottieAnimationView?
    
    
    @IBOutlet weak var tickView: UIView!
//    @IBOutlet weak var tickView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupAnimations()
        startAnimations()
//        scheduleNavigation()
    }
    
    private func setupNavigationBar() {
        navigationItem.hidesBackButton = true
    }
    private func setupAnimations() {
        // Setup confetti animation

        
        // Setup tick animation
        let tickAnim = LottieAnimationView(name: "tick")
        tickAnim.frame = tickView.bounds
        tickAnim.contentMode = .scaleAspectFit
        tickAnim.loopMode = .playOnce
        tickAnim.animationSpeed = 1.0
        tickView.addSubview(tickAnim)
        tickView = tickAnim
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
    private func scheduleNavigation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 7) { [weak self] in
            self?.performSegue(withIdentifier: "gotoFlash", sender: nil)
        }
    }

}
