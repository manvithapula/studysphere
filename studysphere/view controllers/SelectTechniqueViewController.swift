//
//  SelectTechniqueViewController.swift
//  studysphere
//
//  Created by dark on 17/11/24.
//

import UIKit
import Foundation

import FirebaseCore
import GoogleGenerativeAI

class SelectTechniqueViewController: UIViewController {
    var topic:String?
    var date:Date?
    var subject:Subject?
    var document:URL?
    
    var generativeModel: GenerativeModel?
    var apiKey: String? // Replace with your actual API key
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        apiKey = "AIzaSyBlcKonY3wWaBE_ZTwP7CzKpbiuArd6Ugk"
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    @IBAction func createSR(_ sender: Any) {
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
        var newTopic = Topics(id: "", title: topic!, subject: subject!.id, type: .flashcards,subtitle: "6 more to go",createdAt: Timestamp(),updatedAt: Timestamp())
        newTopic = topicsDb.create(&newTopic)
        showLoading()
        Task{
            _ = await createFlashCards(topic: newTopic.id)
            
            let mySchedules = spacedRepetitionSchedule(startDate: Date(), title:newTopic.title,topic: newTopic.id,topicsType: TopicsType.flashcards)
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
    @IBAction func createAR(_ sender: Any) {
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
        var newTopic = Topics(id: "", title: topic!, subject: subject!.id, type: .quizzes,subtitle: "6 more to go",createdAt: Timestamp(),updatedAt: Timestamp())
        newTopic = topicsDb.create(&newTopic)
        showLoading()
        Task{
            let ques = await createQuestions(topic: newTopic.id)
            print(ques)
            let mySchedules = spacedRepetitionSchedule(startDate: Date(), title:newTopic.title,topic: newTopic.id,topicsType: TopicsType.quizzes)
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
    
    @IBAction func createSummarizer(_ sender: Any) {
        var newTopic = Topics(id: "", title: topic!, subject: subject!.id, type: .summary,subtitle: "",createdAt: Timestamp(),updatedAt: Timestamp())
        newTopic = topicsDb.create(&newTopic)
        _ = createSummary(topic: newTopic.id)
        
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
    private func createSummary(topic:String) -> Summary{
        var summary:Summary = Summary( id: "", topic: topic,data: "sdfasasdsadad", createdAt: Timestamp(), updatedAt: Timestamp())
        summary = summaryDb.create(&summary)

        return summary
    }
    
    private func getFileUri() async -> String? {
        guard let pdfData = try? Data(contentsOf: document!) else {
                    print("Error reading PDF data")
                    return nil
                }
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
            
    private func createFlashCards(topic:String) async -> [Flashcard]{
                guard let pdfData = try? Data(contentsOf: document!) else {
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
        guard let pdfData = try? Data(contentsOf: document!) else {
                    print("Error reading PDF data")
                    return []
                }
  
        do{
            guard let fileURI = await getFileUri() else {
                throw NSError(domain: "PDFUploader", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to get file URI"])
            }
            let prompt = """
            Create Questions from this PDF document.
            Focus on key concepts and important details from the content.
            make sure the answers are small as possible and fit in one line.
            one of the option should be the correct answer and randomize this option
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
                            var question1 = Questions(
                                id:"",
                                questionLabel: "\(i)",
                                question: question,
                                correctanswer: answer,
                                option1: a,
                                option2: b,
                                option3: c,
                                option4: d,
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
            private func showAlert(title: String, message: String) {
                let alert = UIAlertController(
                    title: title,
                    message: message,
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
            }
    
    private func showLoading() {
            let loadingView = LoadingView()
            loadingView.tag = 999 // Tag for easy removal
            
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
        }
        

class LoadingView: UIView {
    private let activityIndicator: UIActivityIndicatorView
    private let messageLabel: UILabel
    private let blurEffect: UIVisualEffectView
    
    init() {
        // Create blur effect
        let blur = UIBlurEffect(style: .dark)
        blurEffect = UIVisualEffectView(effect: blur)
        
        // Create activity indicator
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        
        // Create message label
        messageLabel = UILabel()
        messageLabel.text = "Generating flashcards..."
        messageLabel.textColor = .white
        messageLabel.textAlignment = .center
        messageLabel.font = .systemFont(ofSize: 16, weight: .medium)
        
        super.init(frame: .zero)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Add blur effect
        addSubview(blurEffect)
        blurEffect.translatesAutoresizingMaskIntoConstraints = false
        
        // Create container for indicator and label
        let containerView = UIView()
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        containerView.layer.cornerRadius = 12
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add indicator and label to container
        containerView.addSubview(activityIndicator)
        containerView.addSubview(messageLabel)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Blur takes up entire view
            blurEffect.topAnchor.constraint(equalTo: topAnchor),
            blurEffect.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurEffect.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurEffect.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Container constraints
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 200),
            containerView.heightAnchor.constraint(equalToConstant: 100),
            
            // Activity indicator constraints
            activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            
            // Label constraints
            messageLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            messageLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 10)
        ])
    }
    
    func show() {
        activityIndicator.startAnimating()
    }
    
    func hide() {
        activityIndicator.stopAnimating()
    }
}
