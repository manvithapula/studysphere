//
//  homeScreenViewController.swift
//  studysphere
//
//  Created by admin64 on 04/11/24.
//

import UIKit

class homeScreenViewController:UIViewController {
    //
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var introMessage: UILabel!
    
    //streak
    @IBOutlet var streaks: [UIImageView]!
    
    
    // Today's Learning
    @IBOutlet weak var todaysLearning: UILabel!
    @IBOutlet weak var todayLearningLabel1: UILabel!
    @IBOutlet weak var todayLearningLabel2: UILabel!
    @IBOutlet weak var todayLearningLabel3: UILabel!
    @IBOutlet weak var todayLearningLabel4: UILabel!

    //subjects
    @IBOutlet weak var subjects: UILabel!
    @IBOutlet weak var subjectChevron: UIButton!
    @IBOutlet weak var subject1: UILabel!
    @IBOutlet weak var subject2: UILabel!
    @IBOutlet weak var subject3: UILabel!
    
    //study techniques
    @IBOutlet weak var studyTechniques: UILabel!
    @IBOutlet weak var studyTechniquesStackView: UIStackView!
    @IBOutlet weak var spacedRepetitionTextView: UITextView!
    @IBOutlet weak var spacedRepetitionCompletedLabel: UILabel!
    @IBOutlet weak var spacedRepetitionProgressLabel: UILabel!
    @IBOutlet weak var activeRecallTextView: UITextView!
    @IBOutlet weak var activeRecallCompletedLabel: UILabel!
    @IBOutlet weak var activeRecallProgressLabel: UILabel!
    @IBOutlet weak var summariserTextView: UITextView!
    @IBOutlet weak var summariserCompletedLabel: UILabel!
    @IBOutlet weak var summariserProgressLabel: UILabel!
    
    var homeScreenData: DashboardData?
    
   
    
    /* override func viewDidLoad() {
     super.viewDidLoad()
     
     for(i,streak) in streaks.enumerated() {
     if(streakValues[i]){
     streak.image = UIImage(systemName: "flame")
     }
     else{
     streak.image = UIImage(systemName: "circle.dotted")
     }
     }
     }
     }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // streak
        for (i, streak) in streaks.enumerated() {
            if streakValues[i] {
                streak.image = UIImage(systemName: "flame")
            } else {
                streak.image = UIImage(systemName: "circle.dotted")
            }
        }
        
        // Sample data
        let sampleData = createSampleDashboardData()
        setupDashboard(with: sampleData)
    }
    
    //profile icon
    
    override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            // Adding an accessory view with a profile button
            let accessoryView = UIButton()
            let image = UIImage(named: "profile-avatar")
            if let image = UIImage(named: "profile-avatar") {
            accessoryView.setImage(image, for: .normal)
            } else {
            print("Image not found.")
            }

            
            accessoryView.setImage(image, for: .normal)
            accessoryView.frame.size = CGSize(width: 34, height: 34)
            
            if let largeTitleView = navigationController?.navigationBar.subviews.first(where: { subview in
                String(describing: type(of: subview)) == "_UINavigationBarLargeTitleView"
            }) {
                largeTitleView.perform(Selector(("setAccessoryView:")), with: accessoryView)
                largeTitleView.perform(Selector(("setAlignAccessoryViewToTitleBaseline:")), with: nil)
                largeTitleView.perform(Selector(("updateContent")))
            }
        }
    
    private func setupDashboard(with data: DashboardData) {
            homeScreenData = data
            
            // subjects
            if data.subjects.count >= 3 {
                subject1.text = data.subjects[0].name
                subject2.text = data.subjects[1].name
                subject3.text = data.subjects[2].name
            }
            
            // study techniques
            for technique in data.studyTechniques {
                switch technique.name {
                case "Spaced Repetition":
                    spacedRepetitionTextView.text = technique.name
                    spacedRepetitionCompletedLabel.text = "Completed"
                    spacedRepetitionProgressLabel.text = "\(technique.completedSessions)/\(technique.totalSessions)"
                    
                case "Active Recall":
                    activeRecallTextView.text = technique.name
                    activeRecallCompletedLabel.text = "Completed"
                    activeRecallProgressLabel.text = "\(technique.completedSessions)/\(technique.totalSessions)"
                    
                case "Summariser":
                    summariserTextView.text = technique.name
                    summariserCompletedLabel.text = "Completed"
                    summariserProgressLabel.text = "\(technique.completedSessions)/\(technique.totalSessions)"
                    
                default:
                    break
                }
            }
        // today's learning
        if data.todaySchedule.count >= 4 {
              todayLearningLabel1.text = data.todaySchedule[0].title
              todayLearningLabel2.text = data.todaySchedule[1].title
              todayLearningLabel3.text = data.todaySchedule[2].title
              todayLearningLabel4.text = data.todaySchedule[3].title
          }
        }

        
        private func createSampleDashboardData() -> DashboardData {
            let userProfile = UserProfile(
                name: "John Doe",
                profilePictureURL: nil,
                motivationalMessage: "Keep pushing your limits!"
            )
            
            let streak = [
                StreakDay(dayOfWeek: "Mon", isCompleted: false),
                StreakDay(dayOfWeek: "Tue", isCompleted: false),
                StreakDay(dayOfWeek: "Wed", isCompleted: true),
                StreakDay(dayOfWeek: "Thu", isCompleted: true),
                StreakDay(dayOfWeek: "Fri", isCompleted: true),
                StreakDay(dayOfWeek: "Sat", isCompleted: false),
                StreakDay(dayOfWeek: "Sun", isCompleted: true)
            ]
            
            let todaySchedule = [
                       ScheduleItem(title: "Math Homework", progress: 0.5),
                       ScheduleItem(title: "Science Project", progress: 0.8),
                       ScheduleItem(title: "English Essay", progress: 0.3),
                       ScheduleItem(title: "History Assignment", progress: 0.7)
            ]
            
            let subjects = [
                Subject(name: "iOS Development"),
                Subject(name: "Swift Programming"),
                Subject(name: "Data Structures")
            ]
            
            let studyTechniques = [
                StudyTechnique(name: "Spaced Repetition", completedSessions: 3, totalSessions: 5),
                StudyTechnique(name: "Active Recall", completedSessions: 2, totalSessions: 4),
                StudyTechnique(name: "Summarisation", completedSessions: 1, totalSessions: 3)
            ]
            
            return DashboardData(
                userProfile: userProfile,
                streak: streak,
                todaySchedule: todaySchedule,
                subjects: subjects,
                studyTechniques: studyTechniques
            )
        }
    }
