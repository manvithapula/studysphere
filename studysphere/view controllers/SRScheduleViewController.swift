//
//  SRScheduleViewController.swift
//  studysphere
//
//  Created by dark on 05/11/24.
//

import UIKit

class SRScheduleViewController: UIViewController {

    @IBOutlet weak var progressL: UILabel!
    @IBOutlet weak var circularProgressV: CircularProgressView!
    @IBOutlet weak var scheduleTable: UITableView!
    @IBOutlet weak var remainingNumberL: UILabel!
    var completedSchedules: [Schedule]{
        schedules.filter({
            $0.completed
        })
    }
    fileprivate func setup() {
        circularProgressV.setProgress(value: CGFloat(completedSchedules.count) / CGFloat(schedules.count))
        progressL.text = "\(completedSchedules.count)/\(schedules.count)"
        let countDiff = schedules.count - completedSchedules.count
        if(countDiff == 0){
            remainingNumberL.text = "All schedules are completed"
        }
        else{
            remainingNumberL.text = "\(countDiff) more to go"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        scheduleTable.delegate = self
        scheduleTable.dataSource = self
        setup()
    }
    
    
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "showScheduleDetail" {
                if let destinationVC = segue.destination as? FlashcardViewController,
                   let index = scheduleTable.indexPathForSelectedRow {
                    destinationVC.flashcards = flashcards1
                    destinationVC.scheduleIndex = index.row
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
        return schedules.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleCell", for: indexPath)
        let scedules = schedules[indexPath.row]
        
        if let cell = cell as? SRScheduleTableViewCell {
            cell.completionImage.image = UIImage(systemName: scedules.completed ? "checkmark.circle.fill" : "circle.dashed")
            cell.titleL.text = scedules.title
            cell.dateL.text = "Date: " + formatDateToString(date: scedules.date)
            cell.timeL.text = "Time: " + scedules.time
            cell.selectionStyle = .none

        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    
    
}

