//
//  subjectListTableViewController.swift
//  studysphere
//
//  Created by admin64 on 05/11/24.
//

import UIKit

class subjectListTableViewController: UITableViewController {
    
    @IBOutlet var subjectTableView: UITableView!
    var subjects: [Subject] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSubjects()
        subjects = subjectDb.findAll()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showAddSubjectModal))
                navigationItem.rightBarButtonItem = addButton
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @objc func showAddSubjectModal() {
          let addSubjectVC = AddSubjectViewController()
          addSubjectVC.modalPresentationStyle = .pageSheet
          if let sheet = addSubjectVC.sheetPresentationController {
              sheet.detents = [.medium()]
              sheet.prefersGrabberVisible = true
          }
          
        addSubjectVC.onSubjectAdded = { [weak self] newSubjectName in
            var newSubject = Subject(id:"",name: newSubjectName)
            newSubject = subjectDb.create(&newSubject)
            self?.subjects.append(newSubject)
            self?.tableView.reloadData()  // Reload the table view to show the new subject
        }

          present(addSubjectVC, animated: true, completion: nil)
      }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSubjectDetails",
           let destinationVC = segue.destination as? subjectViewController,
           let indexPath = sender as? IndexPath {
            let subject = subjects[indexPath.row]
            destinationVC.subject = subject
        }
    }
    
    private func saveSubjects() {
            if let encoded = try? JSONEncoder().encode(subjects) {
                UserDefaults.standard.set(encoded, forKey: "subjects")
            }
        }
    
    private func loadSubjects() {
           if let savedData = UserDefaults.standard.data(forKey: "subjects"),
              let decodedSubjects = try? JSONDecoder().decode([Subject].self, from: savedData) {
               subjects = decodedSubjects
           }
       }
    

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
}
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return subjects.count
}
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subjectcell", for: indexPath) as! subjectListTableViewCell
        let subject = subjects[indexPath.row]
        cell.subjectListButton.setTitle(subject.name, for: .normal)
        cell.subjectListButton.addTarget(self, action: #selector(detailButtonTapped(_:)), for: .touchUpInside)

        return cell
}

    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 70
}
    @objc func detailButtonTapped(_ sender: UIButton) {
        if let cell = sender.superview?.superview as? subjectListTableViewCell,
           let indexPath = self.tableView.indexPath(for: cell) {
            performSegue(withIdentifier: "toSubjectDetails", sender: indexPath)
        }
    }
    //can select row
    
}
    
    
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // Set the height for each row to add spacing
    
