//
//  SelectTechniqueViewController.swift
//  studysphere
//
//  Created by dark on 17/11/24.
//

import UIKit

class SelectTechniqueViewController: UIViewController {
     var topic:String?
     var date:Date?
     var subject:Subject?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
        var newTopic = Topics(id: "", title: topic!, subject: subject!.id, type: .flashcards,completed: false,subtitle: "6 more to go")
        newTopic = topicsDb.create(&newTopic)
        let flashcards = createFlashCards(topic: newTopic.id)
        let mySchedules = spacedRepetitionSchedule(startDate: Date(), title:newTopic.title,topic: newTopic.id)
        for var schedule in mySchedules{
            let _ = schedulesDb.create(&schedule)
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if let tabBarVC = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController = tabBarVC
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.makeKeyAndVisible()
            
            // Ensure the TabBarController contains a UINavigationController with HomeViewController
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // Find the UINavigationController containing HomeViewController
                if let navigationVC = tabBarVC.viewControllers?.first(where: { $0 is UINavigationController }) as? UINavigationController,
                   let homeVC = navigationVC.viewControllers.first(where: { $0 is homeScreenViewController }) as? homeScreenViewController {
                    
                    // Perform the segue from HomeViewController
                    homeVC.performSegue(withIdentifier: "toSRList", sender: nil)
                } else {
                    print("Error: HomeViewController is not properly embedded in UINavigationController under TabBarController.")
                }
            }
        } else {
            print("Error: Could not instantiate TabBarController.")
        }


        
    }
    @IBAction func createAR(_ sender: Any) {
    }
    
    @IBAction func createSummarizer(_ sender: Any) {
    }
    private func createFlashCards(topic:String) -> [Flashcard]{
        let flashcards1: [Flashcard] = [
            Flashcard(id: "", question: "What is the capital of France?", answer: "Paris",topic:topic),
            Flashcard(id: "", question: "What is the capital of Germany?", answer: "Berlin",topic: topic),
            Flashcard(id: "", question: "What is the capital of Italy?", answer: "Rome",topic: topic),
            Flashcard(id: "", question: "What is the capital of Spain?", answer: "Madrid",topic: topic),
            Flashcard(id: "", question: "What is the capital of Sweden?", answer: "Stockholm",topic: topic),
            Flashcard(id: "", question: "What is the capital of Norway?", answer: "Oslo",topic: topic),
            Flashcard(id: "", question: "What is the capital of Finland?", answer: "Helsinki",topic: topic),
        ]
        for var flashcard in flashcards1{
            let _ = flashCardDb.create(&flashcard)
        }
        return flashcards1
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

