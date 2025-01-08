import UIKit
import FirebaseCore
import MobileCoreServices
import UniformTypeIdentifiers
import Foundation

class CreateViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let picker = UIPickerView()
    var thisSaturday: Date!

    
    @IBOutlet weak var Topic: UITextField!
    @IBOutlet weak var Date: UITextField!
    @IBOutlet weak var NextButton: UIButton!
    @IBOutlet weak var fileUploadView: DashedRectangleUpload!
    @IBOutlet weak var subject: UITextField!

    private var selectedSubject: Subject?
    var datePicker = UIDatePicker()
    
    // Dropdown TableView for subjects
    var dropdownTableView: UITableView!
    var subjects: [Subject] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //intial setup
        Topic.returnKeyType = .done
        Topic.autocorrectionType = .no
        Date.returnKeyType = .done
        Date.keyboardType = .numbersAndPunctuation
        fileUploadView.setup(in: self)
        setupDatePicker()
        setupDropdownTableView() // Initialize the dropdown table view
        
        subject.addTarget(self, action: #selector(showDropdown), for: .editingDidBegin) // Show dropdown when editing starts
        Task{
            subjects = try await subjectDb.findAll()
        }
    }

    @IBAction func Topic(_ sender: Any) {}
    @IBAction func Date(_ sender: Any) {}
    @IBAction func TapButton(_ sender: Any) {}

    @objc private func datePickerDone() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        Date.text = dateFormatter.string(from: datePicker.date)
        Date.resignFirstResponder()
    }
    
    private func setupDatePicker() {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 260))
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(datePickerDone))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [flexSpace, doneButton]

        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.frame = CGRect(x: 0, y: toolbar.frame.height, width: view.frame.width, height: 216)

        containerView.addSubview(toolbar)
        containerView.addSubview(datePicker)
        Date.inputView = containerView
    }
    
    private func setupDropdownTableView() {
        dropdownTableView = UITableView(frame: CGRect.zero)
        dropdownTableView.delegate = self
        dropdownTableView.dataSource = self
        dropdownTableView.isHidden = true
        dropdownTableView.layer.borderWidth = 1
        dropdownTableView.layer.borderColor = UIColor.lightGray.cgColor
        dropdownTableView.layer.cornerRadius = 5
        dropdownTableView.backgroundColor = .white
        dropdownTableView.separatorStyle = .singleLine
        self.view.addSubview(dropdownTableView)
    }
    
    @objc private func showDropdown() {
        let dropdownHeight: CGFloat = min(200, CGFloat(subjects.count + 1) * 44) // Add height for "Add Subject" button
        dropdownTableView.frame = CGRect(
            x: subject.frame.minX,
            y: subject.frame.maxY + 5,
            width: subject.frame.width,
            height: dropdownHeight
        )
        dropdownTableView.isHidden = false
        dropdownTableView.reloadData()
    }
    
    @objc private func hideDropdown() {
        dropdownTableView.isHidden = true
    }
    
    private func loadSubjects() {
        if let savedData = UserDefaults.standard.data(forKey: "subjects"),
           let decodedSubjects = try? JSONDecoder().decode([Subject].self, from: savedData) {
            subjects = decodedSubjects
        }
    }
    
    private func saveSubjects() {
        if let encoded = try? JSONEncoder().encode(subjects) {
            UserDefaults.standard.set(encoded, forKey: "subjects")
        }
    }
    
    //DataSource and tableDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subjects.count + 1 // Include "Add Subject" button
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < subjects.count {
            // Subject Cell
            let cell = UITableViewCell(style: .default, reuseIdentifier: "subjectCell")
            cell.textLabel?.text = subjects[indexPath.row].name
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
            cell.textLabel?.textColor = .black
            return cell
        } else {
            // "Add Subject" Cell
            let cell = UITableViewCell(style: .default, reuseIdentifier: "addSubjectCell")
            cell.textLabel?.text = "➕ Add Subject"
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            cell.textLabel?.textColor = UIColor.systemBlue
            cell.backgroundColor = UIColor.systemGray6
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < subjects.count {
            // Select an existing subject
            subject.text = subjects[indexPath.row].name
            selectedSubject = subjects[indexPath.row]
            hideDropdown()
        } else {
            // Add New Subject
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
                self?.selectedSubject = newSubject
                self?.dropdownTableView.reloadData()
            }
            
            present(addSubjectVC, animated: true, completion: nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        hideDropdown() // Hide dropdown when tapping outside
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectTechnique" {
            if let destinationVC = segue.destination as? SelectTechniqueViewController {
                destinationVC.date = datePicker.date
                destinationVC.topic = Topic.text
                destinationVC.subject = selectedSubject
            }
        }
    }
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "selectTechnique" {
            
            // Check if topic is entered
            guard let topic = Topic.text, !topic.isEmpty else {
                showAlert(title: "Missing Topic", message: "Please enter a topic before continuing.")
                return false
            }
            
            // Check if date is valid (e.g., not in the past)
            guard let date = Date.text, !date.isEmpty else {
                showAlert(title: "Missing Date", message: "Please enter a date before continuing.")
                return false
            }
            // Check if subject is selected
            guard selectedSubject != nil else {
                showAlert(title: "Missing Subject", message: "Please select a subject before continuing.")
                return false
            }
            
            return true
        }
        return true
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

