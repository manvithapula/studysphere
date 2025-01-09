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
        
        // Removed standalone labels since they'll be part of the navigation title
        
        private var scheduleItems: [ScheduleItem] = [
            ScheduleItem(iconName: "book.fill", title: "Introduction to Swift", subtitle: "2 chapters remaining", progress: 0.7),
            ScheduleItem(iconName: "pencil", title: "UI Design Basics", subtitle: "1 chapter remaining", progress: 0.3)
        ]
        
        private var sectionTitles = ["Your Streak", "Today's Learning", "Subjects", "Study Techniques"]
        private var subjects: [String] = ["Mathematics", "Physics", "Chemistry", "Biology"]
        private var studyTechniques: [String] = ["Spaced Repetiton", "Active Recall", "Summariser"]
        private var streakStartDate: Date = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        
        override func viewDidLoad() {
            print("Home loaded")
            super.viewDidLoad()
            setupGradient()
            setupCollectionView()
            setupNavigationBar()
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
        
        private func setupNavigationBar() {
            navigationController?.navigationBar.prefersLargeTitles = false
            navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController?.navigationBar.shadowImage = UIImage()
            navigationController?.navigationBar.isTranslucent = true
            
            // Create labels for the navigation title
            let nameLabel = UILabel()
            nameLabel.text = "Amitesh"
            nameLabel.font = .systemFont(ofSize: 28, weight: .bold)
            nameLabel.textColor = .black
            
            let motivationalLabel = UILabel()
            motivationalLabel.text = "Ready to learn something new today?"
            motivationalLabel.font = .systemFont(ofSize: 14, weight: .regular)
            motivationalLabel.textColor = .black
            
            // Stack view for the labels
            let titleStackView = UIStackView(arrangedSubviews: [nameLabel, motivationalLabel])
            titleStackView.axis = .vertical
            titleStackView.alignment = .leading
            titleStackView.spacing = 4
            
            // Set as the navigation title
            navigationItem.titleView = titleStackView
        }
        
        private func setupCollectionView() {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.backgroundColor = .clear
            
            collectionView.register(UICollectionReusableView.self,
                                  forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                  withReuseIdentifier: "HeaderView")
            
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.minimumInteritemSpacing = 8
            layout.minimumLineSpacing = 8
            layout.sectionInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
            layout.headerReferenceSize = CGSize(width: collectionView.bounds.width, height: 50)
            collectionView.collectionViewLayout = layout
            
            // Remove the top content inset since we're using the navigation bar
            collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        
    @objc private func chevronButtonTapped() {
        performSegue(withIdentifier: "TodaysLearningSegue", sender: self)
    }
    @objc private func subjectsChevronButtonTapped() {
        performSegue(withIdentifier: "SubjectListViewSegue", sender: self)
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
                
                let titleLabel = UILabel()
                titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
                titleLabel.text = sectionTitles[indexPath.section]
                titleLabel.translatesAutoresizingMaskIntoConstraints = false
                
                // Add chevron for both Today's Learning and Subjects sections
                if indexPath.section == 1 || indexPath.section == 2 {
                    let chevronButton = UIButton(type: .system)
                    let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
                    chevronButton.setImage(UIImage(systemName: "chevron.right", withConfiguration: config), for: .normal)
                    chevronButton.translatesAutoresizingMaskIntoConstraints = false
                    
                    // Set different selector based on section
                    if indexPath.section == 1 {
                        chevronButton.addTarget(self, action: #selector(chevronButtonTapped), for: .touchUpInside)
                    } else {
                        chevronButton.addTarget(self, action: #selector(subjectsChevronButtonTapped), for: .touchUpInside)
                    }
                    
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
                cell.subjectTitle.text = subjects[indexPath.row]
                cell.layer.cornerRadius = 12
                cell.backgroundColor = UIColor.main
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
                return CGSize(width: (width - 16), height: 80)
            case 3:
                return CGSize(width: (width - 16) / 3, height: 120)
            default:
                return .zero
            }
        }
    }

    // MARK: - UICollectionViewDelegate

extension homeScreenViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            performSegue(withIdentifier: "CalenderViewSegue", sender: self)
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
}
    
