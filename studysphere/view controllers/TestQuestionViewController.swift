//
//  TestQuestionViewController.swift
//  studysphere
//
//  Created by Dev on 14/12/24.
//

import UIKit

class TestQuestionViewController: UIViewController {
        var memorised:Float = 0
        var needPractice:Float = 0
        @IBOutlet weak var memorisedL: UILabel!
        @IBOutlet weak var needPracticeL: UILabel!
        @IBOutlet weak var percentageL: UILabel!
        override func viewDidLoad() {
            super.viewDidLoad()

            // Do any additional setup after loading the view.
            // make left navigation button
            let leftButton = UIBarButtonItem(title:"Schedule",style: .plain, target: self, action: #selector(backButtonTapped))
            navigationItem.leftBarButtonItem = leftButton
            memorisedL.text = "\(memorised)"
            needPracticeL.text = "\(needPractice)"
            percentageL.text = "\(Int(memorised/(memorised + needPractice)*100))%"
        }
        @objc func backButtonTapped() {
            performSegue(withIdentifier: "toQuestionBack", sender: nil)
        }
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

