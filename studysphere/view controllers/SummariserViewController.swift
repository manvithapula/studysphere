//
//  SummariserViewController.swift
//  studysphere
//
//  Created by admin64 on 05/11/24.
//

import UIKit

class SummariserViewController: UIViewController {
        
        // Outlets
        @IBOutlet weak var headingLabel: UILabel!
        @IBOutlet weak var summaryTextView: UITextView!
    // Properties for heading and summary text
       var heading: String = "English Summary"
       var summaryText: String = "aaaaaa"
    
    
    var topic : Topics?
       
       // Progress bar and label
       private let progressBar = UIProgressView(progressViewStyle: .default)
       private let progressLabel = UILabel()

       // Example property to hold progress
       var progress: Float = 0.0 {
           didSet {
               updateProgress()
           }
       }
       
       override func viewDidLoad() {
           super.viewDidLoad()
           setupView()
           setupProgressBar()
           // Simulate progress update for demonstration
           simulateProgress()
       }
       
       func setupView() {
           headingLabel.text = heading
           summaryTextView.text = summaryText
       }
       
       func setupProgressBar() {
           // Configure progress bar
           progressBar.progress = progress
           progressBar.tintColor = .systemBlue
           
           // Configure label
           progressLabel.text = "\(Int(progress * 100))%"
           progressLabel.font = UIFont.systemFont(ofSize: 14)
           progressLabel.textColor = .black
           progressLabel.textAlignment = .center

           // Add progress bar and label to the view
           view.addSubview(progressBar)
           view.addSubview(progressLabel)
           
           // Enable Auto Layout
           progressBar.translatesAutoresizingMaskIntoConstraints = false
           progressLabel.translatesAutoresizingMaskIntoConstraints = false
           
           // Set constraints for the progress bar
           NSLayoutConstraint.activate([
               progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
               progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
               progressBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
               progressBar.heightAnchor.constraint(equalToConstant: 4)
           ])
           
           // Set constraints for the progress label
           NSLayoutConstraint.activate([
               progressLabel.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 5),
               progressLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
           ])
       }
       
       func updateProgress() {
           // Update the progress bar and the label
           progressBar.progress = progress
           progressLabel.text = "\(Int(progress * 100))%"
       }
       
       func simulateProgress() {
           // Simulate progress over time (for demo purposes)
           Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
               if self.progress < 1.0 {
                   self.progress += 0.1
               } else {
                   timer.invalidate()
               }
           }
       }
   }
