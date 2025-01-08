//
//  CalendarViewController.swift
//  studysphere
//
//  Created by admin64 on 02/01/25.
//

import UIKit

class CalendarViewController: UIViewController {
        let calendar = Calendar.current
        var currentMonth: Date!
        
        override func viewDidLoad() {
            super.viewDidLoad()
            currentMonth = Date()
            setupUI()
        }
        
        func setupUI() {
            // Background color
            view.backgroundColor = UIColor(red: 17/255, green: 18/255, blue: 37/255, alpha: 1)
            
            // Main container view with rounded corners
            let mainContainer = UIView()
            mainContainer.backgroundColor = UIColor(red: 28/255, green: 28/255, blue: 52/255, alpha: 0.3)
            mainContainer.layer.cornerRadius = 20
            mainContainer.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(mainContainer)
            
            // Center the container in the view with padding
            NSLayoutConstraint.activate([
                mainContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                mainContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                mainContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                mainContainer.heightAnchor.constraint(equalToConstant: 400)
            ])
            
            // Month header label
            let monthHeader = UILabel()
            monthHeader.text = formattedMonthYear()
            monthHeader.textColor = .white
            monthHeader.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
            monthHeader.textAlignment = .center
            monthHeader.translatesAutoresizingMaskIntoConstraints = false
            mainContainer.addSubview(monthHeader)
            
            // Weekday labels stack
            let weekdayStack = createWeekdayLabels()
            weekdayStack.translatesAutoresizingMaskIntoConstraints = false
            mainContainer.addSubview(weekdayStack)
            
            // Calendar container
            let calendarContainer = UIView()
            calendarContainer.translatesAutoresizingMaskIntoConstraints = false
            mainContainer.addSubview(calendarContainer)
            
            // Layout constraints
            NSLayoutConstraint.activate([
                monthHeader.topAnchor.constraint(equalTo: mainContainer.topAnchor, constant: 20),
                monthHeader.centerXAnchor.constraint(equalTo: mainContainer.centerXAnchor),
                
                weekdayStack.topAnchor.constraint(equalTo: monthHeader.bottomAnchor, constant: 20),
                weekdayStack.leadingAnchor.constraint(equalTo: mainContainer.leadingAnchor, constant: 20),
                weekdayStack.trailingAnchor.constraint(equalTo: mainContainer.trailingAnchor, constant: -20),
                
                calendarContainer.topAnchor.constraint(equalTo: weekdayStack.bottomAnchor, constant: 10),
                calendarContainer.leadingAnchor.constraint(equalTo: mainContainer.leadingAnchor, constant: 20),
                calendarContainer.trailingAnchor.constraint(equalTo: mainContainer.trailingAnchor, constant: -20),
                calendarContainer.bottomAnchor.constraint(equalTo: mainContainer.bottomAnchor, constant: -20)
            ])
            
            createCalendar(in: calendarContainer)
        }
        
        func createWeekdayLabels() -> UIStackView {
            let stack = UIStackView()
            stack.axis = .horizontal
            stack.distribution = .equalSpacing
            
            let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
            for day in weekdays {
                let label = UILabel()
                label.text = day
                label.textColor = .gray
                label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
                label.textAlignment = .center
                stack.addArrangedSubview(label)
            }
            
            return stack
        }
        
        func createCalendar(in container: UIView) {
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
            let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
            let days = Array(range.lowerBound...range.upperBound - 1)
            let weekday = calendar.component(.weekday, from: startOfMonth)
            
            let cellSize: CGFloat = 35
            let spacing: CGFloat = 8
            let totalColumns = 7
            
            var dayIndex = 0
            for row in 0..<6 {
                for col in 0..<totalColumns {
                    let xOffset = CGFloat(col) * (cellSize + spacing)
                    let yOffset = CGFloat(row) * (cellSize + spacing)
                    
                    let dayCell = createDayCell()
                    dayCell.frame = CGRect(x: xOffset, y: yOffset, width: cellSize, height: cellSize)
                    container.addSubview(dayCell)
                    
                    if row == 0 && col < weekday - 1 || dayIndex >= days.count {
                        dayCell.isHidden = true
                    } else {
                        let dayLabel = dayCell.subviews.compactMap { $0 as? UILabel }.first
                        dayLabel?.text = "\(days[dayIndex])"
                        
                        if isToday(day: days[dayIndex], in: currentMonth) {
                            dayCell.backgroundColor = UIColor.orange.withAlphaComponent(0.3)
                        }
                        
                        // Add streak indicator similar to the image
                        if days[dayIndex] == 2 {
                            dayCell.backgroundColor = UIColor.orange.withAlphaComponent(0.3)
                            let streakIndicator = createStreakIndicator()
                            dayCell.addSubview(streakIndicator)
                            
                            NSLayoutConstraint.activate([
                                streakIndicator.bottomAnchor.constraint(equalTo: dayCell.bottomAnchor, constant: 3),
                                streakIndicator.centerXAnchor.constraint(equalTo: dayCell.centerXAnchor),
                                streakIndicator.widthAnchor.constraint(equalToConstant: 12),
                                streakIndicator.heightAnchor.constraint(equalToConstant: 12)
                            ])
                        }
                        
                        dayIndex += 1
                    }
                }
            }
        }
        
        func createDayCell() -> UIView {
            let view = UIView()
            view.backgroundColor = .clear
            view.layer.cornerRadius = 17.5
            
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            label.textColor = .white
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
            
            return view
        }
        
        func createStreakIndicator() -> UIView {
            let view = UIView()
            view.backgroundColor = .orange
            view.layer.cornerRadius = 6
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }
        
        func isToday(day: Int, in month: Date) -> Bool {
            let components = calendar.dateComponents([.year, .month, .day], from: Date())
            let currentComponents = calendar.dateComponents([.year, .month], from: month)
            return components.year == currentComponents.year && components.month == currentComponents.month && components.day == day
        }
        
        func formattedMonthYear() -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: currentMonth)
        }
    }
