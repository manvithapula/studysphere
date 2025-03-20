//
//  SubjectIconService.swift
//  studysphere
//
//  Created by dark on 18/03/25.
//

import Foundation
class SubjectIconService {
    // Dictionary mapping keywords to categories
    static let shared = SubjectIconService()
    
    private let categoryMapping: [String: SubjectCategory] = [
        // Mathematics
        "math": .mathematics,
        "algebra": .mathematics,
        "calculus": .mathematics,
        "geometry": .mathematics,
        "trigonometry": .mathematics,
        
        // Statistics
        "statistics": .statistics,
        "probability": .statistics,
        "data analysis": .statistics,
        
        // Science
        "science": .science,
        
        // Biology
        "biology": .biology,
        "botany": .biology,
        "zoology": .biology,
        "ecology": .biology,
        "genetics": .biology,
        
        // Chemistry
        "chemistry": .chemistry,
        "biochemistry": .chemistry,
        "organic chemistry": .chemistry,
        
        // Physics
        "physics": .physics,
        "mechanics": .physics,
        "electromagnetics": .physics,
        "quantum": .physics,
        "thermodynamics": .physics,
        
        // Computer Science
        "computer": .computerScience,
        "programming": .computerScience,
        "coding": .computerScience,
        "compiler design" : .computerScience,
        "algorithm": .computerScience,
        "data structure": .computerScience,
        "software": .computerScience,
        "hardware": .computerScience,
        "artificial intelligence": .computerScience,
        "machine learning": .computerScience,
        "database": .computerScience,
        "network": .computerScience,
        "web": .computerScience,
        "app": .computerScience,
        "mobile": .computerScience,
        
        // Literature
        "literature": .literature,
        "english": .literature,
        "poetry": .literature,
        "fiction": .literature,
        "novel": .literature,
        "reading": .literature,
        "writing": .literature,
        
        // History
        "history": .history,
        "ancient": .history,
        "medieval": .history,
        "modern": .history,
        "world war": .history,
        "civilization": .history,
        "revolution": .history,
        "archaeology": .history,
        
        // Art
        "art": .art,
        "drawing": .art,
        "painting": .art,
        "sculpture": .art,
        "graphic design": .art,
        "photography": .art,
        
        // Music
        "music": .music,
        "instrument": .music,
        "guitar": .music,
        "piano": .music,
        "violin": .music,
        "theory": .music,
        "composition": .music,
        
        // Languages
        "language": .languages,
        "spanish": .languages,
        "french": .languages,
        "german": .languages,
        "italian": .languages,
        "chinese": .languages,
        "japanese": .languages,
        "linguistics": .languages,
        "grammar": .languages,
        "speech": .languages,
        
        // Business
        "business": .business,
        "marketing": .business,
        "management": .business,
        "accounting": .business,
        "finance": .business,
        "entrepreneurship": .business,
        
        // Economics
        "economics": .economics,
        "macro": .economics,
        "micro": .economics,
        "market": .economics,
        
        // Engineering
        "engineering": .engineering,
        "mechanical": .engineering,
        "electrical": .engineering,
        "civil": .engineering,
        "chemical": .engineering,
        "aerospace": .engineering,
        "robotics": .engineering,
        
        // Law
        "law": .law,
        "legal": .law,
        "criminal justice": .law,
        "constitutional": .law,
        
        // Medicine
        "medicine": .medicine,
        "health": .medicine,
        "anatomy": .medicine,
        "physiology": .medicine,
        "nursing": .medicine,
        "pharmacy": .medicine,
        
        // Psychology
        "psychology": .psychology,
        "cognitive": .psychology,
        "behavioral": .psychology,
        "mental": .psychology,
        "social psychology": .psychology,
        
        // Philosophy
        "philosophy": .philosophy,
        "ethics": .philosophy,
        "logic": .philosophy,
        "metaphysics": .philosophy,
        
        // Physical Education
        "physical education": .physicalEducation,
        "fitness": .physicalEducation,
        "sport": .physicalEducation,
        "exercise": .physicalEducation,
        "health education": .physicalEducation,
        
        // Geography
        "geography": .geography,
        "cartography": .geography,
        "gis": .geography,
        "earth": .geography,
        
        // Astronomy
        "astronomy": .astronomy,
        "cosmos": .astronomy,
        "space": .astronomy,
        "planetary": .astronomy,
        "astrophysics": .astronomy,
        
        // Social Studies
        "social studies": .socialStudies,
        "sociology": .socialStudies,
        "anthropology": .socialStudies,
        "political science": .socialStudies,
        "government": .socialStudies,
        "civics": .socialStudies
    ]
    
    // Get the appropriate category for a subject name
    func getCategory(for subjectName: String) -> SubjectCategory {
        let lowercasedName = subjectName.lowercased()
        
        // Check against our keyword mapping
        for (keyword, category) in categoryMapping {
            if lowercasedName.contains(keyword) {
                return category
            }
        }
        
        // Return default if no match is found
        return .other
    }
    
    // Get the icon name for a subject
    func getIconName(for subjectName: String) -> String {
        return getCategory(for: subjectName).iconName
    }
    
    // Get both the icon name and the detected category
    func getIconAndCategory(for subjectName: String) -> (iconName: String, category: SubjectCategory) {
        let category = getCategory(for: subjectName)
        return (category.iconName, category)
    }
}
enum SubjectCategory: String, CaseIterable {
    // Core academic subjects
    case mathematics = "Mathematics"
    case science = "Science"
    case computerScience = "Computer Science"
    case literature = "Literature"
    case history = "History"
    case art = "Art"
    case music = "Music"
    case languages = "Languages"
    case business = "Business"
    case engineering = "Engineering"
    case psychology = "Psychology"
    case philosophy = "Philosophy"
    case physicalEducation = "Physical Education"
    case socialStudies = "Social Studies"
    
    // More specialized subjects
    case biology = "Biology"
    case chemistry = "Chemistry"
    case physics = "Physics"
    case economics = "Economics"
    case law = "Law"
    case medicine = "Medicine"
    case geography = "Geography"
    case astronomy = "Astronomy"
    case statistics = "Statistics"
    
    // Default category
    case other = "Other"
    
    // Get the appropriate SF Symbol for each category
    var iconName: String {
        switch self {
        // Core academic subjects
        case .mathematics:
            return "function"
        case .science:
            return "atom"
        case .computerScience:
            return "desktopcomputer"
        case .literature:
            return "text.book.closed"
        case .history:
            return "clock"
        case .art:
            return "paintbrush"
        case .music:
            return "music.note"
        case .languages:
            return "character.bubble"
        case .business:
            return "briefcase"
        case .engineering:
            return "gear"
        case .psychology:
            return "brain.head.profile"
        case .philosophy:
            return "lightbulb"
        case .physicalEducation:
            return "figure.run"
        case .socialStudies:
            return "person.3"
            
        // More specialized subjects
        case .biology:
            return "leaf"
        case .chemistry:
            return "flask"
        case .physics:
            return "atom"
        case .economics:
            return "chart.line.uptrend.xyaxis"
        case .law:
            return "scale.3d"
        case .medicine:
            return "heart"
        case .geography:
            return "globe"
        case .astronomy:
            return "moon.stars"
        case .statistics:
            return "chart.bar"
            
        // Default
        case .other:
            return "book"
        }
    }
}
