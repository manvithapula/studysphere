//
//  dataType.swift
//  studysphere
//
//  Created by dark on 29/10/24.
//

import Foundation
//struct Card{
//    var title:String
//    var subtitle:String
//    var isCompleted:Bool
//}

protocol Identifiable {
    var id: String { get set }
}
struct ProgressType{
    var completed:Int
    var total:Int
    var progress:Double{
        Double(completed)/Double(total)
    }
}
struct UserDetailsType:Codable,Identifiable{
    var id:String
    var firstName:String
    var lastName:String
    var dob:Date
    var pushNotificationEnabled:Bool
    var faceIdEnabled:Bool
    var email:String
    var password:String
    
    static var ArchiveURL: URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentDirectory.appendingPathComponent("user.plist")
        return archiveURL
    }
    
    static func saveData(user: UserDetailsType){
        let plistEncoder = PropertyListEncoder()
        let data = try? plistEncoder.encode(user)
        try? data?.write(to: ArchiveURL)
    }
    
    static func loadData()->UserDetailsType{
        let plistDecoder = PropertyListDecoder()
        guard let data = try? Data(contentsOf: ArchiveURL) else { return user }
        return try! plistDecoder.decode(UserDetailsType.self, from: data)
    }
}
var user = UserDetailsType(id: "1", firstName: "Anwin", lastName: "Sharon", dob: date!, pushNotificationEnabled: false, faceIdEnabled: true,email: "test@test.com",password: "password")


struct Flashcard:Codable,Identifiable {
    var id:String
    var question: String
    var answer: String
    var topic:String
}

struct Summary:Codable,Identifiable{
    var id:String
    var topic:String
    var data:String
}

struct Schedule:Codable,Identifiable{
    var id:String
    var title:String
    var date:Date
    var time:String
    var completed:Bool
    var topic:String
}
struct Subject:Codable,Identifiable{
    var id:String
    let name:String
}
struct Topics:Codable,Identifiable {
    var id:String
    var title:String
    var subject:String
    var type:TopicsType
    var completed:Bool
    var subtitle:String
}
enum TopicsType: String, Codable {
    case flashcards = "flashcards"
    case quizzes = "quizzes"
    case summary = "summary"
}

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
}
struct UserProfile {
    let name: String
    let profilePictureURL: URL?
    let motivationalMessage: String
}

// Streak Model
struct StreakDay {
    let dayOfWeek: String
    let isCompleted: Bool
}

// Today’s Schedule Model
struct ScheduleItem {
    let title: String
    let progress: Float
}



// Study Technique Model
struct StudyTechnique {
    let name: String
    let completedSessions: Int
    let totalSessions: Int
}

struct DashboardData {
    let userProfile: UserProfile
    let streak: [StreakDay]
    let todaySchedule: [ScheduleItem]
    let subjects: [Subject]
    let studyTechniques: [StudyTechnique]
}
let streakValues = [
    false,
    false,
    true,
    true,
    true,
    true,
    true
]

var ARQuestions : [Questions] = [
    Questions(id: "", questionLabel: "1", question: "Who will win election in india ?", correctanswer: "Narendra Modi", option1: "Narendra Modi", option2: "Rahul Gandhi", option3: "Kejrival ", option4: "Umman Chandi", topic: ""),
    Questions(id: "", questionLabel: "2", question: "Where was the first General Indian Post", correctanswer: "Mumbai", option1: "Kolkata", option2: "Mumbai", option3: "Delhi", option4: "Chennai", topic: "")
]

var flashcards1: [Flashcard] = [
    Flashcard(id: "", question: "What is the capital of France?", answer: "Paris",topic: ""),
    Flashcard(id: "", question: "What is the capital of Germany?", answer: "Berlin",topic: ""),
    Flashcard(id: "", question: "What is the capital of Italy?", answer: "Rome",topic: ""),
    Flashcard(id: "", question: "What is the capital of Spain?", answer: "Madrid",topic: ""),
    Flashcard(id: "", question: "What is the capital of Sweden?", answer: "Stockholm",topic: ""),
    Flashcard(id: "", question: "What is the capital of Norway?", answer: "Oslo",topic: ""),
    Flashcard(id: "", question: "What is the capital of Finland?", answer: "Helsinki",topic: ""),
]
var flc : [Flashcard] = [
    Flashcard(id: "", question: "What is the capital of France?", answer: "Paris",topic: ""),
    Flashcard(id: "", question: "What is the capital of Germany?", answer: "Berlin",topic: ""),
    Flashcard(id: "", question: "What is the capital of Italy?", answer: "Rome",topic: ""),
    Flashcard(id: "", question: "What is the capital of Spain?", answer: "Madrid",topic: ""),
    Flashcard(id: "", question: "What is the capital of Sweden?", answer: "Stockholm",topic: ""),
    Flashcard(id: "", question: "What is the capital of Norway?", answer: "Oslo",topic: ""),
    Flashcard(id: "", question: "What is the capital of Finland?", answer: "Helsinki",topic: ""),
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

var schedules:[Schedule] = spacedRepetitionSchedule(startDate: formatDateFromString(date: "23 Sep 2024")!, title: "Swift fundamentals ",topic: "Swift")

import Foundation

func spacedRepetitionSchedule(startDate: Date,title:String,topic:String) -> [Schedule] {
    let intervals = [0, 1, 3, 7, 14, 30]
    let calendar = Calendar.current
    let schedule = intervals.map { interval in
        let date = calendar.date(byAdding: .day, value: interval, to: startDate)!
        return Schedule(id:"",title: title, date: date, time: "10:00 AM", completed: false,topic: topic)
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
    private var ArchiveURL: URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentDirectory.appendingPathComponent("\(self.name).plist")
        return archiveURL
    }
    private var items: [T]
    init(name: String) {
        self.name = name
        self.items = []
        if let loadedItems = self.loadData() {
            self.items = loadedItems
        }
    }
    
    public func create(_ item: inout T) -> T{
        item.id = UUID().uuidString
        items.append(item)
        saveData()
        return item
    }
    
    public func findAll(where conditions: [String: Any]? = nil) -> [T] {
        // If no conditions provided, return all items
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
            
            // Check if all conditions match
            return conditions.allSatisfy { key, value in
                if let itemValue = itemDict[key] {
                    return String(describing: itemValue) == String(describing: value)
                }
                return false
            }
        }
    }
    
    public func update(_ item: T) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
            saveData()
        }
    }
    
    public func delete(id: String) {
        items.removeAll { $0.id == id }
        saveData()
    }
    
    private func loadData() -> [T]? {
        let plistDecoder = PropertyListDecoder()
        guard let data = try? Data(contentsOf: ArchiveURL) else {
            return nil
        }
        do {
            return try plistDecoder.decode([T].self, from: data)
        } catch {
            print("Error decoding data: \(error)")
            return nil
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
    
    func logIn(email: String) {
        UserDefaults.standard.set(email, forKey: "userEmail")
    }
    
    func logOut() {
        UserDefaults.standard.removeObject(forKey: "userEmail")
    }
}



let userDB = FakeDb<UserDetailsType>(name: "usertemp")
let flashCardDb = FakeDb<Flashcard>(name: "flashcardtemp")
let summaryDb = FakeDb<Summary>(name: "summarytemp")
let subjectDb = FakeDb<Subject>(name: "subjecttemp")
let topicsDb = FakeDb<Topics>(name: "topictemp")
let schedulesDb = FakeDb<Schedule>(name: "schedulestemp")
let questionsDb = FakeDb<Questions>(name: "questionstemp")


