//
//  QuestionViewController.swift
//  studysphere
//
//  Created by Dev on 18/11/24.
//
import UIKit

class QuestionViewController: UIViewController {
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var ARProgressBar: UIProgressView!
    @IBOutlet weak var Askedquestion: UILabel!
    @IBOutlet weak var Option1: UIButton!
    @IBOutlet weak var Option2: UIButton!
    @IBOutlet weak var Option3: UIButton!
    @IBOutlet weak var Option4: UIButton!
    @IBOutlet weak var RightAnswer: UIButton!
    @IBOutlet weak var Next: UIButton!
    private var incorrectNumCount: Int = 0
    private var correctNumCount: Int = 0
    
    //properties
    private var currentQuestionIndex = 0
    private var score = 0
    private let totalQuestions = 2

    //lifecycle
    var topic:Topics?
    var questions:[Questions] = []
    var schedule:Schedule?
    override func viewDidLoad() {
        super.viewDidLoad()
        questions = questionsDb.findAll(where: ["topic":topic!.id])
        setupUI()
        loadQuestion()
    }
    
    // UI
    private func setupUI() {
        // Style all option buttons
        [Option1, Option2, Option3, Option4].forEach { button in
            button?.layer.cornerRadius = 8
            button?.layer.borderWidth = 1
            button?.layer.borderColor = UIColor.systemBlue.cgColor
            button?.backgroundColor = .clear
        }
        
        // Style Next button
        Next.layer.cornerRadius = 20
        Next.isEnabled = false
        
        // Set initial progress
        ARProgressBar.progress = 0.0
    }
    
    private func loadQuestion() {
        print(currentQuestionIndex,questions.count)
        if currentQuestionIndex >= questions.count {
            showFinalScore()
            return
        }
        
        let currentQuestion = questions[currentQuestionIndex]
        
        // Update labels
        questionLabel.text =  " Questions \(currentQuestionIndex + 1)/\(totalQuestions)"
        Askedquestion.text = currentQuestion.question
        
        // Update buttons
        Option1.setTitle(currentQuestion.option1, for: .normal)
        Option2.setTitle(currentQuestion.option2, for: .normal)
        Option3.setTitle(currentQuestion.option3, for: .normal)
        Option4.setTitle(currentQuestion.option4, for: .normal)
        
        // Reset button states
        resetButtonStates()

    }
    
    private func resetButtonStates() {
        [Option1, Option2, Option3, Option4].forEach { button in
            button?.backgroundColor = .clear
            button?.isEnabled = true
        }
        Next.isEnabled = false
    }
    
    private func updateProgress() {
        let progress = Float(currentQuestionIndex) / Float(questions.count)
        ARProgressBar.setProgress(progress, animated: true)
    }
    
    //actions
    @IBAction func optionButtonTapped(_ sender: UIButton) {
        // Disable all options
        [Option1, Option2, Option3, Option4].forEach { $0?.isEnabled = false }
        
        let currentQuestion = questions[currentQuestionIndex]
        
        // Get selected option index
        let selectedAnswer: String
        switch sender {
        case Option1: selectedAnswer = currentQuestion.option1
        case Option2: selectedAnswer = currentQuestion.option2
        case Option3: selectedAnswer = currentQuestion.option3
        case Option4: selectedAnswer = currentQuestion.option4
        default: selectedAnswer = ""
        }
        
        // answer check
        if selectedAnswer == currentQuestion.correctanswer {
            sender.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.3)
            score += 1
        } else {
            sender.backgroundColor = UIColor.systemRed.withAlphaComponent(0.3)
            // Show correct answer
            let correctButton: UIButton?
            switch currentQuestion.correctanswer {
            case currentQuestion.option1: correctButton = Option1
            case currentQuestion.option2: correctButton = Option2
            case currentQuestion.option3: correctButton = Option3
            case currentQuestion.option4: correctButton = Option4
            default: correctButton = nil
            }
            correctButton?.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.3)
        }
        
        Next.isEnabled = true
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        currentQuestionIndex += 1
        updateProgress()
        loadQuestion()
    }
    
    private func showFinalScore() {
        schedule?.completed = true
        schedulesDb.update(schedule!)
        performSegue(withIdentifier: "toARAnimation", sender: nil)
    }
    
    private func restartQuiz() {
        currentQuestionIndex = 0
        score = 0
        loadQuestion()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let destination = segue.destination as? ARTestResultViewController {
            destination.correct = score
            destination.incorrect = questions.count - score
        }
    }
}
//

//struct Question {
//    let questionNumber: String
//    let text: String
//    let options: [String]
//    let correctAnswer: Int
//}
