//
//  SRScheduleViewController.swift
//  studysphere
//
//  Created by dark on 05/11/24.
//

import UIKit
import FirebaseCore

class SRScheduleViewController: UIViewController {

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
    
    
    
}

