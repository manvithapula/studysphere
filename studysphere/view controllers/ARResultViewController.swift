//
//  ARResultViewController.swift
//  studysphere
//
//  Created by Dev on 18/11/24.
//
import UIKit

class ARResultViewController: UIViewController {
    
    @IBOutlet weak var circularProgress: ProgressViewCIrcle!
    @IBOutlet weak var correctLabel: UILabel!
    @IBOutlet weak var incorrectLabel: UILabel!
    @IBOutlet weak var totalPercentageLabel: UILabel!

    
    var correctAnswers: Int = 0
    var incorrectAnswers: Int = 0

    
    override func viewDidLoad() {  // lifrcycle
        super.viewDidLoad()

        setupNavigationBar()
        updateUI()
    }

    //methods
    private func setupNavigationBar() {
        let leftButton = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = leftButton
    }

    private func updateUI() {
        let totalAnswers = correctAnswers + incorrectAnswers
        let percentage = totalAnswers > 0 ? CGFloat(incorrectAnswers) / CGFloat(totalAnswers) : 0.0

        circularProgress.setProgress(value: percentage)
        correctLabel.text = "\(correctAnswers)"
        incorrectLabel.text = "\(incorrectAnswers)"
        totalPercentageLabel.text = "(\(Int(percentage * 100)))%"
    }

    //actions
    @objc private func backButtonTapped() {
        performSegue(withIdentifier: "backToHome", sender: nil)
    }
}
