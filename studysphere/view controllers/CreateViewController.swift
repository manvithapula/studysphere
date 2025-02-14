import UIKit
import MobileCoreServices
import UniformTypeIdentifiers
import Foundation

import FirebaseCore
import GoogleGenerativeAI


struct Technique{
  var name: String
}

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
    var datePicker = UIDatePicker()
    
    // Dropdown TableView for subjects
    var dropdownTableView: UITableView!
    var subjects: [Subject] = []
    private var techniqueDropdownTableView: UITableView!
    private let techniques = [Technique(name: "Space Repetition"), Technique(name: "Active Recall"), Technique(name: "Summarizer")]
    private var selectedTechnique: Technique?
    
    var generativeModel: GenerativeModel?
    var apiKey: String? // Replace with your actual API key


    override func viewDidLoad() {
        super.viewDidLoad()
        
        //intial setup
        apiKey = "AIzaSyAPoKc-EWHZYQp-7bXbmUxyKTdZOCLgFco"

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
            cell.textLabel?.text = techniques[indexPath.row].name
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
            selectTechnique.text = selectedTechnique?.name
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
    func shouldCreate() -> Bool {
            
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
            // check if technique is selected
            guard selectedTechnique != nil else {
                showAlert(title: "Missing Technique", message: "Please select a learning technique before continuing.")
                return false
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
    @IBAction func createButtonTapped(_ sender: UIButton) {
        if(!shouldCreate()){ return}
        switch(selectedTechnique?.name){
            case techniques[0].name:
                createSR(sender)
                break
            case techniques[1].name:
                createAR(sender)
                break
            case techniques[2].name:
                createSummarizer(sender)
                break
            default:
                break
        }
    }
    
    
    
    
    
    func createSR(_ sender: Any) {
        if let apiKey = apiKey {
            let config = GenerationConfig(
                temperature: 1,
                topP: 0.95,
                topK: 64,
                maxOutputTokens: 8192,
                responseMIMEType: "application/json",
                responseSchema: Schema(type: .object,properties:[
                    "response":Schema(type: .object,properties: [
                        "data":Schema(type: .array,items:Schema(type: .object,properties: [
                            "question":Schema(type: .string),
                            "answer":Schema(type: .string)
                        ]))
                    ])
                ])
                
                
            )
            generativeModel = GenerativeModel(name: "gemini-1.5-flash", apiKey: apiKey,generationConfig: config)
        } else {
            print("API Key not found!")
        }
        var newTopic = Topics(id: "", title: Topic.text!, subject: selectedSubject!.id, type: .flashcards,subtitle: "6 more to go",createdAt: Timestamp(),updatedAt: Timestamp())
        newTopic = topicsDb.create(&newTopic)
        showLoading(text:"Generating flashcards...")
        Task{
            let cards = await createFlashCards(topic: newTopic.id)
            if(cards.isEmpty){
                hideLoading()
                showError(message: "Faled to generate flashcards")
                topicsDb.delete(id: newTopic.id)
                return
            }
            
            let mySchedules = spacedRepetitionSchedule(startDate: Foundation.Date(), title:newTopic.title,topic: newTopic.id,topicsType: TopicsType.flashcards)
            for var schedule in mySchedules{
                let _ = schedulesDb.create(&schedule)
            }
            hideLoading()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            if let tabBarVC = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController = tabBarVC
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.makeKeyAndVisible()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if let navigationVC = tabBarVC.viewControllers?.first(where: { $0 is UINavigationController }) as? UINavigationController,
                       let homeVC = navigationVC.viewControllers.first(where: { $0 is homeScreenViewController }) as? homeScreenViewController {
                        homeVC.performSegue(withIdentifier: "toSrListView", sender: nil)
                    } else {
                        print("Error: HomeViewController is not properly embedded in UINavigationController under TabBarController.")
                    }
                }
            } else {
                print("Error: Could not instantiate TabBarController.")
            }
            
        }
        
    }
    func createAR(_ sender: Any) {
        if let apiKey = apiKey {
            let config = GenerationConfig(
                temperature: 1,
                topP: 0.95,
                topK: 64,
                maxOutputTokens: 8192,
                responseMIMEType: "application/json",
                responseSchema: Schema(type: .object,properties:[
                    "response":Schema(type: .object,properties: [
                        "data":Schema(type: .array,items:Schema(type: .object,properties: [
                            "question":Schema(type: .string),
                            "option1":Schema(type: .string),
                            "option2":Schema(type: .string),
                            "option3":Schema(type: .string),
                            "option4":Schema(type: .string),
                            "correctOption":Schema(type: .string)
                        ]))
                    ])
                ])
                
                
            )
            generativeModel = GenerativeModel(name: "gemini-1.5-flash", apiKey: apiKey,generationConfig: config)
        } else {
            print("API Key not found!")
        }
        var newTopic = Topics(id: "", title: Topic.text!, subject: selectedSubject!.id, type: .quizzes,subtitle: "6 more to go",createdAt: Timestamp(),updatedAt: Timestamp())
        newTopic = topicsDb.create(&newTopic)
        showLoading(text:"Generating Quiz...")
        Task{
            let ques = await createQuestions(topic: newTopic.id)
            if(ques.isEmpty){
                hideLoading()
                showError(message: "Failed to generate Quiz")
                topicsDb.delete(id: newTopic.id)
                return
            }
            let mySchedules = spacedRepetitionSchedule(startDate: Foundation.Date(), title:newTopic.title,topic: newTopic.id,topicsType: TopicsType.quizzes)
            for var schedule in mySchedules{
                let _ = schedulesDb.create(&schedule)
            }
            hideLoading()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let tabBarVC = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController = tabBarVC
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.makeKeyAndVisible()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if let navigationVC = tabBarVC.viewControllers?.first(where: { $0 is UINavigationController }) as? UINavigationController,
                       let homeVC = navigationVC.viewControllers.first(where: { $0 is homeScreenViewController }) as? homeScreenViewController {
                        homeVC.performSegue(withIdentifier: "toArListView", sender: nil)
                    } else {
                        print("Error: HomeViewController is not properly embedded in UINavigationController under TabBarController.")
                    }
                }
            } else {
                print("Error: Could not instantiate TabBarController.")
            }
        }
    }
    
    func createSummarizer(_ sender: Any) {
        if let apiKey = apiKey {
            let config = GenerationConfig(
                temperature: 1,
                topP: 0.95,
                topK: 64,
                maxOutputTokens: 8192,
                responseMIMEType: "application/json",
                responseSchema: Schema(type: .object,properties:[
                    "response":Schema(type: .object,properties: [
                        "data":Schema(type: .object,properties: [
                            "summary":Schema(type: .string)
                        ])
                    ])
                ])
                
                
            )
            generativeModel = GenerativeModel(name: "gemini-1.5-flash", apiKey: apiKey,generationConfig: config)
        } else {
            print("API Key not found!")
        }
        var newTopic = Topics(id: "", title: Topic.text!, subject: selectedSubject!.id, type: .summary,subtitle: "",createdAt: Timestamp(),updatedAt: Timestamp())
        newTopic = topicsDb.create(&newTopic)
        showLoading(text:"Generating summary...")
        Task{
            let summary = await createSummary(topic: newTopic.id)
            hideLoading()
            if(summary == nil){
                showError(message: "Failed to create summary")
                topicsDb.delete(id:newTopic.id)
                return
            }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let tabBarVC = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController = tabBarVC
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.makeKeyAndVisible()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if let navigationVC = tabBarVC.viewControllers?.first(where: { $0 is UINavigationController }) as? UINavigationController,
                       let homeVC = navigationVC.viewControllers.first(where: { $0 is homeScreenViewController }) as? homeScreenViewController {
                        homeVC.performSegue(withIdentifier: "toSuListView", sender: nil)
                    } else {
                        print("Error: HomeViewController is not properly embedded in UINavigationController under TabBarController.")
                    }
                }
            } else {
                print("Error: Could not instantiate TabBarController.")
            }
        }
      
        }
    
    
    private func getFileUri() async -> String? {
        guard let pdfData = try? Data(contentsOf: fileUploadView.document!) else {
                    print("Error reading PDF data")
                    return nil
                }
        print(pdfData)
        let baseURL = "https://generativelanguage.googleapis.com"
        let fileSize = pdfData.count
        do {
            // Create upload URL request
            var urlComponents = URLComponents(string: "\(baseURL)/upload/v1beta/files")!
            urlComponents.queryItems = [URLQueryItem(name: "key", value: apiKey)]
            
            var request = URLRequest(url: urlComponents.url!)
            request.httpMethod = "POST"
            request.setValue("resumable", forHTTPHeaderField: "X-Goog-Upload-Protocol")
            request.setValue("start", forHTTPHeaderField: "X-Goog-Upload-Command")
            request.setValue("\(fileSize)", forHTTPHeaderField: "X-Goog-Upload-Header-Content-Length")
            request.setValue("application/pdf", forHTTPHeaderField: "X-Goog-Upload-Header-Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let metadata = ["file": ["display_name": "PDF_Document"]]
            request.httpBody = try JSONSerialization.data(withJSONObject: metadata)
            
            // Get upload URL
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  let uploadURL = httpResponse.value(forHTTPHeaderField: "X-Goog-Upload-URL") else {
                throw NSError(domain: "PDFUploader", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to get upload URL"])
            }
            
            // Upload the PDF
            var uploadRequest = URLRequest(url: URL(string: uploadURL)!)
            uploadRequest.httpMethod = "POST"
            uploadRequest.setValue("\(fileSize)", forHTTPHeaderField: "Content-Length")
            uploadRequest.setValue("0", forHTTPHeaderField: "X-Goog-Upload-Offset")
            uploadRequest.setValue("upload, finalize", forHTTPHeaderField: "X-Goog-Upload-Command")
            uploadRequest.httpBody = pdfData
            
            let (fileInfoData, _) = try await URLSession.shared.data(for: uploadRequest)
            let fileInfo = try JSONSerialization.jsonObject(with: fileInfoData) as! [String: Any]
            return (fileInfo["file"] as? [String: Any])?["uri"] as? String
        }
        catch{
            return nil
        }
    }
    private func createSummary(topic:String)async -> Summary?{
        
        
  
        do{
            guard let fileURI = await getFileUri() else {
                throw NSError(domain: "PDFUploader", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to get file URI"])
            }
            let prompt = """
            Create Summary for this PDF document.
            Focus on key concepts and important details from the content.
            so that i can give a quick look before the exam
            """
            
            let content = ModelContent(role: "user", parts: [
                        ModelContent.Part.text(prompt),
                        ModelContent.Part.fileData(mimetype: "application/pdf", uri: fileURI)
                    ])
                    
                    // Generate content using the model
            let respons = try await generativeModel?.generateContent([content])
            print(respons as Any)
                // Parse the response and create flashcards
            if let jsonData = respons?.text?.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
               let responseData = json["response"] as? [String: Any],
               let data = responseData["data"] as? [String: Any],
               let summaryText = data["summary"] as? String {
                
                var summary = Summary(
                    id: "",
                    topic: topic,
                    data: summaryText,
                    createdAt: Timestamp(),
                    updatedAt: Timestamp()
                )
                summary = summaryDb.create(&summary)
                return summary
            }
                
            return nil
        }
        catch{
            print(error)
            return nil
        }
        
    }
    private func createFlashCards(topic:String) async -> [Flashcard]{
                guard let pdfData = try? Data(contentsOf: fileUploadView.document!) else {
                            print("Error reading PDF data")
                            return []
                        }
                let baseURL = "https://generativelanguage.googleapis.com"
                let fileSize = pdfData.count
                        // Send the request to the model
//                let response = try await model.generateContent(prompt, parts: [part])
//                print(response)
                do {
                        // Create upload URL request
                        var urlComponents = URLComponents(string: "\(baseURL)/upload/v1beta/files")!
                        urlComponents.queryItems = [URLQueryItem(name: "key", value: apiKey)]
                        
                        var request = URLRequest(url: urlComponents.url!)
                        request.httpMethod = "POST"
                        request.setValue("resumable", forHTTPHeaderField: "X-Goog-Upload-Protocol")
                        request.setValue("start", forHTTPHeaderField: "X-Goog-Upload-Command")
                        request.setValue("\(fileSize)", forHTTPHeaderField: "X-Goog-Upload-Header-Content-Length")
                        request.setValue("application/pdf", forHTTPHeaderField: "X-Goog-Upload-Header-Content-Type")
                        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                        
                        let metadata = ["file": ["display_name": "PDF_Document"]]
                        request.httpBody = try JSONSerialization.data(withJSONObject: metadata)
                        
                        // Get upload URL
                        let (_, response) = try await URLSession.shared.data(for: request)
                        guard let httpResponse = response as? HTTPURLResponse,
                              let uploadURL = httpResponse.value(forHTTPHeaderField: "X-Goog-Upload-URL") else {
                            throw NSError(domain: "PDFUploader", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to get upload URL"])
                        }
                        
                        // Upload the PDF
                        var uploadRequest = URLRequest(url: URL(string: uploadURL)!)
                        uploadRequest.httpMethod = "POST"
                        uploadRequest.setValue("\(fileSize)", forHTTPHeaderField: "Content-Length")
                        uploadRequest.setValue("0", forHTTPHeaderField: "X-Goog-Upload-Offset")
                        uploadRequest.setValue("upload, finalize", forHTTPHeaderField: "X-Goog-Upload-Command")
                        uploadRequest.httpBody = pdfData
                        
                        let (fileInfoData, _) = try await URLSession.shared.data(for: uploadRequest)
                        let fileInfo = try JSONSerialization.jsonObject(with: fileInfoData) as! [String: Any]
                        guard let fileURI = (fileInfo["file"] as? [String: Any])?["uri"] as? String else {
                            throw NSError(domain: "PDFUploader", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to get file URI"])
                        }
                        
                        // Create prompt for flashcard generation
                        let prompt = """
                        Create flashcards from this PDF document.
                        Focus on key concepts and important details from the content.
                        Please provide at least 7 question-answer pairs.
                        """
                        
                    let content = ModelContent(role: "user", parts: [
                                ModelContent.Part.text(prompt),
                                ModelContent.Part.fileData(mimetype: "application/pdf", uri: fileURI)
                            ])
                            
                            // Generate content using the model
                    let respons = try await generativeModel?.generateContent([content])
                    print(respons as Any)
                        // Parse the response and create flashcards
                    if let jsonData = respons?.text?.data(using: .utf8),
                           let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                           let responseData = json["response"] as? [String: Any],
                           let cards = responseData["data"] as? [[String: String]] {
                            
                            var flashcards: [Flashcard] = []
                            for cardData in cards {
                                if let question = cardData["question"],
                                   let answer = cardData["answer"] {
                                    var flashcard = Flashcard(
                                        id: "",
                                        question: question,
                                        answer: answer,
                                        topic: topic,
                                        createdAt: Timestamp(),
                                        updatedAt: Timestamp()
                                    )
                                    let _ = flashCardDb.create(&flashcard)
                                    flashcards.append(flashcard)
                                }
                            }
                            return flashcards
                        }
                        
                        return []
                        
                    } catch {
                        print("Error processing PDF: \(error)")
                        return []
                    }
            }
    private func createQuestions(topic: String) async -> [Questions] {
        
  
        do{
            guard let fileURI = await getFileUri() else {
                print("Failed to upload")
                throw NSError(domain: "PDFUploader", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to get file URI"])
            }
            let prompt = """
            Create Questions from this PDF document.
            Focus on key concepts and important details from the content.
            make sure the answers are small as possible and fit in one line.
            Please provide at least 5 questions
            """
            
            let content = ModelContent(role: "user", parts: [
                        ModelContent.Part.text(prompt),
                        ModelContent.Part.fileData(mimetype: "application/pdf", uri: fileURI)
                    ])
                    
                    // Generate content using the model
            let respons = try await generativeModel?.generateContent([content])
            print(respons as Any)
                // Parse the response and create flashcards
            if let jsonData = respons?.text?.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                   let responseData = json["response"] as? [String: Any],
                   let cards = responseData["data"] as? [[String: String]] {
                    
                var questions: [Questions] = []
                    var i = 1
                    for cardData in cards {
                        print(cardData)
                        if let question = cardData["question"],
                           let answer = cardData["correctOption"],
                           let a = cardData["option1"],
                           let b = cardData["option2"],
                           let c = cardData["option3"],
                           let d = cardData["option4"]{
                            var optionsArray: [String] = [a,b,c,d]
                            let randomIndex = Int.random(in: 0..<optionsArray.count)
                            optionsArray[randomIndex] = answer
                            var question1 = Questions(
                                id:"",
                                questionLabel: "\(i)",
                                question: question,
                                correctanswer: answer,
                                option1: optionsArray[0],
                                option2: optionsArray[1],
                                option3: optionsArray[2],
                                option4: optionsArray[3],
                                topic: topic
                            )
                            let _ = questionsDb.create(&question1)
                            questions.append(question1)
                            i += 1
                        }
                    }
                return questions
                }
                
                return []
        }
        catch{
            return []
        }
        
    }
    private func showLoading(text:String) {
            let loadingView = LoadingView()
            loadingView.tag = 999 // Tag for easy removal
            loadingView.text = text
            view.addSubview(loadingView)
            loadingView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                loadingView.topAnchor.constraint(equalTo: view.topAnchor),
                loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            
            loadingView.show()
        }
        
        private func hideLoading() {
            if let loadingView = view.viewWithTag(999) {
                loadingView.removeFromSuperview()
            }
        }
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

