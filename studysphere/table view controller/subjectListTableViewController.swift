//
//  subjectListTableViewController.swift
//  studysphere
//
//  Created by admin64 on 05/11/24.
//

import UIKit
import FirebaseCore

class subjectListTableViewController: UITableViewController {
    
    @IBOutlet var subjectTableView: UITableView!
    
    public var subjects: [Subject] = []
      
      override func viewDidLoad() {
          super.viewDidLoad()
          setupUI()
          loadSubjects()
          Task {
              subjects = try await subjectDb.findAll()
              tableView.reloadData()
          }
      }
      
      private func setupUI() {
          // Configure navigation bar
          title = "My Subjects"
          navigationController?.navigationBar.prefersLargeTitles = true
          
          let addButton = UIBarButtonItem(
              image: UIImage(systemName: "plus.circle.fill"),
              style: .plain,
              target: self,
              action: #selector(showAddSubjectModal)
          )
          addButton.tintColor = AppTheme.primary
          navigationItem.rightBarButtonItem = addButton
          
          // Configure table view
          tableView.backgroundColor = .systemGray6
          tableView.separatorStyle = .none
          tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
          
          // Register custom cell
          tableView.register(subjectListTableViewCell.self, forCellReuseIdentifier: "subjectCell")
      }
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = false

    }
    
    @objc func showAddSubjectModal() {
          let addSubjectVC = AddSubjectViewController()
          addSubjectVC.modalPresentationStyle = .pageSheet
          if let sheet = addSubjectVC.sheetPresentationController {
              sheet.detents = [.medium()]
              sheet.prefersGrabberVisible = true
          }
          
        addSubjectVC.onSubjectAdded = { [weak self] newSubjectName in
            var newSubject = Subject(id:"",name: newSubjectName, createdAt: Timestamp(), updatedAt: Timestamp())
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
          let cell = tableView.dequeueReusableCell(withIdentifier: "subjectCell", for: indexPath) as! subjectListTableViewCell
          let subject = subjects[indexPath.row]
          cell.configure(with: subject, index: indexPath.row)
          return cell
      }
      
      override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
          return 90
      }
      
      override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          performSegue(withIdentifier: "toSubjectDetails", sender: indexPath)
          tableView.deselectRow(at: indexPath, animated: true)
      }
  }
