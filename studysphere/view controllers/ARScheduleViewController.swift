//
//  ARScheduleViewController.swift
//  studysphere
//
//  Created by Dev on 16/11/24.
//

import UIKit
import FirebaseCore

class ARScheduleViewController: UIViewController {

    @IBOutlet weak var ProgressNum: UILabel!
    @IBOutlet weak var ARprogresswheel: CircularProgressView!
    @IBOutlet weak var ARtable: UITableView!
    @IBOutlet weak var ARremaningnumber: UILabel!
    private var mySchedules: [Schedule] = []

    var completedSchedules: [Schedule]{
        mySchedules.filter({
            $0.completed != nil
        })
    }
    var topic: Topics?
    fileprivate func setup() {
        Task{
            mySchedules = try await schedulesDb.findAll(where: ["topic":topic!.id])
            mySchedules = try await schedulesDb.findAll(where: ["topic":topic!.id])
            let sortedSchedules = mySchedules.sorted(by: { (schedule1, schedule2) -> Bool in
                return schedule1.date.dateValue() < schedule2.date.dateValue()
            })
            mySchedules = sortedSchedules
            ARtable.reloadData()
            ARprogresswheel.setProgress(value: CGFloat(completedSchedules.count) / CGFloat(schedules.count))
            ProgressNum.text = "\(completedSchedules.count)/\(schedules.count)"
            let countDiff = mySchedules.count - completedSchedules.count
            if(countDiff == 0){
                ARremaningnumber.text = "All schedules are completed"
                topic?.subtitle = "All schedules are completed"
                topic?.completed = Timestamp()
            }
            else{
                ARremaningnumber.text = "\(countDiff) more to go"
                topic?.subtitle = "\(countDiff) more to go"
            }
            var topicsTemp = topic
            try await topicsDb.update(&topicsTemp!)
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        ARtable.delegate = self
        ARtable.dataSource = self
        setup()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "toQuestionVCBtn" {
                if let destinationVC = segue.destination as? QuestionViewController {
                    destinationVC.topic = topic
                    if completedSchedules.count == mySchedules.count {
                        destinationVC.schedule = mySchedules.last!
                        return
                    }
                    destinationVC.schedule = mySchedules[completedSchedules.count]
                }
            }
        if segue.identifier == "toQuestionVC" {
            if let destinationVC = segue.destination as? QuestionViewController ,
            let index = ARtable.indexPathForSelectedRow{
                destinationVC.topic = topic
                destinationVC.schedule = mySchedules[index.row]
            }
            
        }

        

        }
    @IBAction func comeHere(segue:UIStoryboardSegue) {
        //refresh table
        setup()
        ARtable.reloadData()
    }

}

extension ARScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mySchedules.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ARscheduleCell", for: indexPath)
        let scedules = mySchedules[indexPath.row]
        
        if let cell = cell as? ARScheduleTableViewCell {
            cell.ARcompletionImage.image = UIImage(systemName: (scedules.completed != nil) ? "checkmark.circle.fill" : "circle.dashed")
            cell.ARtitle.text = "Revision \(indexPath.row + 1)"
            cell.ARdate.text = "Date: " + formatDateToString(date: scedules.date.dateValue())
            cell.ARtime.text = "Time: " + scedules.time
            cell.selectionStyle = .none

        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.isTabBarHidden = false
    }
    
    
}

