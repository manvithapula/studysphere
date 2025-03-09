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
    @IBOutlet weak var memorisedL: UILabel!
    @IBOutlet weak var needPracticeL: UILabel!
    @IBOutlet weak var percentageL: UILabel!
    @IBOutlet weak var youGot: UILabel!
    @IBOutlet weak var thatsBetter: UILabel!
    @IBOutlet weak var nextBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        nextBtn.backgroundColor = AppTheme.primary
        nextBtn.layer.cornerRadius = 25

        // Do any additional setup after loading the view.
        // make left navigation button
        let leftButton = UIBarButtonItem(title:"Schedule",style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = leftButton
        
        let total = memorised + needPractice
        youGot.text = "You got \(memorised)/\(total) questions Correct"
        thatsBetter.text = "That's better than \(Int(memorised/(total)*100))% of means"
    }
    @objc func backButtonTapped() {
        performSegue(withIdentifier: "toQuestionBack", sender: nil)
    }
    @IBAction func goBack(_ sender: Any) {
        performSegue(withIdentifier: "toQuestionBack", sender: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
