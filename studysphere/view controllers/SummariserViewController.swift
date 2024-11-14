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
        

        override func viewDidLoad() {
            super.viewDidLoad()
            setupView()
        }

        func setupView() {
            headingLabel.text = heading
            summaryTextView.text = summaryText
            
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
   

        // Outlets for UI components
