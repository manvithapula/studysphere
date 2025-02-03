//
//  SREditScheduleViewController.swift
//  studysphere
//
//  Created by dark on 06/11/24.
//

import UIKit
import FirebaseCore

class SREditScheduleViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    var datePicker: UIDatePicker?
    var activeIndexPath: IndexPath?
    var datePickerToolbar: UIToolbar?
    
    var schedules1: [Schedule] = schedules

    fileprivate func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.backgroundColor = .systemGray6
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 12
        tableView.clipsToBounds = true
    }
    private func updateTableHeight() {
        // Calculate total height of all rows
        let numberOfRows = schedules1.count
        var totalHeight: CGFloat = 0
        
        for _ in 0..<numberOfRows {
            totalHeight += max(tableView.rowHeight,43.5)
            print(tableView.rowHeight)
        }
        print(totalHeight)
        // Update height constraint
        tableHeightConstraint.constant = totalHeight
        
        // Force layout update
        view.layoutIfNeeded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit Schedule"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))

        setupTableView()

    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeight()
    }
    

}

extension SREditScheduleViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schedules1.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let schedule = schedules1[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SRScheduleCell", for: indexPath)
        cell.textLabel?.text = "Session \(indexPath.row + 1)"
        cell.detailTextLabel?.text = ""
        
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 120, height: 30)
        button.setTitle(formatDateToString(date: schedule.date.dateValue()), for: .normal)
        // Update the button action to show date picker
        button.tag = indexPath.row  // Add tag to identify which row was tapped
        button.addTarget(self, action: #selector(dateButtonTapped(_:)), for: .touchUpInside)
        button.tintColor = .gray
        button.backgroundColor = .clear
        
        cell.accessoryView = button
        cell.selectionStyle = .none
        cell.backgroundColor = .systemGray6
        
        return cell
    }
    @objc func dateButtonTapped(_ sender: UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        showDatePicker(for: indexPath)
    }
    @objc func dateChanged(_ sender: UIDatePicker) {
        if let indexPath = activeIndexPath {
            schedules1[indexPath.row].date = Timestamp(date:sender.date)
            var schedule = schedules1[indexPath.row]
            Task{
                try await schedulesDb.update(&schedule)
                tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
    }
    func showDatePicker(for indexPath: IndexPath) {
            // Create date picker and toolbar if they don't exist
            if datePicker == nil {
                setupDatePicker()
            }
            
            // Set current date
        datePicker?.date = schedules1[indexPath.row].date.dateValue()
            activeIndexPath = indexPath
            
            // Show date picker and toolbar
            datePicker?.isHidden = false
            datePickerToolbar?.isHidden = false
        }
    
    private func setupDatePicker() {
            datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
            datePicker?.preferredDatePickerStyle = .wheels
            datePicker?.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
            
            // Create toolbar
            datePickerToolbar = UIToolbar()
            datePickerToolbar?.sizeToFit()
            
            // Done button
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(datePickerDoneButtonTapped))
            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            datePickerToolbar?.setItems([flexSpace, doneButton], animated: false)
            
            // Add toolbar and picker to view
            if let toolbar = datePickerToolbar, let picker = datePicker {
                view.addSubview(toolbar)
                view.addSubview(picker)
                
                // Position toolbar and date picker
                toolbar.translatesAutoresizingMaskIntoConstraints = false
                picker.translatesAutoresizingMaskIntoConstraints = false
                
                NSLayoutConstraint.activate([
                    toolbar.bottomAnchor.constraint(equalTo: picker.topAnchor),
                    toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    
                    picker.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                    picker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    picker.trailingAnchor.constraint(equalTo: view.trailingAnchor)
                ])
            }
        }
        

    @objc func doneButtonTapped() {
        performSegue(withIdentifier: "unwindToSchedule", sender: nil)
        }
    @objc func nameTapped(tapGestureRecognizer: UITapGestureRecognizer){
        print("hi")
    }
    @objc func datePickerDoneButtonTapped() {
            // Hide date picker and toolbar
            datePicker?.isHidden = true
            datePickerToolbar?.isHidden = true
            
            // Update the table if needed
            if let activeIndexPath = activeIndexPath {
                tableView.reloadRows(at: [activeIndexPath], with: .none)
            }
        }
    
}
