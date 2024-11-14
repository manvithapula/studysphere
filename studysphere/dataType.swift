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
struct ProgressType{
    var completed:Int
    var total:Int
    var progress:Double{
        Double(completed)/Double(total)
    }
}
struct UserDetailsType:Codable{
    var firstName:String
    var lastName:String
    var dob:Date
    var pushNotificationEnabled:Bool
    var faceIdEnabled:Bool
    
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
var user = UserDetailsType(firstName: "Anwin", lastName: "Sharon", dob: date!, pushNotificationEnabled: false, faceIdEnabled: true)


struct Flashcard {
    let question: String
    let answer: String
}
struct Schedule{
    var title:String
    var date:Date
    var time:String
    var completed:Bool
}

var flashcards1: [Flashcard] = [
    Flashcard(question: "What is the capital of France?", answer: "Paris"),
    Flashcard(question: "What is the capital of Germany?", answer: "Berlin"),
    Flashcard(question: "What is the capital of Italy?", answer: "Rome"),
    Flashcard(question: "What is the capital of Spain?", answer: "Madrid"),
    Flashcard(question: "What is the capital of Sweden?", answer: "Stockholm"),
    Flashcard(question: "What is the capital of Norway?", answer: "Oslo"),
    Flashcard(question: "What is the capital of Finland?", answer: "Helsinki"),
]
var flc : [Flashcard] = [
    Flashcard(question: "What is the capital of test?", answer: "Paris"),
    Flashcard(question: "What is the capital of Germany?", answer: "Berlin"),
    Flashcard(question: "What is the capital of Italy?", answer: "Rome"),
    Flashcard(question: "What is the capital of Spain?", answer: "Madrid"),
    Flashcard(question: "What is the capital of Sweden?", answer: "Stockholm"),
    Flashcard(question: "What is the capital of Norway?", answer: "Oslo"),
    Flashcard(question: "What is the capital of Finland?", answer: "Helsinki"),
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

var schedules:[Schedule]=[
    Schedule(title: "Swift fundamentals ", date: formatDateFromString(date: "23 Sep 2024")!, time: "10:00 AM", completed: true),
    Schedule(title: "Swift fundamentals ", date: formatDateFromString(date: "23 Sep 2024")!, time: "10:00 AM", completed: true),
    Schedule(title: "Swift fundamentals ", date: formatDateFromString(date: "23 Sep 2024")!, time: "10:00 AM", completed: true),
    Schedule(title: "Swift fundamentals ", date: formatDateFromString(date: "23 Sep 2024")!, time: "10:00 AM", completed: true),
    Schedule(title: "Swift fundamentals ", date: formatDateFromString(date: "23 Sep 2024")!, time: "10:00 AM", completed: true),
    Schedule(title: "Swift fundamentals ", date: formatDateFromString(date: "23 Sep 2024")!, time: "10:00 AM", completed: false),
    Schedule(title: "Swift fundamentals ", date: formatDateFromString(date: "23 Sep 2024")!, time: "10:00 AM", completed: false),
]




//var cards:[Card]=[
//    Card(title:"English Literature",subtitle:"1 more to go",isCompleted: false),
//    Card(title: "Maths Literature", subtitle: "1 more to go",isCompleted: false),
//    Card(title: "Chemistry Literature", subtitle: "1 more to go",isCompleted: false),
//    Card(title: "Biology Literature", subtitle: "1 more to go",isCompleted: false),
//    Card(title: "Biology Literature", subtitle: "1 more to go",isCompleted: true),
//
//]


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
