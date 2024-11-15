//
//  homeScreenModel.swift
//  studysphere
//
//  Created by admin64 on 04/11/24.
//




import Foundation

// User Profile Model
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

// Subject Model
struct Subject: Codable {
    var name: String
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

//subject detail page
struct Card{
    var title:String
    var subtitle:String
    var isCompleted:Bool
}

var cards:[Card]=[
    Card(title:"English Literature",subtitle:"1 more to go",isCompleted: false),
    Card(title: "Maths Literature", subtitle: "1 more to go",isCompleted: false),
    Card(title: "Chemistry Literature", subtitle: "1 more to go",isCompleted: false),
    Card(title: "Biology Literature", subtitle: "1 more to go",isCompleted: false),
    Card(title: "Biology Literature", subtitle: "1 more to go",isCompleted: true),

]
