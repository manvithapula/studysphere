//
//  ScheduleViewController.swift
//  studysphere
//
//  Created by admin64 on 03/01/25.
//

import UIKit

class ScheduleViewController: UIViewController {
    
        // MARK: - Outlets
        @IBOutlet weak var mainStackView: UIStackView!
        @IBOutlet weak var dateStackView: UIStackView!
        @IBOutlet weak var tableView: UITableView!
        
    // MARK: - Properties
       private var dateViews: [UIView] = []
       private var dateLabels: [UILabel] = []
       private var dayLabels: [UILabel] = []
       
       private var scheduleItems: [ScheduleItem] = [
           ScheduleItem(iconName: "book.fill",
                       title: "Introduction to Swift",
                       subtitle: "2 chapters remaining",
                       progress: 0.7),
           ScheduleItem(iconName: "pencil",
                       title: "UI Design Basics",
                       subtitle: "1 chapter remaining",
                       progress: 0.3)
       ]
       
       private let numberOfDaysToShow = 5
       private let calendar = Calendar.current
       private var selectedDate: Date = Date()
       
       // MARK: - Lifecycle
       override func viewDidLoad() {
           super.viewDidLoad()
           setupUI()
           setupTableView()
           setupDateViews()
       }
       
       // MARK: - Setup
       private func setupUI() {
           view.backgroundColor = .systemBackground
           
           // Configure date stack view
           dateStackView.axis = .horizontal
           dateStackView.distribution = .fillEqually
           dateStackView.spacing = 8
           dateStackView.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
           dateStackView.isLayoutMarginsRelativeArrangement = true
           
           // Configure table view
           tableView.backgroundColor = .clear
       }
       
       private func setupTableView() {
           tableView.delegate = self
           tableView.dataSource = self
           tableView.register(ScheduleTableViewCell.self, forCellReuseIdentifier: "ScheduleTableViewCell")
           tableView.separatorStyle = .none
           tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
       }
       
       private func setupDateViews() {
           let today = Date()
           dateStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
           dateViews.removeAll()
           dateLabels.removeAll()
           dayLabels.removeAll()
           
           for i in 0..<numberOfDaysToShow {
               if let date = calendar.date(byAdding: .day, value: i, to: today) {
                   let dateView = createDateView(for: date)
                   dateStackView.addArrangedSubview(dateView)
                   
                   let tapGesture = UITapGestureRecognizer(target: self,
                                                          action: #selector(dateViewTapped(_:)))
                   dateView.addGestureRecognizer(tapGesture)
                   dateView.tag = i
               }
           }
           
           updateSelectedDateView(index: 0)
       }
       
       private func createDateView(for date: Date) -> UIView {
           let container = UIView()
           container.translatesAutoresizingMaskIntoConstraints = false
           container.backgroundColor = .systemBackground
           container.layer.cornerRadius = 8
           container.clipsToBounds = true
           container.isUserInteractionEnabled = true
           
           // Create labels
           let monthLabel = createLabel(text: date.monthString(), size: 13, weight: .regular)
           let dateLabel = createLabel(text: String(calendar.component(.day, from: date)), size: 16, weight: .semibold)
           let dayLabel = createLabel(text: date.dayOfWeekString(), size: 13, weight: .regular)
           
           // Create and configure stack view
           let stack = UIStackView(arrangedSubviews: [monthLabel, dateLabel, dayLabel])
           stack.translatesAutoresizingMaskIntoConstraints = false
           stack.axis = .vertical
           stack.alignment = .center
           stack.spacing = 0
           
           container.addSubview(stack)
           
           NSLayoutConstraint.activate([
               container.heightAnchor.constraint(equalToConstant: 80),
               container.widthAnchor.constraint(equalToConstant: 68),
               stack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
               stack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
               stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 4),
               stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -4)
           ])
           
           dateViews.append(container)
           dateLabels.append(dateLabel)
           dayLabels.append(dayLabel)
           
           return container
       }
       
       private func createLabel(text: String, size: CGFloat, weight: UIFont.Weight) -> UILabel {
           let label = UILabel()
           label.translatesAutoresizingMaskIntoConstraints = false
           label.font = .systemFont(ofSize: size, weight: weight)
           label.text = text
           label.textAlignment = .center
           return label
       }
       
       // MARK: - Actions
       @objc private func dateViewTapped(_ gesture: UITapGestureRecognizer) {
           guard let index = gesture.view?.tag else { return }
           updateSelectedDateView(index: index)
           loadScheduleItems()
       }
       
       private func updateSelectedDateView(index: Int) {
           dateViews.forEach { view in
               view.backgroundColor = .systemBackground
               if let stack = view.subviews.first as? UIStackView {
                   stack.arrangedSubviews.forEach { label in
                       if let label = label as? UILabel {
                           label.textColor = .label
                       }
                   }
               }
           }
           
           let selectedView = dateViews[index]
           selectedView.backgroundColor = .systemIndigo
           if let stack = selectedView.subviews.first as? UIStackView {
               stack.arrangedSubviews.forEach { label in
                   if let label = label as? UILabel {
                       label.textColor = .white
                   }
               }
           }
           
           if let date = calendar.date(byAdding: .day, value: index, to: Date()) {
               selectedDate = date
           }
       }
       
       private func loadScheduleItems() {
           tableView.reloadData()
       }
   }

   // MARK: - UITableView DataSource & Delegate
   extension ScheduleViewController: UITableViewDelegate, UITableViewDataSource {
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return scheduleItems.count
       }
       
       func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           return 80
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           guard let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleTableViewCell",
                                                         for: indexPath) as? ScheduleTableViewCell else {
               return UITableViewCell()
           }
           
           let item = scheduleItems[indexPath.row]
           cell.configure(with: item)
           return cell
       }
   }

   // MARK: - Date Extension
   extension Date {
       func dayOfWeekString() -> String {
           let formatter = DateFormatter()
           formatter.dateFormat = "EEE"
           return formatter.string(from: self)
       }
       
       func monthString() -> String {
           let formatter = DateFormatter()
           formatter.dateFormat = "MMM"
           return formatter.string(from: self)
       }
   }
