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
    private var mySchedules: [Schedule] = []
    var completedSchedules: [Schedule]{
        mySchedules.filter({
            $0.completed
        })
    }
    
    var topic:Topics?
    fileprivate func setup() {
        mySchedules = schedulesDb.findAll(where: ["topic":topic!.id])
        circularProgressV.setProgress(value: CGFloat(completedSchedules.count) / CGFloat(mySchedules.count))
        if(mySchedules.count == 0){
            mySchedules = spacedRepetitionSchedule(startDate: formatDateFromString(date: "23 Sep 2024")!, title:topic!.title,topic: topic!.id)
            for var schedule in mySchedules{
                let _ = schedulesDb.create(&schedule)
            }
            mySchedules = schedulesDb.findAll(where: ["topic":topic!.id])
        }
        progressL.text = "\(completedSchedules.count)/\(mySchedules.count)"
        let countDiff = mySchedules.count - completedSchedules.count
        if(countDiff == 0){
            remainingNumberL.text = "All schedules are completed"
            topic?.subtitle = "All schedules are completed"
            topic?.completed = true
        }
        else{
            remainingNumberL.text = "\(countDiff) more to go"
            topic?.subtitle = "\(countDiff) more to go"
        }
        topicsDb.update(topic!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        scheduleTable.delegate = self
        scheduleTable.dataSource = self
        setup()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "showScheduleDetail" {
                if let destinationVC = segue.destination as? FlashcardViewController,
                   let index = scheduleTable.indexPathForSelectedRow {
                    destinationVC.flashcards = flashCardDb.findAll(where: ["topic":topic!.id])
                    destinationVC.schedule = mySchedules[index.row]
                }
            }
        if segue.identifier == "showScheduleDetailBtn" {
            if completedSchedules.count == mySchedules.count {
                
            }
            if let destinationVC = segue.destination as? FlashcardViewController{
                destinationVC.flashcards = flashCardDb.findAll(where: ["topic":topic!.id])
                if completedSchedules.count == mySchedules.count {
                    destinationVC.schedule = mySchedules.last
                    return
                }
                destinationVC.schedule = mySchedules[completedSchedules.count]
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

