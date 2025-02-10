//
//  SRScheduleViewController.swift
//  studysphere
//
//  Created by dark on 05/11/24.
//

import UIKit
import FirebaseCore

/*class SRScheduleViewController: UIViewController {

    @IBOutlet weak var progressL: UILabel!
    @IBOutlet weak var circularProgressV: CircularProgressView!
    @IBOutlet weak var scheduleTable: UITableView!
    @IBOutlet weak var remainingNumberL: UILabel!
    private var mySchedules: [Schedule] = []
    var completedSchedules: [Schedule]{
        mySchedules.filter({
            $0.completed != nil
        })
    }
    
    var topic:Topics?
    fileprivate func setup() {
        Task{
            mySchedules = try await schedulesDb.findAll(where: ["topic":topic!.id])
            let sortedSchedules = mySchedules.sorted(by: { (schedule1, schedule2) -> Bool in
                return schedule1.date.dateValue() < schedule2.date.dateValue()
            })
            mySchedules = sortedSchedules
            scheduleTable.reloadData()
            circularProgressV.setProgress(value: CGFloat(completedSchedules.count) / CGFloat(mySchedules.count))
            progressL.text = "\(completedSchedules.count)/\(mySchedules.count)"
            let countDiff = mySchedules.count - completedSchedules.count
            if(countDiff == 0){
                remainingNumberL.text = "All schedules are completed"
                topic?.subtitle = "All schedules are completed"
                topic?.completed = Timestamp()
            }
            else{
                remainingNumberL.text = "\(countDiff) more to go"
                topic?.subtitle = "\(countDiff) more to go"
            }
            var topicTemp = topic
            try await topicsDb.update(&topicTemp!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        scheduleTable.delegate = self
        scheduleTable.dataSource = self
        setup()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.isTabBarHidden = false
    }
    
    
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "showScheduleDetail" {
                if let destinationVC = segue.destination as? FlashcardViewController,
                   let index = scheduleTable.indexPathForSelectedRow {
                    
                    destinationVC.topic = topic!.id
                    destinationVC.schedule = mySchedules[index.row]
                }
            }
        if segue.identifier == "showScheduleDetailBtn" {
            if completedSchedules.count == mySchedules.count {
                
            }
            if let destinationVC = segue.destination as? FlashcardViewController{
                Task{
                    destinationVC.topic = topic!.id
                    if completedSchedules.count == mySchedules.count {
                        destinationVC.schedule = mySchedules.last
                        return
                    }
                    destinationVC.schedule = mySchedules[completedSchedules.count]
                }
            }
        }
        if segue.identifier == "toSREditSchedule"{
            if let navController = segue.destination as? UINavigationController {
                if let destinationVC = navController.topViewController as? SREditScheduleViewController {
                    destinationVC.schedules1 = mySchedules
                        }
                    }
        }
        
        }
    
    
    @IBAction func comeHere(segue:UIStoryboardSegue) {
        //refresh table
        setup()
        scheduleTable.reloadData()
    }
    

}

extension SRScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mySchedules.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleCell", for: indexPath)
        let scedules = mySchedules[indexPath.row]
        
        if let cell = cell as? SRScheduleTableViewCell {
            cell.completionImage.image = UIImage(systemName: scedules.completed != nil ? "checkmark.circle.fill" : "circle.dashed")
            cell.titleL.text = "Revision \(indexPath.row + 1)"
            cell.dateL.text = "Date: " + formatDateToString(date: scedules.date.dateValue())
            cell.timeL.text = "Time: " + scedules.time
            cell.selectionStyle = .none

        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    
    
}*/
import UIKit
import FirebaseCore

class SRScheduleViewController: UIViewController, UITableViewDataSource {
    // MARK: - Properties
    private var mySchedules: [Schedule] = []
    var topic: Topics?
    
    private var completedSchedules: [Schedule] {
        mySchedules.filter { $0.completed != nil }
    }
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .bar)
        progress.trackTintColor = .systemGray5
        progress.progressTintColor = .systemBlue
        progress.layer.cornerRadius = 4
        progress.clipsToBounds = true
        progress.translatesAutoresizingMaskIntoConstraints = false
        return progress
    }()
    
    private let statsContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let retentionView = StatView(title: "Average Retention")
    private let nextReviewView = StatView(title: "Next Review")
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .systemBackground
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.isTabBarHidden = false
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(progressView)
        view.addSubview(statsContainer)
        statsContainer.addArrangedSubview(retentionView)
        statsContainer.addArrangedSubview(nextReviewView)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            progressView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            progressView.heightAnchor.constraint(equalToConstant: 8),
            
            statsContainer.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 24),
            statsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            statsContainer.heightAnchor.constraint(equalToConstant: 80),
            
            tableView.topAnchor.constraint(equalTo: statsContainer.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ReviewCell.self, forCellReuseIdentifier: "SRReviewCell")
    }
    
    private func setup() {
        Task {
            mySchedules = try await schedulesDb.findAll(where: ["topic": topic!.id])
            let sortedSchedules = mySchedules.sorted { $0.date.dateValue() < $1.date.dateValue() }
            mySchedules = sortedSchedules
            
            // Update UI
            titleLabel.text = topic?.title ?? "Flashcard Set"
            updateProgress()
            updateStats()
            tableView.reloadData()
            
            // Update topic status
            let countDiff = mySchedules.count - completedSchedules.count
            if countDiff == 0 {
                subtitleLabel.text = "All flashcards reviewed"
                topic?.subtitle = "All flashcards reviewed"
                topic?.completed = Timestamp()
            } else {
                subtitleLabel.text = "\(countDiff) sets remaining"
                topic?.subtitle = "\(countDiff) sets remaining"
            }
            
            var topicsTemp = topic
            try await topicsDb.update(&topicsTemp!)
        }
    }
    
    private func updateProgress() {
        let progress = Float(completedSchedules.count) / Float(mySchedules.count)
        progressView.setProgress(progress, animated: true)
        subtitleLabel.text = "\(completedSchedules.count)/\(mySchedules.count) reviewed"
    }
    
    private func updateStats() {
        // Calculate retention (implement your actual retention calculation)
        let retention = "85%"
        retentionView.setValue(retention)
        
        // Calculate next review
        if let nextSchedule = mySchedules.first(where: { $0.completed == nil }) {
            let timeUntil = calculateTimeUntil(nextSchedule.date.dateValue())
            nextReviewView.setValue(timeUntil)
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showScheduleDetailBtn" {
            if let destinationVC = segue.destination as? FlashcardViewController {
                destinationVC.topic = topic!.id
                if completedSchedules.count == mySchedules.count {
                    destinationVC.schedule = mySchedules.last
                    return
                }
                destinationVC.schedule = mySchedules[completedSchedules.count]
            }
        }
        
        if segue.identifier == "showScheduleDetail",
           let destinationVC = segue.destination as? FlashcardViewController,
           let index = tableView.indexPathForSelectedRow {
            destinationVC.topic = topic!.id
            destinationVC.schedule = mySchedules[index.row]
        }
        
        if segue.identifier == "toSREditSchedule",
           let navController = segue.destination as? UINavigationController,
           let destinationVC = navController.topViewController as? SREditScheduleViewController {
            destinationVC.schedules1 = mySchedules
        }
    }
    
    @IBAction func comeHere(segue: UIStoryboardSegue) {
        setup()
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate & DataSource
extension SRScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mySchedules.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SRReviewCell", for: indexPath) as! ReviewCell
        let schedule = mySchedules[indexPath.row]
        
        cell.configure(
            day: indexPath.row + 1,
            date: schedule.date.dateValue(),
            isCompleted: schedule.completed != nil,
            retention: schedule.completed != nil ? "85% retained" : nil
        )
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    // MARK: - Helper Functions
    private func calculateTimeUntil(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day, .hour], from: now, to: date)
        
        if let days = components.day, let hours = components.hour {
            if days > 0 {
                return "\(days)d \(hours)h"
            } else if hours > 0 {
                return "\(hours)h"
            } else {
                return "Now"
            }
        }
        
        return "N/A"
    }
}

