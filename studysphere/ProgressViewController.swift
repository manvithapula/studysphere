//
//  ProgressViewController.swift
//  studysphere
//
//  Created by dark on 02/11/24.
//

import UIKit

class ProgressViewController: UIViewController {
    @IBOutlet weak var flashcardMainL: UILabel!
    @IBOutlet weak var questionMainL: UILabel!
    @IBOutlet weak var hourMainL: UILabel!
    @IBOutlet weak var flashcardSecondaryL: UILabel!
    @IBOutlet weak var questionSecondaryL: UILabel!
    @IBOutlet weak var timeValueL: UILabel!
    @IBOutlet weak var timeTypeL: UILabel!
    @IBOutlet weak var streakValueL: UILabel!
    @IBOutlet weak var streakTypeL: UILabel!
    
    @IBOutlet weak var flashcardP: UIProgressView!
    @IBOutlet weak var questionP: UIProgressView!
    
    @IBOutlet weak var progressT: UISegmentedControl!
    
    @IBOutlet weak var multiProgressRing: MultiProgressRingView!
    
    fileprivate func updateUI(flashcard:ProgressType,question:ProgressType,hour:ProgressType,time:Int,streak:Int) {
        // Do any additional setup after loading the view.
        multiProgressRing.setProgress(blue: hour.progress, green: question.progress, red: flashcard.progress, animated: true)
        flashcardMainL.text = "\(flashcard.completed) Flashcards"
        questionMainL.text = "\(question.completed) Questions"
        hourMainL.text = "\(hour.completed) Hours"
        
        flashcardSecondaryL.text = "\(flashcard.total) Flashcards reviewed"
        questionSecondaryL.text = "\(question.total) Questions reviewed"
        
        flashcardP.setProgress(Float(flashcard.progress), animated: true)
        questionP.setProgress(Float(question.progress), animated: true)
        updateTimeNStreak(time: time, streak: streak)
    }
    
    func updateTimeNStreak(time:Int,streak:Int) {
        if(time < 1000 * 60){
            timeValueL.text = "\(time/1000)"
            timeTypeL.text = "secs"
        }
        else if (time < 1000 * 60 * 60){
            let minutes = time/1000/60
            timeValueL.text = "\(minutes)"
            timeTypeL.text = "mins"
        }
        else{
            let hours = time/1000/60/60
            timeValueL.text = "\(hours)"
            timeTypeL.text = "hours"
        }
        streakValueL.text = "\(streak)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI(flashcard: flashcardsProgress, question: questions, hour: hours,time: weeklyTime,streak: weeklyStreak)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func toggleAction(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            updateUI(flashcard: flashcardsProgress, question: questions, hour: hours,time: weeklyTime,streak: weeklyStreak)
        }
        else {
            updateUI(flashcard: flashcardsMonthly , question: questionsMonthly, hour: hoursMonthly,time: monthlyTime,streak: monthlyStreak)
        }
    }
    
}
