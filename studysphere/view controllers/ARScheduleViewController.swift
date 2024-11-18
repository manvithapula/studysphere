//
//  ARScheduleViewController.swift
//  studysphere
//
//  Created by Dev on 16/11/24.
//

import UIKit

class ARScheduleViewController: UIViewController {

    @IBOutlet weak var ProgressNum: UILabel!
    @IBOutlet weak var ARprogresswheel: CircularProgressView!
    @IBOutlet weak var ARtable: UITableView!
    @IBOutlet weak var ARremaningnumber: UILabel!
    var completedSchedules: [Schedule]{
        schedules.filter({
            $0.completed
        })
    }
    var topic: Topics?
    private var mySchedules: [Schedule] = []
    fileprivate func setup() {
        ARprogresswheel.setProgress(value: CGFloat(completedSchedules.count) / CGFloat(schedules.count))
        ProgressNum.text = "\(completedSchedules.count)/\(schedules.count)"
        let countDiff = schedules.count - completedSchedules.count
        if(countDiff == 0){
            ARremaningnumber.text = "All schedules are completed"
        }
        else{
            ARremaningnumber.text = "\(countDiff) more to go"
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        mySchedules = schedulesDb.findAll(where: ["topic":topic!.id])
        // Do any additional setup after loading the view.
        ARtable.delegate = self
        ARtable.dataSource = self
        setup()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "toQuestionVC" {
                if let destinationVC = segue.destination as? QuestionViewController {
                    destinationVC.topic = topic
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
            cell.ARcompletionImage.image = UIImage(systemName: scedules.completed ? "checkmark.circle.fill" : "circle.dashed")
            cell.ARtitle.text = scedules.title
            cell.ARdate.text = "Date: " + formatDateToString(date: scedules.date)
            cell.ARtime.text = "Time: " + scedules.time
            cell.selectionStyle = .none

        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    
    
}

