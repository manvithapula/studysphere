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
        private var gradientLayer = CAGradientLayer()
        
        private var schedules: [Schedule] = []
        private var offset = 0
        
        var filterSchedules: [Schedule] {
            let date = calendar.date(byAdding: .day, value: offset, to: Date())
            let today = formatDateToString(date: date!)
            return schedules.filter { schedule in
                let date = formatDateToString(date: schedule.date.dateValue())
                return date == today
            }
        }
        
        private var scheduleItems: [ScheduleItem] {
            var temp: [ScheduleItem] = []
            for schedule in filterSchedules {
                let scheduleItem = ScheduleItem(
                    iconName: schedule.topicType == TopicsType.flashcards ? "square.stack.3d.down.forward" : "clipboard",
                    title: schedule.title,
                    subtitle: "",
                    progress: (schedule.completed != nil) ? 1 : 0,
                    topicType: schedule.topicType,
                    topicId: schedule.topic
                )
                temp.append(scheduleItem)
            }
            return temp
        }
        
        private let numberOfDaysToShow = 5
        private let calendar = Calendar.current
        private var selectedDate: Date = Date()
        
        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            Task {
                schedules = try await schedulesDb.findAll()
                setupUI()
                setupTableView()
                setupDateViews()
                setupNavigationBar()
                setupGradient()
            }
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            setupGradient()
        }
        
        // MARK: - Setup
        private func setupGradient() {
            let mainColor = AppTheme.primary
            gradientLayer.colors = [
                mainColor.withAlphaComponent(1.0).cgColor,
                mainColor.withAlphaComponent(0.0).cgColor
            ]
            gradientLayer.locations = [0.0, 0.15]
            gradientLayer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 10)
            view.layer.addSublayer(gradientLayer)
        }
        
        private func setupNavigationBar() {
            navigationController?.navigationBar.prefersLargeTitles = false
            title = "Schedule"
            
            let doneButton = UIBarButtonItem(
                title: "Done",
                style: .done,
                target: self,
                action: #selector(doneButtonTapped)
            )
            doneButton.tintColor = AppTheme.primary
            navigationItem.rightBarButtonItem = doneButton
        }
        
        private func setupUI() {
            view.backgroundColor = .systemGray6
            
            // Configure date stack view
            dateStackView.backgroundColor = .white
            dateStackView.layer.cornerRadius = 16
            dateStackView.clipsToBounds = true
            dateStackView.axis = .horizontal
            dateStackView.distribution = .fillEqually
            dateStackView.spacing = 8
            dateStackView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
            dateStackView.isLayoutMarginsRelativeArrangement = true
            
            // Configure main stack view
            mainStackView.axis = .vertical
            mainStackView.spacing = 20
            mainStackView.layoutMargins = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
            mainStackView.isLayoutMarginsRelativeArrangement = true
        }
        
        private func setupTableView() {
            tableView.backgroundColor = .white
            tableView.layer.cornerRadius = 16
            tableView.clipsToBounds = true
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
        
        // Configure date stack view properties
        dateStackView.backgroundColor = .white
        dateStackView.layer.cornerRadius = 16
        dateStackView.clipsToBounds = true
        
        // Create horizontal stack view for dates with improved spacing
        let horizontalStack = UIStackView()
        horizontalStack.axis = .horizontal
        horizontalStack.distribution = .equalSpacing // Changed to equalSpacing for better distribution
        horizontalStack.spacing = 16 // Increased spacing between date views
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        
        for i in 0..<numberOfDaysToShow {
            if let date = calendar.date(byAdding: .day, value: i, to: today) {
                let dateView = createDateView(for: date)
                horizontalStack.addArrangedSubview(dateView)
                
                let tapGesture = UITapGestureRecognizer(target: self,
                                                       action: #selector(dateViewTapped(_:)))
                dateView.addGestureRecognizer(tapGesture)
                dateView.tag = i
            }
        }
        
        // Add horizontal stack to date stack view
        dateStackView.addArrangedSubview(horizontalStack)
        
        // Improved constraints for better spacing
        NSLayoutConstraint.activate([
            horizontalStack.leadingAnchor.constraint(equalTo: dateStackView.leadingAnchor, constant: 24),
            horizontalStack.trailingAnchor.constraint(equalTo: dateStackView.trailingAnchor, constant: -24),
            horizontalStack.topAnchor.constraint(equalTo: dateStackView.topAnchor, constant: 20),
            horizontalStack.bottomAnchor.constraint(equalTo: dateStackView.bottomAnchor, constant: -20)
        ])
        
        updateSelectedDateView(index: 0)
    }

    private func createDateView(for date: Date) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .white
        container.layer.cornerRadius = 16 // Increased corner radius
        container.clipsToBounds = true
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.05
        container.layer.shadowRadius = 5
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.isUserInteractionEnabled = true
        
        
        
         func createLabel(text: String, size: CGFloat, weight: UIFont.Weight) -> UILabel {
                  let label = UILabel()
                  label.translatesAutoresizingMaskIntoConstraints = false
                  label.font = .systemFont(ofSize: size, weight: weight)
                  label.text = text
                  label.textColor = .label
                  label.textAlignment = .center
                  return label
              }
              
        // Create labels with improved styling
        let monthLabel = createLabel(text: date.monthString(), size: 12, weight: .medium)
        let dateLabel = createLabel(text: String(calendar.component(.day, from: date)), size: 20, weight: .bold)
        let dayLabel = createLabel(text: date.dayOfWeekString(), size: 12, weight: .medium)
        
        let stack = UIStackView(arrangedSubviews: [monthLabel, dateLabel, dayLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4 // Consistent spacing between labels
        
        container.addSubview(stack)
        
        // Updated constraints for better proportions
        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: 60), // Fixed width
            container.heightAnchor.constraint(equalToConstant: 90), // Increased height
            
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

    private func updateSelectedDateView(index: Int) {
        dateViews.forEach { view in
            view.backgroundColor = .white
            view.layer.borderWidth = 0
            if let stack = view.subviews.first as? UIStackView {
                stack.arrangedSubviews.forEach { label in
                    if let label = label as? UILabel {
                        label.textColor = .systemGray
                    }
                }
            }
        }
        
        let selectedView = dateViews[index]
        selectedView.backgroundColor = AppTheme.primary.withAlphaComponent(0.1)
        selectedView.layer.borderWidth = 1
        selectedView.layer.borderColor = AppTheme.primary.cgColor
        
        if let stack = selectedView.subviews.first as? UIStackView {
            stack.arrangedSubviews.forEach { label in
                if let label = label as? UILabel {
                    label.textColor = AppTheme.primary
                }
            }
        }
        
        if let date = calendar.date(byAdding: .day, value: index, to: Date()) {
            selectedDate = date
        }
    }
    
  
      
        // MARK: - Actions
        @objc private func dateViewTapped(_ gesture: UITapGestureRecognizer) {
            guard let index = gesture.view?.tag else { return }
            offset = index
            updateSelectedDateView(index: index)
            loadScheduleItems()
        }
        
        @objc private func doneButtonTapped() {
            dismiss(animated: true)
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
