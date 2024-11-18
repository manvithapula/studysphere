//
//  SummariserViewController.swift
//  studysphere
//
//  Created by admin64 on 05/11/24.
//

import UIKit

class SummariserViewController: UIViewController, UITextViewDelegate {
        
        // Outlets
        @IBOutlet weak var headingLabel: UILabel!
        @IBOutlet weak var summaryTextView: UITextView!
    // Properties for heading and summary text
       var heading: String = "English Summary"
       var summaryText: String = "aaaaaa"
    
    
    var topic : Topics?
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
           heading = topic!.title
           let summary = summaryDb.findFirst(where: ["topic": topic!.id])
           print(summary)
           setupView()
           setupProgressBar()
           
           // Set the scroll view delegate to self
           summaryTextView.delegate = self
           
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
       
       // UIScrollViewDelegate method to track scrolling
       func scrollViewDidScroll(_ scrollView: UIScrollView) {
           // Calculate progress based on the scroll position and content height
           let contentHeight = scrollView.contentSize.height
           let visibleHeight = scrollView.frame.size.height
           let offsetY = scrollView.contentOffset.y
           
           // Calculate the scroll progress
           if contentHeight > visibleHeight {
               progress = Float(offsetY / (contentHeight - visibleHeight))
           } else {
               progress = 1.0 // Full progress if content height is less than visible height
           }
       }
   }
