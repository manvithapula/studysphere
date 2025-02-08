import UIKit
import FirebaseCore
import MobileCoreServices
import UniformTypeIdentifiers
import Foundation

class CreateViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIDocumentPickerDelegate {
    let picker = UIPickerView()
    var thisSaturday: Date!
    

    
    @IBOutlet weak var Topic: UITextField!
    @IBOutlet weak var Date: UITextField!
    @IBOutlet weak var NextButton: UIButton!
    @IBOutlet weak var fileUploadView: DashedRectangleUpload!
    @IBOutlet weak var subject: UITextField!
    @IBOutlet weak var selectTechnique: UITextField!
    
    private var selectedSubject: Subject?
    private var document:URL? = nil
    var datePicker = UIDatePicker()
    
    // Dropdown TableView for subjects
    var dropdownTableView: UITableView!
    var subjects: [Subject] = []
    private var techniqueDropdownTableView: UITableView!
    private let techniques = ["Space Repetition", "Active Recall", "Summarizer"]
    private var selectedTechnique: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //intial setup
        Topic.returnKeyType = .done
        Topic.autocorrectionType = .no
        Date.returnKeyType = .done
        Date.keyboardType = .numbersAndPunctuation
        fileUploadView.setup(in: self)
        fileUploadView.isUserInteractionEnabled = true
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectPDF))
//        fileUploadView.addGestureRecognizer(tapGesture)
        setupDatePicker()
        setupDropdownTableView() // Initialize the dropdown table view
        subject.addTarget(self, action: #selector(showDropdown), for: .allTouchEvents) // Show dropdown when editing starts
        Task{
            subjects = try await subjectDb.findAll()
        }
        setupTechniqueDropdown()
        selectTechnique.addTarget(self, action: #selector(showTechniqueDropdown), for: .allTouchEvents)
    }
    private func setupTechniqueDropdown() {
        techniqueDropdownTableView = UITableView(frame: CGRect.zero)
        techniqueDropdownTableView.delegate = self
        techniqueDropdownTableView.dataSource = self
        techniqueDropdownTableView.isHidden = true
        techniqueDropdownTableView.layer.borderWidth = 1
        techniqueDropdownTableView.layer.borderColor = UIColor.lightGray.cgColor
        techniqueDropdownTableView.layer.cornerRadius = 5
        techniqueDropdownTableView.backgroundColor = .white
        techniqueDropdownTableView.separatorStyle = .singleLine
        techniqueDropdownTableView.tag = 2 // To distinguish from subject dropdown
        self.view.addSubview(techniqueDropdownTableView)
    }

    @objc private func showTechniqueDropdown() {
        // Hide subject dropdown if it's visible
        dropdownTableView.isHidden = true
        
        let dropdownHeight: CGFloat = CGFloat(techniques.count) * 44
        techniqueDropdownTableView.frame = CGRect(
            x: selectTechnique.frame.minX,
            y: selectTechnique.frame.maxY + 5,
            width: selectTechnique.frame.width,
            height: dropdownHeight
        )
        techniqueDropdownTableView.isHidden = false
        techniqueDropdownTableView.reloadData()
    }

    private func hideTechniqueDropdown() {
        techniqueDropdownTableView.isHidden = true
    }
    @objc func selectPDF() {
            let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf], asCopy: true)
            documentPicker.delegate = self
            present(documentPicker, animated: true, completion: nil)
        }
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else {
            return
        }
        document = selectedFileURL
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
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 300))
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
        if tableView.tag == 2 {
            return techniques.count
        }
        return subjects.count + 1 // Original subject dropdown logic
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 2 {
            // Technique dropdown
            let cell = UITableViewCell(style: .default, reuseIdentifier: "techniqueCell")
            cell.textLabel?.text = techniques[indexPath.row]
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
            cell.textLabel?.textColor = .black
            return cell
        } else {
            // Original subject dropdown logic
            if indexPath.row < subjects.count {
                let cell = UITableViewCell(style: .default, reuseIdentifier: "subjectCell")
                cell.textLabel?.text = subjects[indexPath.row].name
                cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
                cell.textLabel?.textColor = .black
                return cell
            } else {
                let cell = UITableViewCell(style: .default, reuseIdentifier: "addSubjectCell")
                cell.textLabel?.text = "➕ Add Subject"
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
                cell.textLabel?.textColor = UIColor.systemBlue
                cell.backgroundColor = UIColor.systemGray6
                return cell
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 2 {
            // Technique selection
            selectedTechnique = techniques[indexPath.row]
            selectTechnique.text = selectedTechnique
            hideTechniqueDropdown()
        } else {
            // Original subject selection logic
            if indexPath.row < subjects.count {
                subject.text = subjects[indexPath.row].name
                selectedSubject = subjects[indexPath.row]
                hideDropdown()
            } else {
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
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        hideDropdown()
        hideTechniqueDropdown()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectTechnique" {
            if let destinationVC = segue.destination as? SelectTechniqueViewController {
                destinationVC.date = datePicker.date
                destinationVC.topic = Topic.text
                destinationVC.subject = selectedSubject
                destinationVC.document = fileUploadView.document
//                destinationVC.technique = selectedTechnique
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
            guard selectedTechnique != nil else {
                showAlert(title: "Missing Technique", message: "Please select a learning technique before continuing.")
                return false
            }
            //check if document is selected
            guard fileUploadView.document != nil else {
                showAlert(title: "Missing Document", message: "Please select a document before continuing.")
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

