//
//  ProfileMainViewController.swift
//  studysphere
//
//  Created by dark on 02/11/24.
//

import UIKit

class ProfileMainViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailsButton: UIButton!
    @IBOutlet weak var preferencesTable: UITableView!

    
    // MARK: - Table Height Constraint
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeight()
    }
    
    private func updateTableHeight() {
        // Calculate total height of all rows
        let numberOfRows = preferencesTable.numberOfRows(inSection: 0)
        var totalHeight: CGFloat = 0
        
        for _ in 0..<numberOfRows {
            totalHeight += preferencesTable.rowHeight
        }
        
        // Update height constraint
        tableHeightConstraint.constant = totalHeight
        
        // Force layout update
        view.layoutIfNeeded()
    }
    
    private func setupTableView() {
        // Set delegate and dataSource
        preferencesTable.delegate = self
        preferencesTable.dataSource = self
        
        // Register cells
        preferencesTable.register(UITableViewCell.self, forCellReuseIdentifier: "ToggleCell")
        preferencesTable.register(UITableViewCell.self, forCellReuseIdentifier: "LogoutCell")
        
        // Additional table setup
        preferencesTable.backgroundColor = .systemGray6
        preferencesTable.isScrollEnabled = false
        preferencesTable.layer.cornerRadius = 12
        preferencesTable.clipsToBounds = true
        
        // Set row height
        preferencesTable.rowHeight = 44
        
        // Remove extra separators
        preferencesTable.tableFooterView = UIView()
        
        // Set separator style
        preferencesTable.separatorStyle = .singleLine
        preferencesTable.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    private func setupUI() {
        // Navigation bar setup
        title = "Profile"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        
        // Profile image setup
        profileImageView.layer.cornerRadius = 50
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        
        // Name label setup
        nameLabel.font = .systemFont(ofSize: 24, weight: .bold)
        nameLabel.textAlignment = .center
        
        // Details button setup
        detailsButton.backgroundColor = .systemGray6
        detailsButton.layer.cornerRadius = 12
        detailsButton.contentHorizontalAlignment = .left
        
        // Add chevron to details button
        let chevronImage = UIImage(systemName: "chevron.right")
        let chevronImageView = UIImageView(image: chevronImage)
        chevronImageView.tintColor = .systemGray
        chevronImageView.contentMode = .scaleAspectFit
        detailsButton.addSubview(chevronImageView)
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chevronImageView.centerYAnchor.constraint(equalTo: detailsButton.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: detailsButton.trailingAnchor, constant: -16),
            chevronImageView.widthAnchor.constraint(equalToConstant: 12),
            chevronImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    @objc private func doneTapped() {
        dismiss(animated: true)
    }
}

// MARK: - TableView DataSource & Delegate
extension ProfileMainViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0, 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ToggleCell", for: indexPath)
            cell.textLabel?.text = indexPath.row == 0 ? "Push notification" : "Face ID"
            cell.backgroundColor = .systemGray6
            cell.selectionStyle = .none
            
            let toggle = UISwitch()
            toggle.isOn = indexPath.row == 0 ? user.pushNotificationEnabled : user.faceIdEnabled
            toggle.onTintColor = .systemGreen
            cell.accessoryView = toggle
            
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LogoutCell", for: indexPath)
            cell.textLabel?.text = "Logout"
            cell.textLabel?.textColor = .systemRed
            cell.backgroundColor = .systemGray6
            cell.textLabel?.textAlignment = .left
            cell.selectionStyle = .none
            
            return cell
            
        default:
            return UITableViewCell()
        }
    }
}
