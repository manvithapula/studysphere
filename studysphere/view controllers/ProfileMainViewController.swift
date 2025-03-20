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

    
    //Table Height Constraint
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let email = AuthManager.shared.userEmail ?? FirebaseAuthManager.shared.currentUser!.email
        print(email as Any)
        Task{
            if let item = try await userDB.findAll(where: ["email":email!]).first{
                user = item
                print(item)
            }else{
                user = userDB.create(&user)
            }
            setupUI()
            setupTableView()
        }
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
        
        //extra separators
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
        profileImageView?.layer.cornerRadius = 50
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        
        // Name label setup
        nameLabel.font = .systemFont(ofSize: 24, weight: .bold)
        nameLabel.textAlignment = .center
        nameLabel.text = user.firstName
        
        // Details button setup
        detailsButton.backgroundColor = .systemGray6
        detailsButton.layer.cornerRadius = 12
        detailsButton.contentHorizontalAlignment = .left
        
        //cheveron to buttons
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
    
    @IBAction func comeHere(segue:UIStoryboardSegue) {
        setupUI()
        setupTableView()
    }
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            if isMovingToParent || isBeingPresented {
                // Normal forward navigation
            } else {
                setupUI()
                setupTableView()
            }
        loadImageFromUserDefaults()
        }
}

//TableView DataSource & Delegate
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
            
            toggle.tag = indexPath.row  // Use tag to identify which toggle
            toggle.addTarget(self, action: #selector(toggleValueChanged(_:)), for: .valueChanged)
                   
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            
            if indexPath.row == 2 {  // Logout cell
                showLogoutAlert()
            }
        }
    private func showLogoutAlert() {
            let alert = UIAlertController(
                title: "Logout",
                message: "Are you sure you want to logout?",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
                self?.performLogout()
            })
            
            present(alert, animated: true)
        }
        
        private func performLogout() {
            // Clear user data
            AuthManager.shared.logOut()
            subjectDb.clearCache()
            scoreDb.clearCache()
            topicsDb.clearCache()
            schedulesDb.clearCache()
            flashCardDb.clearCache()
            summaryDb.clearCache()
            questionsDb.clearCache()
            do{
                try FirebaseAuthManager.shared.signOut()
            }
            catch{
                print(error)
            }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let navVC = storyboard.instantiateViewController(withIdentifier: "loginNav") as? UINavigationController {
                        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController = navVC
        }
        }
    //notifications and face id 
    @objc private func toggleValueChanged(_ sender: UISwitch) {
            switch sender.tag {
            case 0:
                user.pushNotificationEnabled = sender.isOn
                
            case 1:
                user.faceIdEnabled = sender.isOn
                
            default:
                break
            }
        Task{
            try await userDB.update(&user)
        }
        }
    
    private func loadImageFromUserDefaults() {
        if let photoURL = FirebaseAuthManager.shared.currentUser?.photoURL {
            // Create a unique cache key based on the URL
            let cacheKey = photoURL.absoluteString
            
            // Check if image exists in UserDefaults cache
            if let cachedImageData = UserDefaults.standard.data(forKey: cacheKey),
               let cachedImage = UIImage(data: cachedImageData) {
                // Use cached image
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.profileImageView.image = cachedImage
                }
                return
            }
            
            // If not in cache, download from network
            URLSession.shared.dataTask(with: photoURL) { [weak self] data, response, error in
                guard let self = self,
                      let imageData = data,
                      error == nil,
                      let image = UIImage(data: imageData) else {
                    print("Error loading profile image: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                // Save to UserDefaults cache
                UserDefaults.standard.set(imageData, forKey: cacheKey)
                
                // Update UI on main thread
                DispatchQueue.main.async {
                    self.profileImageView.image = image
                }
            }.resume()
        } else {
            // Set default image when no photo URL exists
            profileImageView.image = UIImage(systemName: "person.crop.circle")
        }
    }
}
