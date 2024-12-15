//
//  FlashcardResultViewController.swift
//  studysphere
//
//  Created by dark on 18/11/24.
//

import UIKit

class FlashcardResultViewController: UIViewController {
    
    @IBOutlet weak var circularPV: ProgressViewCIrcle!
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
        
        circularPV.setProgress(value: CGFloat(needPractice/(memorised + needPractice)))
        memorisedL.text = "\(memorised)"
        needPracticeL.text = "\(needPractice)"
        percentageL.text = "\(Int(memorised/(memorised + needPractice)*100))%"
    }
    @objc func backButtonTapped() {
        performSegue(withIdentifier: "toScheduleUnwind", sender: nil)
    }
    

}
