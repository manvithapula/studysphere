//
//  subjectListTableViewCell.swift
//  studysphere
//
//  Created by admin64 on 05/11/24.
//

import UIKit

class subjectListTableViewCell: UITableViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowRadius = 8
        view.layer.shadowOffset = CGSize(width: 0, height: 3)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Card background with gradient
    private let cardBackground: GradientView = {
        let view = GradientView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    // Icon container with animated gradient
    private let iconContainer: GradientView = {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        return view
    }()
    
    // Icon image view
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // Subject title label
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .darkText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
  
    // Topics count label
    private let topicsCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = AppTheme.primary.withAlphaComponent(0.8)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
  
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }
    
    // MARK: - Setup
    
    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(cardBackground)
        cardBackground.addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        cardBackground.addSubview(titleLabel)
        cardBackground.addSubview(topicsCountLabel)
        
        NSLayoutConstraint.activate([
            // Container view constraints
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 110),
            
            // Card background constraints
            cardBackground.topAnchor.constraint(equalTo: containerView.topAnchor),
            cardBackground.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            cardBackground.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            cardBackground.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            
            // Icon container constraints
            iconContainer.leadingAnchor.constraint(equalTo: cardBackground.leadingAnchor, constant: 16),
            iconContainer.centerYAnchor.constraint(equalTo: cardBackground.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 48),
            iconContainer.heightAnchor.constraint(equalToConstant: 48),
            
            // Icon image view constraints
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // Title label constraints
            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: cardBackground.topAnchor, constant: 10),
           
         
            // Topics count label constraints
            topicsCountLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            topicsCountLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            topicsCountLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardBackground.bottomAnchor, constant: -16)])
            
    }
    
    // MARK: - Configuration
    
    func configure(with subject: Subject, index: Int) {
        titleLabel.text = subject.name
        
        // Generate random topic count for demo
        let topicsCount = Int.random(in: 1...20)
        topicsCountLabel.text = "\(topicsCount) modules"
        
        // Set up the icon based on subject
        setupIcon(for: subject.name, at: index)
        
        // Set up colors based on index
        setupColors(for: index)
    }
    
    // MARK: - Subject Icon Management

    // Create an enum for subject categories with associated icons
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
                return "text.book.closed.fill"
            case .history:
                return "clock.fill"
            case .art:
                return "paintbrush.fill"
            case .music:
                return "music.note"
            case .languages:
                return "character.bubble.fill"
            case .business:
                return "briefcase.fill"
            case .engineering:
                return "gear"
            case .psychology:
                return "brain.head.profile"
            case .philosophy:
                return "lightbulb.fill"
            case .physicalEducation:
                return "figure.run"
            case .socialStudies:
                return "person.3.fill"
                
            // More specialized subjects
            case .biology:
                return "leaf.fill"
            case .chemistry:
                return "flask.fill"
            case .physics:
                return "atom"
            case .economics:
                return "chart.line.uptrend.xyaxis"
            case .law:
                return "scale.3d"
            case .medicine:
                return "heart.fill"
            case .geography:
                return "globe"
            case .astronomy:
                return "moon.stars.fill"
            case .statistics:
                return "chart.bar.fill"
                
            // Default
            case .other:
                return "book.fill"
            }
        }
    }

    // SubjectIconService class for managing subject icons
    class SubjectIconService {
        // Dictionary mapping keywords to categories
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
            "design": .art,
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

    // MARK: - Usage in Cell

    private func setupIcon(for subjectName: String, at index: Int) {
        let iconService = SubjectIconService()
        let result = iconService.getIconAndCategory(for: subjectName)
        
        // Set the icon
        let iconName = result.iconName
        iconImageView.image = UIImage(systemName: iconName)
        
        // Optionally, you could add category to the UI if desired
        // categoryLabel.text = result.category.rawValue
        
        // You could also adjust colors based on category if desired
        // adjustColorsBasedOnCategory(result.category)
    }
    
    private func setupColors(for index: Int) {
        // Create a color scheme based on index using only AppTheme.primary and AppTheme.secondary
        let colorSchemes: [(start: UIColor, end: UIColor, pattern: UIColor)] = [
            (AppTheme.primary.withAlphaComponent(0.15), AppTheme.primary.withAlphaComponent(0.05), AppTheme.primary.withAlphaComponent(0.1)),
            (AppTheme.secondary.withAlphaComponent(0.15), AppTheme.secondary.withAlphaComponent(0.05), AppTheme.secondary.withAlphaComponent(0.1))
        ]
        
        let iconColorSchemes: [(start: UIColor, end: UIColor)] = [
            (AppTheme.primary, AppTheme.primary.adjustBrightness(by: 0.2)),
            (AppTheme.secondary, AppTheme.secondary.adjustBrightness(by: 0.2))
        ]
        
        let colorIndex = index % colorSchemes.count
        let colors = colorSchemes[colorIndex]
        let iconColors = iconColorSchemes[colorIndex]
        
        // Set card background gradient
        cardBackground.setGradient(startColor: colors.start,
                                  endColor: colors.end,
                                  startPoint: CGPoint(x: 0.0, y: 0.0),
                                  endPoint: CGPoint(x: 1.0, y: 1.0))
        
        // Set icon container gradient
        iconContainer.setGradient(startColor: iconColors.start,
                                 endColor: iconColors.end,
                                 startPoint: CGPoint(x: 0.0, y: 0.0),
                                 endPoint: CGPoint(x: 1.0, y: 1.0))
        
        // Set topics count label color
        topicsCountLabel.textColor = iconColors.start.withAlphaComponent(0.8)
    }
    
    // MARK: - Interaction
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.2) {
            self.containerView.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            self.containerView.layer.shadowOpacity = highlighted ? 0.12 : 0.08
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        topicsCountLabel.text = nil
        iconImageView.image = UIImage(systemName: "book.fill")
        // Reset any other properties that need resetting
    }
}

// MARK: - Helper Classes

class GradientView: UIView {
    private var gradientLayer: CAGradientLayer?
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    func setGradient(startColor: UIColor, endColor: UIColor, startPoint: CGPoint, endPoint: CGPoint) {
        let gradientLayer = self.layer as? CAGradientLayer
        gradientLayer?.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer?.startPoint = startPoint
        gradientLayer?.endPoint = endPoint
        self.gradientLayer = gradientLayer
    }
}

// MARK: - Extensions

extension UIColor {
    func adjustBrightness(by percentage: CGFloat) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: s, brightness: b * (1 + percentage), alpha: a)
    }
}
