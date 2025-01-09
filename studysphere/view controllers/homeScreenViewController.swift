//
//  homeScreenViewController.swift
//  studysphere
//
//  Created by admin64 on 04/11/24.
//

import UIKit

class homeScreenViewController: UIViewController {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
        
   
    private var gradientLayer = CAGradientLayer()
        private let nameLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 34, weight: .bold)
            label.textColor = .black
            label.text = AuthManager.shared.firstName! + " " + AuthManager.shared.lastName!
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        private let motivationalLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 16, weight: .regular)
            label.textColor = .black
            label.text = "Ready to learn something new today?"
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        private var scheduleItems: [ScheduleItem] = [
            ScheduleItem(iconName: "book.", title: "Introduction to Swift", subtitle: "2 chapters remaining", progress: 0.7),
            ScheduleItem(iconName: "pencil", title: "UI Design Basics", subtitle: "1 chapter remaining", progress: 0.3)
        ]
        
        private var sectionTitles = ["", "Today's Learning", "Subjects", "Study Techniques"]
        private var subjects: [Subject] = []
        private var studyTechniques: [String] = ["Flashcards", "Active Recall", "Review"]
        private var streakStartDate: Date = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        
        override func viewDidLoad() {
            print("Home loaded")
            super.viewDidLoad()
            
            Task{
                subjects = try await subjectDb.findAll()
                collectionView.reloadData()
                setupGradient()
                setupHeaderLabels()
                setupCollectionView()
                setupNavigationBar()
            }

            
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            gradientLayer.frame = view.bounds
        }
        
    private func setupGradient() {
            let mainColor = UIColor.orange
            
        gradientLayer.colors = [
                mainColor.withAlphaComponent(1.0).cgColor,
                mainColor.withAlphaComponent(0.0).cgColor
            ]
        gradientLayer.locations = [0.0, 0.15]
        gradientLayer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 10)
        view.layer.addSublayer(gradientLayer)
        }

        
        private func setupHeaderLabels() {
            view.addSubview(nameLabel)
            view.addSubview(motivationalLabel)
            
            NSLayoutConstraint.activate([
                nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
                nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                
                motivationalLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
                motivationalLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor)
            ])
        }
    private func setupNavigationTitle() {
        // Create a container view for the labels
        let titleView = UIView()
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add labels to the container
        titleView.addSubview(nameLabel)
        titleView.addSubview(motivationalLabel)
        
        // Configure constraints within the container
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: titleView.topAnchor,constant: -26),
            nameLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor),
            
            motivationalLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            motivationalLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
            motivationalLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor),
            motivationalLabel.bottomAnchor.constraint(equalTo: titleView.bottomAnchor)
        ])
        
        // Set the custom view as navigation title
        navigationItem.titleView = titleView
    }
        
        private func setupNavigationBar() {
            navigationController?.navigationBar.prefersLargeTitles = false
            navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController?.navigationBar.shadowImage = UIImage()
            navigationController?.navigationBar.isTranslucent = true
        }
        
        private func setupCollectionView() {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.backgroundColor = .clear
            
            // Register header
            collectionView.register(UICollectionReusableView.self,
                                  forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                  withReuseIdentifier: "HeaderView")
            
            // Setup collection view layout
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.minimumInteritemSpacing = 8
            layout.minimumLineSpacing = 8
            layout.sectionInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
            layout.headerReferenceSize = CGSize(width: collectionView.bounds.width, height: 50)
            collectionView.collectionViewLayout = layout
            
            // Adjust collection view insets to account for header labels
            collectionView.contentInset = UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0)
        }
        
        @objc private func chevronButtonTapped() {
            performSegue(withIdentifier: "showSchedule", sender: self)
        }
    }


    // MARK: - UICollectionViewDataSource
    extension homeScreenViewController: UICollectionViewDataSource {
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 4
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            switch section {
            case 0: return 1
            case 1: return scheduleItems.count
            case 2: return subjects.count
            case 3: return studyTechniques.count
            default: return 0
            }
        }
        
        func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            if kind == UICollectionView.elementKindSectionHeader {
                let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: "HeaderView",
                    for: indexPath)
                
                // Create and configure title label
                let titleLabel = UILabel()
                titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
                titleLabel.text = sectionTitles[indexPath.section]
                titleLabel.translatesAutoresizingMaskIntoConstraints = false
                
                // Add chevron button for Today's Learning section
                if indexPath.section == 1 {
                    let chevronButton = UIButton(type: .system)
                    let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
                    chevronButton.setImage(UIImage(systemName: "chevron.right", withConfiguration: config), for: .normal)
                    chevronButton.addTarget(self, action: #selector(chevronButtonTapped), for: .touchUpInside)
                    chevronButton.translatesAutoresizingMaskIntoConstraints = false
                    
                    headerView.addSubview(chevronButton)
                    headerView.addSubview(titleLabel)
                    
                    NSLayoutConstraint.activate([
                        titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
                        titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
                        
                        chevronButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
                        chevronButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
                        chevronButton.widthAnchor.constraint(equalToConstant: 30),
                        chevronButton.heightAnchor.constraint(equalToConstant: 30)
                    ])
                } else {
                    headerView.addSubview(titleLabel)
                    NSLayoutConstraint.activate([
                        titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
                        titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
                    ])
                }
                
                return headerView
            }
            return UICollectionReusableView()
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            switch indexPath.section {
            case 0:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StreakCell", for: indexPath) as? StreakCellCollectionViewCell else {
                    return UICollectionViewCell()
                }
                cell.configure(with: streakStartDate)
                return cell
                
            case 1:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TodaysLearningCell", for: indexPath) as? TodaysLearningCollectionViewCell else {
                    return UICollectionViewCell()
                }
                let module = scheduleItems[indexPath.row]
                cell.configure(with: module)
                return cell
                
            case 2:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubjectsHomeCell", for: indexPath) as? SubjectsHomeCollectionViewCell else {
                    return UICollectionViewCell()
                }
               
                cell.subjectTitle.text = subjects[indexPath.row].name
                cell.button.addAction(UIAction { [weak self] _ in
                    self?.performSegue(withIdentifier: "toSubjectList", sender: self?.subjects[indexPath.row])
                    }, for: .touchUpInside)
                cell.layer.cornerRadius = 12
                cell.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
                return cell
                
            case 3:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "studytechniques", for: indexPath) as? StudyTechniquesCollectionViewCell else {
                    return UICollectionViewCell()
                }
                let techniqueName = studyTechniques[indexPath.row]
                cell.techniqueName.text = techniqueName
                cell.completed.text = "Completed"
                cell.completionStatus.text = "12/18"
                cell.button.addAction(UIAction { [weak self] _ in
                    switch indexPath.row {
                    case 0:
                        self?.performSegue(withIdentifier: "toSrListView", sender: self)
                    case 1:
                        self?.performSegue(withIdentifier: "toArListView", sender: self)
                    case 2:
                        self?.performSegue(withIdentifier: "toSuListView", sender: self)
                    default:
                        break
                    }
                    }, for: .touchUpInside)
                cell.layer.cornerRadius = 12
                cell.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.2)
                return cell
                
            default:
                return UICollectionViewCell()
            }
        }
        // In your UICollectionViewDelegate
        // Then create your detail view controller
        class StudyTechniqueDetailViewController: UIViewController {
            var techniqueName: String?
            
            override func viewDidLoad() {
                super.viewDidLoad()
                view.backgroundColor = .systemBackground
                title = techniqueName
                
                // Add your detail view setup here
                setupUI()
            }
            
            private func setupUI() {
                // Add your UI components for the detail view
            }
        }
        
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    extension homeScreenViewController: UICollectionViewDelegateFlowLayout {
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let width = collectionView.bounds.width - 32
            
            switch indexPath.section {
            case 0:
                return CGSize(width: 350, height: 330)
            case 1:
                return CGSize(width: width, height: 80)
            case 2:
                return CGSize(width: (width - 16), height: 80) // Subjects: 2 columns
            case 3:
                return CGSize(width: (width - 16) / 3, height: 120) // Study techniques: 3 columns
            default:
                return .zero
            }
        }
    }

    // MARK: - UICollectionViewDelegate
    extension homeScreenViewController: UICollectionViewDelegate {
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            print("Tapped")
            switch indexPath.section {
            case 0:
                print("Streak cell tapped")
            case 1:
                let item = scheduleItems[indexPath.row]
                print("Learning item tapped: \(item.title)")
            case 2:
                let subject = subjects[indexPath.row]
                print("Subject tapped: \(subject)")
            case 3:
                print("Tapped")
            default:
                break
            }
        }
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "toSubjectList" {
                let destination = segue.destination as! subjectViewController
                if let subject = sender as? Subject {
                    destination.subject = subject
                }
                
            }
        }

    }
