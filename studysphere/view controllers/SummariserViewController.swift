//
//  SummariserViewController.swift
//  studysphere
//
//  Created by admin64 on 05/11/24.
//

import UIKit

class SummariserViewController: UIViewController, UITextViewDelegate {
    
    
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var summaryTextView: UITextView!
    
    
    // MARK: - Properties
       var heading: String = "English Summary"
       var summaryText: String = "aaaaaaLorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."
       var topic: Topics?
       var completionHandler: ((Topics) -> Void)?

       private let progressBar = UIProgressView(progressViewStyle: .default)
       private let progressLabel = UILabel()

       var progress: Float = 0.0 {
           didSet {
               updateProgress()
               checkCompletion()
           }
       }

       override func viewDidLoad() {
           super.viewDidLoad()
           heading = topic?.title ?? "Summary"
           let summary = summaryDb.findFirst(where: ["topic": topic?.id ?? 0])
           print(summary ?? "No summary found")
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
           progressBar.progress = progress
           progressBar.tintColor = .systemBlue
           progressLabel.text = "\(Int(progress * 100))%"
           progressLabel.font = UIFont.systemFont(ofSize: 14)
           progressLabel.textColor = .black
           progressLabel.textAlignment = .center
           view.addSubview(progressBar)
           view.addSubview(progressLabel)
           progressBar.translatesAutoresizingMaskIntoConstraints = false
           progressLabel.translatesAutoresizingMaskIntoConstraints = false

           NSLayoutConstraint.activate([
               progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
               progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -80),
               progressBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
               progressBar.heightAnchor.constraint(equalToConstant: 4),
               progressLabel.centerYAnchor.constraint(equalTo: progressBar.centerYAnchor),
               progressLabel.leadingAnchor.constraint(equalTo: progressBar.trailingAnchor, constant: 5)
           ])
       }

       func updateProgress() {
           progressBar.progress = progress
           progressLabel.text = "\(Int(progress * 100))%"
       }

       func scrollViewDidScroll(_ scrollView: UIScrollView) {
           let contentHeight = scrollView.contentSize.height
           let visibleHeight = scrollView.frame.size.height
           let offsetY = scrollView.contentOffset.y

           if contentHeight > visibleHeight {
               progress = Float(offsetY / (contentHeight - visibleHeight))
           } else {
               progress = 1.0
           }
       }

       private func checkCompletion() {
           if progress >= 1.0 {
               topic?.completed = Date()
               if let completedTopic = topic {
                   completionHandler?(completedTopic)
                   navigationController?.popViewController(animated: true)
               }
           }
       }
   }
