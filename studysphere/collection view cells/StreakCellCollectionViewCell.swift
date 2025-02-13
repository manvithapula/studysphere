//
//  StreakCellCollectionViewCell.swift
//  studysphere
//
//  Created by admin64 on 02/01/25.
//

import UIKit

class StreakCellCollectionViewCell: UICollectionViewCell {
        // MARK: - IBOutlets
        @IBOutlet weak var cardView: UIView!
        @IBOutlet weak var streakTitleLabel: UILabel!
        @IBOutlet weak var streakImageView: UIImageView!
        @IBOutlet weak var subtitleLabel: UILabel!
        @IBOutlet weak var weekdayStackView: UIStackView!
        @IBOutlet weak var weekStackView: UIStackView!
        
    
      // MARK: - Properties
      private var dateLabels: [UILabel] = []
      private var weekdayLabels: [UILabel] = []
      
      override func awakeFromNib() {
          super.awakeFromNib()
          setupUI()
          setupConstraints()
          setupWeekdayLabels()
          setupDateLabels()
          setupStackViewConstraints()
          updateWeekView(withStreakDays: 0, startDate: Date())
      }
      
      private func setupUI() {
          cardView.layer.cornerRadius = 16
          cardView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0)
          
          streakTitleLabel.textColor = .white
          streakTitleLabel.font = .systemFont(ofSize: 24, weight: .bold)
          streakTitleLabel.textAlignment = .center
          
          streakImageView.tintColor = .orange
          streakImageView.contentMode = .scaleAspectFit
          
          subtitleLabel.textColor = .white
          subtitleLabel.font = .systemFont(ofSize: 16)
          subtitleLabel.textAlignment = .center
          subtitleLabel.numberOfLines = 0
      }
      
      private func setupConstraints() {
          // Remove existing constraints from storyboard
          streakTitleLabel.removeFromSuperview()
          streakImageView.removeFromSuperview()
          subtitleLabel.removeFromSuperview()
          
          // Add views back to the card
          cardView.addSubview(streakTitleLabel)
          cardView.addSubview(streakImageView)
          cardView.addSubview(subtitleLabel)
          
          // Enable auto layout
          streakTitleLabel.translatesAutoresizingMaskIntoConstraints = false
          streakImageView.translatesAutoresizingMaskIntoConstraints = false
          subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
          
          NSLayoutConstraint.activate([
              // Streak Title Label
              streakTitleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 24),
              streakTitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
              streakTitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
              
              // Streak Image View
              streakImageView.topAnchor.constraint(equalTo: streakTitleLabel.bottomAnchor, constant: 16),
              streakImageView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
              streakImageView.widthAnchor.constraint(equalToConstant: 60),
              streakImageView.heightAnchor.constraint(equalToConstant: 60),
              
              // Subtitle Label
              subtitleLabel.topAnchor.constraint(equalTo: streakImageView.bottomAnchor, constant: 16),
              subtitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
              subtitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16)
          ])
      }
      
      private func setupWeekdayLabels() {
          let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
          for weekday in weekdays {
              let label = UILabel()
              label.text = weekday
              label.textColor = .white
              label.textAlignment = .center
              label.font = .systemFont(ofSize: 14)
              weekdayLabels.append(label)
              weekdayStackView.addArrangedSubview(label)
          }
      }
      
      private func setupDateLabels() {
          for _ in 0..<7 {
              let label = UILabel()
              label.textColor = .white
              label.textAlignment = .center
              label.font = .systemFont(ofSize: 14)
              dateLabels.append(label)
              weekStackView.addArrangedSubview(label)
          }
      }
      
      private func setupStackViewConstraints() {
          // Remove any existing constraints from storyboard
          weekdayStackView.removeFromSuperview()
          weekStackView.removeFromSuperview()
          
          // Add stack views back to the card view
          cardView.addSubview(weekdayStackView)
          cardView.addSubview(weekStackView)
          
          // Enable auto layout
          weekdayStackView.translatesAutoresizingMaskIntoConstraints = false
          weekStackView.translatesAutoresizingMaskIntoConstraints = false
          
          // Configure stack view properties
          weekdayStackView.axis = .horizontal
          weekdayStackView.distribution = .fillEqually
          weekdayStackView.spacing = 8
          weekdayStackView.alignment = .center
          
          weekStackView.axis = .horizontal
          weekStackView.distribution = .fillEqually
          weekStackView.spacing = 8
          weekStackView.alignment = .center
          
          NSLayoutConstraint.activate([
              // Weekday Stack View Constraints
              weekdayStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
              weekdayStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
              weekdayStackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
              weekdayStackView.heightAnchor.constraint(equalToConstant: 20),
              
              // Week Stack View Constraints
              weekStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
              weekStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
              weekStackView.topAnchor.constraint(equalTo: weekdayStackView.bottomAnchor, constant: 8),
              weekStackView.heightAnchor.constraint(equalToConstant: 30),
              weekStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20)
          ])
          
          // Configure date labels for better appearance
          dateLabels.forEach { label in
              label.widthAnchor.constraint(equalToConstant: 30).isActive = true
              label.heightAnchor.constraint(equalToConstant: 30).isActive = true
              label.layer.cornerRadius = 15
              label.clipsToBounds = true
              label.textAlignment = .center
          }
      }
      
      private func calculateStreakDays(from startDate: Date) -> Int {
          let calendar = Calendar.current
          let now = Date()
          let components = calendar.dateComponents([.day], from: startDate, to: now)
          return components.day ?? 0
      }
      
      private func updateWeekView(withStreakDays streakDays: Int, startDate: Date) {
          let today = Date()
          let calendar = Calendar.current
          
          // Find the start of the week (Sunday)
          var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
          let startOfWeek = calendar.date(from: components)!
          
          // Update date labels
          for (index, label) in dateLabels.enumerated() {
              if let date = calendar.date(byAdding: .day, value: index, to: startOfWeek) {
                  let dayNumber = calendar.component(.day, from: date)
                  label.text = "\(dayNumber)"
                  
                  // Check if this date falls within the streak period
                  let isInStreak = calendar.dateComponents([.day], from: startDate, to: date).day ?? 0 >= 0 &&
                                  calendar.dateComponents([.day], from: date, to: today).day ?? 0 >= 0
                  
                  if calendar.isDate(date, inSameDayAs: today) {
                      label.backgroundColor = .orange
                  } else if isInStreak {
                      label.backgroundColor = UIColor.white.withAlphaComponent(0.2)
                  } else {
                      label.backgroundColor = nil
                  }
                  
                  label.layer.cornerRadius = 15
                  label.clipsToBounds = true
              }
          }
      }
      
      func configure(with startDate: Date) {
          StreakManager.shared.updateStreak()
          let streakDays = StreakManager.shared.currentStreak
          var streakStartDate: Date = Calendar.current.date(byAdding: .day, value: -streakDays, to: Date())!
          streakTitleLabel.text = "\(streakDays)-day streak"
          subtitleLabel.text = "Study next week to keep your streak going!"
          updateWeekView(withStreakDays: streakDays, startDate: streakStartDate)
      }
  }

   
