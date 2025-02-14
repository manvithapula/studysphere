//
//  QuestionResultViewController.swift
//  studysphere
//
//  Created by dark on 18/11/24.
//

import UIKit

class QuestionResultViewController: UIViewController {
    
    @IBOutlet weak var circularPV: ProgressViewCIrcle!
    var memorised:Float = 0
    var needPractice:Float = 0
    @IBOutlet weak var correct: UILabel!
    @IBOutlet weak var Incorrect: UILabel!
    @IBOutlet weak var percentageL: UILabel!
    @IBOutlet weak var youGot: UILabel!
    @IBOutlet weak var thatsBetter: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // make left navigation button
        let leftButton = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = leftButton
        
        let total = memorised + needPractice
        
        // Convert label text to Float
        let correctValue = Float(memorised)
            youGot.text = "\(correctValue)"
            Incorrect.text = "\(total)"
//            if total > 0 {
//                let percentage = (correctValue/total) * 100
//                thatsBetter.text = "\(percentage)%"
//            } else {
//                thatsBetter.text = "0%"
//            }
        
    }
    
    @objc func backButtonTapped() {
        performSegue(withIdentifier: "toScheduleUnwind", sender: nil)
    }
    
    @IBAction func goBack(_ sender: Any) {
        performSegue(withIdentifier: "toScheduleUnwind", sender: nil)
    }
}
