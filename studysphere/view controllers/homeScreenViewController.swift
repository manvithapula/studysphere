//
//  homeScreenViewController.swift
//  studysphere
//
//  Created by admin64 on 04/11/24.
//

import UIKit

class homeScreenViewController:UIViewController {
    //general labels
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var introMessage: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    //streak
    @IBOutlet var streaks: [UIImageView]!
    @IBOutlet weak var streakLabel: UILabel!
    
    
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
    

        override func viewDidLoad() {
            super.viewDidLoad()
            
            // Update streak when the home screen loads
            StreakManager.shared.updateStreak()
            updateStreakDisplay()
            
            // Sample data
            let sampleData = createSampleDashboardData()
            setupDashboard(with: sampleData)
        }

    private func updateStreakDisplay() {
          let currentStreak = StreakManager.shared.currentStreak

          // Loop through streaks array and set the image based on the current streak count
          for (index, streakImageView) in streaks.enumerated() {
              if index < currentStreak {
                  streakImageView.image = UIImage(systemName: "flame")
                  streakImageView.tintColor = .red
              } else {
                  streakImageView.image = UIImage(systemName: "circle.dotted")
                  streakImageView.tintColor = .black
              }
          }

        
        
        if currentStreak == 1 {
                  streakLabel.text = "1 day streak"
              } else {
                  streakLabel.text = "\(currentStreak) days streak"
              }
        
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
            let schedules = schedulesDb.findAll()
            let today = formatDateToString(date: Date())
            var filterSchedules:[Schedule]{
                return schedules.filter { schedule in
                   
                    let date = formatDateToString(date: schedule.date)
                    return date == today
                }
            }
            var todaySchedule:[ScheduleItem] = []
            for schedule in filterSchedules{
                let scheduleItem = ScheduleItem(title: schedule.title, progress: 0)
                todaySchedule.append(scheduleItem)
            }
            
            let Allsubjects = subjectDb.findAll()
            let studyTechniques = [
                StudyTechnique(name: "Spaced Repetition", completedSessions: 3, totalSessions: 5),
                StudyTechnique(name: "Active Recall", completedSessions: 2, totalSessions: 4),
                StudyTechnique(name: "Summarisation", completedSessions: 1, totalSessions: 3)
            ]
            
            return DashboardData(
                userProfile: userProfile,
                streak: streak,
                todaySchedule: todaySchedule,
                subjects: Allsubjects,
                studyTechniques: studyTechniques
            )
        }
    
    }
