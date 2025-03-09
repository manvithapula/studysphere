//
//  dataType.swift
//  studysphere
//
//  Created by dark on 29/10/24.
//

import Foundation
import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore



struct AppTheme {
    static let primary = UIColor(red: 37/255, green: 99/255, blue: 235/255, alpha: 1.0) //blue
    static let secondary = UIColor(red: 99/255, green: 102/255, blue: 241/255, alpha: 1.0) // light blue
    static let background = UIColor.white // white
    static let cardBackground = UIColor(red: 249/255, green: 250/255, blue: 251/255, alpha: 1.0) // 
    
}

struct StudyModule {
    let technique: String
    let subject: String
    let dueDate: Date
    let title: String
    let progress: Double
}
protocol Identifiable {
    var id: String { get set }
    var createdAt: Timestamp { get set }
    var updatedAt: Timestamp { get set }
}
//homescreen
class FirestoreManager {
    static let shared = FirestoreManager()
    let db: Firestore

    private init() {
        db = Firestore.firestore()
        configure()
    }

    private func configure() {
        let settings = FirestoreSettings()
        db.settings = settings
    }
}

// nav bar
struct UserProfile {
    let name: String
    let profilePictureURL: URL?
    let motivationalMessage: String
}

// streak
struct StreakDay {
    let dayOfWeek: String
    let isCompleted: Bool
}

// todays learning
struct ScheduleItem {
    let iconName: String
    let title: String
    let subtitle: String
    let progress: Float
    let topicType:TopicsType
    let topicId:String
}


  

// study technique
struct StudyTechnique {
    let name: String
    let completedSessions: Int
    let totalSessions: Int
}

var studyTechniques: [StudyTechnique] = [
    StudyTechnique(name: "Flashcards", completedSessions: 5, totalSessions: 10),
    StudyTechnique(name: "Active Recall", completedSessions: 3, totalSessions: 10),
    StudyTechnique(name: "Review", completedSessions: 5, totalSessions: 10)
]

struct DashboardData {
    let userProfile: UserProfile
    let streak: [StreakDay]
    let todaySchedule: [ScheduleItem]
    let subjects: [Subject]
    let studyTechniques: [StudyTechnique]
}
/*let streakValues = [
    false,
    false,
    true,
    true,
    true,
    true,
    true
]*/

//subject
struct Subject:Codable,Identifiable{
    var id:String
    let name:String
    var createdAt:Timestamp
    var updatedAt:Timestamp
    
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "name": name,
            "createdAt": createdAt,
            "updatedAt": updatedAt
        ]
    }

}
struct Score:Codable,Identifiable {
    var id:String
    var score:Int
    var total:Int
    var scheduleId:String
    var topicId:String
    var createdAt:Timestamp
    var updatedAt:Timestamp
}
//list referencing
struct Topics:Codable,Identifiable {
    var id:String
    var title:String
    var subject:String
    var type:TopicsType
    var completed:Timestamp?
    var subtitle:String
    var createdAt:Timestamp
    var updatedAt:Timestamp
    
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "title": title,
            "subject": subject,
            "type": type,
            "completed": completed!,
            "subtitle": subtitle,
            "createdAt": createdAt,
            "updatedAt": updatedAt
        ]
    }
    
    
}
enum TopicsType: String, Codable {
    case flashcards = "flashcards"
    case quizzes = "quizzes"
    case summary = "summary"
}
struct ProgressType{
    var completed:Int
    var total:Int
    var progress:Double{
        Double(completed)/Double(total)
    }
}

//profile
struct UserDetailsType:Codable,Identifiable{
    var id:String
    var firstName:String
    var lastName:String
    var dob:Timestamp
    var pushNotificationEnabled:Bool
    var faceIdEnabled:Bool
    var email:String
    var password:String
    var createdAt:Timestamp
    var updatedAt:Timestamp
    
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "firstName": firstName,
            "lastName": lastName,
            "dob": dob,
            "pushNotificationEnabled": pushNotificationEnabled,
            "faceIdEnabled": faceIdEnabled,
            "email": email,
            "password": password,
            "createdAt":createdAt,
            "updatedAt":updatedAt
            ]
    }
 
    init(id:String,firstName:String,lastName:String,dob:Timestamp,pushNotificationEnabled:Bool,faceIdEnabled:Bool,email:String,password:String,createdAt:Timestamp,updatedAt:Timestamp){
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.dob = dob
        self.pushNotificationEnabled = pushNotificationEnabled
        self.faceIdEnabled = faceIdEnabled
        self.email = email
        self.password = password
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
var user = UserDetailsType(id: "1", firstName: "Anwin", lastName: "Sharon", dob: Timestamp(), pushNotificationEnabled: false, faceIdEnabled: true,email: "test@test.com",password: "password",createdAt:Timestamp(),updatedAt:Timestamp())


//flashcard view controller
struct Flashcard:Codable,Identifiable {
    var id:String
    var question: String
    var answer: String
    var topic:String
    var createdAt:Timestamp
    var updatedAt:Timestamp
    
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "question": question,
            "answer": answer,
            "topic": topic,
            "createdAt": createdAt,
            "updatedAt": updatedAt,
        ]
    }
}

// ar view controller 
struct Questions: Codable, Identifiable {
    var id: String
    var questionLabel: String
    var question: String
    var correctanswer: String
    var option1 : String
    var option2 : String
    var option3 : String
    var option4 : String
    var topic : String
    var createdAt:Timestamp
    var updatedAt:Timestamp
    
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "questionLabel": questionLabel,
            "question": question,
            "correctanswer": correctanswer,
            "option1": option1,
            "option2": option2,
            "option3": option3,
            "option4": option4,
            "topic":topic,
            "createdAt": createdAt,
            "updatedAt": updatedAt
            ]
    }
    
    init(id:String,questionLabel:String,question:String,correctanswer:String,option1:String,option2:String,option3:String,option4:String,topic:String){
        self.id = id
        self.questionLabel = questionLabel
        self.question = question
        self.correctanswer = correctanswer
        self.option1 = option1
        self.option2 = option2
        self.option3 = option3
        self.option4 = option4
        self.topic = topic
        self.createdAt = Timestamp()
        self.updatedAt = Timestamp()
    }
}

//summariser view controller
struct Summary:Codable,Identifiable{
    var id:String
    var topic:String
    var data:String
    var createdAt:Timestamp
    var updatedAt:Timestamp
    
    func toDictionary() -> [String: Any]{
        return [
            "id":id,
            "topic":topic,
            "data": data,
            "createdAt":createdAt,
            "updatedAt":updatedAt
        ]
    }
}

// active recall and spaced repetition schedule view controller
struct Schedule:Codable,Identifiable{
    var id:String
    var title:String
    var date:Timestamp
    var time:String
    var completed:Timestamp?
    var topic:String
    var topicType:TopicsType
    var createdAt:Timestamp
    var updatedAt:Timestamp
    
    func toDictionary() -> [String:Any]{
        return [
            "id":id,
            "title":title,
            "date":date,
            "time":time,
            "completed":completed!,
            "topic":topic,
            "topicType":topicType,
            "createdAt":createdAt,
            "updatedAt":updatedAt
        ]
    }
}




var ARQuestions : [Questions] = [
    Questions(id: "", questionLabel: "1", question: "Who will win election in india ?", correctanswer: "Narendra Modi", option1: "Narendra Modi", option2: "Rahul Gandhi", option3: "Kejrival ", option4: "Umman Chandi", topic: ""),
    Questions(id: "", questionLabel: "2", question: "Where was the first General Indian Post", correctanswer: "Mumbai", option1: "Kolkata", option2: "Mumbai", option3: "Delhi", option4: "Chennai", topic: "")
]

let unformattedDate = "14 Jan 2001"

func formatDateFromString(date:String) -> Date?{
    var dateFormatter:DateFormatter{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter
    }
    return dateFormatter.date(from: date)
}

func formatDateToString(date:Date) -> String{
    let formatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter
    }()
    return formatter.string(from: date)
}
var date:Date?{
    formatDateFromString(date: unformattedDate)
}

var schedules:[Schedule] = spacedRepetitionSchedule(startDate: formatDateFromString(date: "23 Sep 2024")!, title: "Swift fundamentals ",topic: "Swift",topicsType: TopicsType.flashcards)

import Foundation

func spacedRepetitionSchedule(startDate: Date,title:String,topic:String,topicsType:TopicsType) -> [Schedule] {
    let intervals = [0, 1, 3, 7, 14, 30]
    let calendar = Calendar.current
    let schedule = intervals.map { interval in
        let date = calendar.date(byAdding: .day, value: interval, to: startDate)!
        return Schedule(id:"",title: title, date: Timestamp(date:date), time: "10:00 AM", completed:nil, topic: topic,topicType: topicsType,createdAt: Timestamp(),updatedAt: Timestamp())
    }
    
    return schedule
}




let flashcardsProgress:ProgressType=ProgressType(completed: 250, total: 500)
let questions:ProgressType=ProgressType(completed: 250, total: 300)
let hours:ProgressType=ProgressType(completed: 20, total: 24*7)
let flashcardsMonthly:ProgressType=ProgressType(completed: 550, total: 700)
let questionsMonthly:ProgressType=ProgressType(completed: 333, total: 645)
let hoursMonthly:ProgressType=ProgressType(completed: 24, total: 6*7)
let weeklyTime = 1000 * 60 * 46
let weeklyStreak = 7
let monthlyTime = 1000 * 60 * 60 * 10
let monthlyStreak = 17


class FakeDb<T: Codable & Identifiable> {
    private var name: String
    private let db: Firestore
    private var collection: CollectionReference {
        if(name == "usertemp"){
            return db.collection("usertemp")
        }
        return db.collection("userdata").document(String(AuthManager.shared.id!)).collection(name)
    }
    private var ArchiveURL: URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentDirectory.appendingPathComponent("\(self.name).plist")
        return archiveURL
    }
    private var items: [T]
    private var loaded = false
    init(name: String) {
        self.name = name
        self.db = FirestoreManager.shared.db
        self.items = []
        Task{
            _ = await self.loadData()
        }
    }
    
    public func create(_ item: inout T) -> T{
        item.id = UUID().uuidString
        item.createdAt = Timestamp()
        items.append(item)
        try! collection.document(item.id).setData(item.asDictionary());
        saveData()
        return item
    }
    

    public func findAll(where conditions: [String: Any]? = nil) async throws -> [T] {
        // Initialize Firestore collection reference
        
        // If no conditions are provided, fetch all documents
        let items = await self.loadData()
        guard let conditions = conditions else {
                    return items
                }
                
                // Filter items based on conditions
                return items.filter { item in
                    guard let itemDict = try? item.asDictionary() else { return false }
                    
                    return conditions.allSatisfy { key, value in
                        if let itemValue = itemDict[key] {
                            return String(describing: itemValue) == String(describing: value)
                        }
                        return false
                    }
                }
    }

    
    public func findFirst(where conditions: [String: Any]? = nil) -> T? {
        guard let conditions = conditions else {
            return items.first
        }
        return items.first { item in
            guard let itemDict = try? item.asDictionary() else { return false }
            
            return conditions.allSatisfy { key, value in
                if let itemValue = itemDict[key] {
                    return String(describing: itemValue) == String(describing: value)
                }
                return false
            }
        }
    }
    
    public func update(_ item: inout T) async throws {
        item.updatedAt = Timestamp()
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
        }

        let documentRef = collection.document(item.id)
        do {
            let data = try item.asDictionary()
            try await documentRef.updateData(data)
            print("Document with id \(item.id) successfully updated.")
        } catch {
            print("Error updating document: \(error)")
            throw error
        }

    }

    
    public func delete(id: String) {
        items.removeAll { $0.id == id }
        collection.document(id).delete()
        saveData()
    }
    
    @available(iOS 15.0, *)
    private func loadData() async -> [T] {
        if loaded {
            return items
        }

        do {
            let querySnapshot = try await collection.getDocuments()

            let documents = querySnapshot.documents

            var fetchedItems: [T] = []
            for document in documents {
                let data = document.data()
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    let item = try decoder.decode(T.self, from: jsonData)
                    fetchedItems.append(item)
                } catch {
                    print("Error decoding document: \(document.documentID), error: \(error)")
                }
            }
            self.items = fetchedItems
            self.loaded = true
            return fetchedItems
        } catch {
            print("Error getting documents: \(error)")
            return []
        }
    }
    
    private func saveData() {
        let plistEncoder = PropertyListEncoder()
        let data = try? plistEncoder.encode(self.items)
        try? data?.write(to: ArchiveURL)
    }
}
// Extension to help convert Codable to Dictionary
extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Dictionary conversion failed"])
        }
        return dictionary
    }
}

class AuthManager {
    static let shared = AuthManager()
    
    private init() {}
    
    var isLoggedIn: Bool {
        return UserDefaults.standard.string(forKey: "userEmail") != nil
    }
    
    var userEmail: String? {
        return UserDefaults.standard.string(forKey: "userEmail")
    }
    var firstName: String? {
        return UserDefaults.standard.string(forKey: "firstName")
    }
    var lastName: String? {
        return UserDefaults.standard.string(forKey: "lastName")
    }
    var id: String? {
        return UserDefaults.standard.string(forKey: "id")
    }
    
    func logIn(email: String,firstName:String,lastName:String,id:String) {
        UserDefaults.standard.set(email, forKey: "userEmail")
        UserDefaults.standard.set(firstName, forKey: "firstName")
        UserDefaults.standard.set(lastName, forKey: "lastName")
        UserDefaults.standard.set(id, forKey: "id")
    }
    
    func logOut() {
        UserDefaults.standard.removeObject(forKey: "userEmail")
    }
    func updateName(firstName:String,lastName:String){
        UserDefaults.standard.set(firstName, forKey: "firstName")
        UserDefaults.standard.set(lastName, forKey: "lastName")
    }
}



let userDB = FakeDb<UserDetailsType>(name: "usertemp")
let flashCardDb = FakeDb<Flashcard>(name: "flashcardtemp")
let summaryDb = FakeDb<Summary>(name: "summarytemp")
let subjectDb = FakeDb<Subject>(name: "subjecttemp")
let topicsDb = FakeDb<Topics>(name: "topictemp")
let schedulesDb = FakeDb<Schedule>(name: "schedulestemp")
let questionsDb = FakeDb<Questions>(name: "questionstemp")
let scoreDb = FakeDb<Score>(name: "scoretemp")
//struct Card{
//    var title:String
//    var subtitle:String
//    var isCompleted:Bool
//}
