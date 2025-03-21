//
//  subjectListTableViewController.swift
//  studysphere
//
//  Created by admin64 on 05/11/24.
//

import UIKit
import FirebaseCore

class MySubjectListTableViewController: UITableViewController {
    
    @IBOutlet var subjectTableView: UITableView!
    public var subjects: [Subject] = []
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No subjects yet.\nTap '+' to add a new subject."
        label.textAlignment = .center
        label.numberOfLines = 2
     //   label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()

         
      override func viewDidLoad() {
          super.viewDidLoad()
          setupTapGesture()
          setupUI()
          loadSubjects()
          setupEmptyStateView()
    
          Task {
              subjects = try await subjectDb.findAll()
              tableView.reloadData()
          }
      }
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
            
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
      
      private func setupUI() {
          // Configure navigation bar
          title = "My Subjects"
          let addButton = UIBarButtonItem(
              image: UIImage(systemName: "plus.circle"),
              style: .plain,
              target: self,
              action: #selector(showAddSubjectModal)
          )
          addButton.tintColor = AppTheme.primary
          navigationItem.rightBarButtonItem = addButton
          
        
          tableView.backgroundColor = .systemGray6
          tableView.separatorStyle = .none
          tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
          
          
          tableView.register(subjectListTableViewCell.self, forCellReuseIdentifier: "subjectCell")
      }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = false

    }
    
    private func setupEmptyStateView() {
            tableView.backgroundView = emptyStateLabel
        }

        private func updateEmptyState() {
            let isEmpty = subjects.isEmpty
            emptyStateLabel.isHidden = !isEmpty
            tableView.backgroundView = isEmpty ? emptyStateLabel : nil
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
           let destinationVC = segue.destination as? SubjectDetailsViewController,
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
          updateEmptyState()
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
