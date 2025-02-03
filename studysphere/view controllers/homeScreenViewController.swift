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
    
        
        private var scheduleItems: [ScheduleItem] = []
        
        private var sectionTitles = ["Your Streak", "Today's Learning", "Subjects", "Study Techniques"]
        private var subjects: [Subject] = []
        private var studyTechniques: [String] = ["Spaced Repetition", "Active Recall", "Summariser"]

        private var streakStartDate: Date = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task{
            Task{
                subjects = try await subjectDb.findAll()
                let schedules = try await  schedulesDb.findAll()
                let today = formatDateToString(date: Date())
                var filterSchedules:[Schedule]{
                    return schedules.filter { schedule in
                        
                        let date = formatDateToString(date: schedule.date.dateValue())
                        return date == today
                    }
                }
                scheduleItems = []
                var i = 0
                for schedule in filterSchedules{
                    if i > 2{
                        break
                    }
                    if(schedule.completed == nil){
                        let scheduleItem = ScheduleItem(iconName: schedule.topicType == TopicsType.flashcards ? "square.stack.3d.down.forward":"clipboard", title: schedule.title,subtitle: "", progress: 0,topicType: schedule.topicType,topicId: schedule.topic)
                        scheduleItems.append(scheduleItem)
                        i += 1
                    }
                }
                collectionView.reloadData()
                
            }
        }
    }
        override func viewDidLoad() {
            print("Home loaded")
            super.viewDidLoad()
            navigationController?.navigationBar.prefersLargeTitles = false
            Task{
                subjects = try await subjectDb.findAll()
                let schedules = try await  schedulesDb.findAll()
                let today = formatDateToString(date: Date())
                var filterSchedules:[Schedule]{
                    return schedules.filter { schedule in
                        
                        let date = formatDateToString(date: schedule.date.dateValue())
                        return date == today
                    }
                }
                scheduleItems = []
                var i = 0
                for schedule in filterSchedules{
                    if i > 2{
                        break
                    }
                    if(schedule.completed == nil){
                        let scheduleItem = ScheduleItem(iconName: "pencil", title: schedule.title,subtitle: "", progress: 0,topicType: schedule.topicType,topicId: schedule.topic)
                        scheduleItems.append(scheduleItem)
                        i += 1
                    }
                }
                setupGradient()
                setupCollectionView()
                navigationItem.title = "StudySphere"
                
            }

            
        }
        
    override func viewDidLayoutSubviews() {
          super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
          // Adding an accessory view with a profile button
          let accessoryView = UIButton()
          let image = UIImage(named: "profile-avatar")
          if let image = UIImage(named: "profile-avatar") {
              accessoryView.setImage(image, for: .normal)
          } else {
              print("Image not found.")
          }
          
          
          accessoryView.setImage(image, for: .normal)
          accessoryView.frame.size = CGSize(width: 34, height: 34)
          
          if let largeTitleView = navigationController?.navigationBar.subviews.first(where: { subview in
              String(describing: type(of: subview)) == "_UINavigationBarLargeTitleView"
          }) {
              largeTitleView.perform(Selector(("setAccessoryView:")), with: accessoryView)
              largeTitleView.perform(Selector(("setAlignAccessoryViewToTitleBaseline:")), with: nil)
              largeTitleView.perform(Selector(("updateContent")))
          }
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


        
   /* private func setupNavigationBar() {
       
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        
        let accessoryView = UIButton()
        if let image = UIImage(named: "profile-avatar") {
            accessoryView.setImage(image, for: .normal)
            accessoryView.translatesAutoresizingMaskIntoConstraints = false
            accessoryView.widthAnchor.constraint(equalToConstant: 40).isActive = true
            accessoryView.heightAnchor.constraint(equalToConstant: 40).isActive = true
            accessoryView.layer.cornerRadius = 20
            accessoryView.clipsToBounds = true
        }
    
        let nameLabel = UILabel()
        nameLabel.text = AuthManager.shared.firstName! + " " + AuthManager.shared.lastName!
        nameLabel.font = .systemFont(ofSize: 28, weight: .bold)
        nameLabel.textColor = .black
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
       
        let motivationalLabel = UILabel()
        motivationalLabel.text = "Ready to learn something new today?"
        motivationalLabel.font = .systemFont(ofSize: 14, weight: .regular)
        motivationalLabel.textColor = .black
        motivationalLabel.translatesAutoresizingMaskIntoConstraints = false
        motivationalLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        motivationalLabel.setContentHuggingPriority(.required, for: .horizontal)
        

        let titleStackView = UIStackView(arrangedSubviews: [nameLabel, motivationalLabel])
        titleStackView.axis = .vertical
        titleStackView.alignment = .leading
        titleStackView.spacing = 4
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        

        let horizontalStack = UIStackView(arrangedSubviews: [titleStackView, accessoryView])
        horizontalStack.axis = .horizontal
        horizontalStack.alignment = .center
        horizontalStack.spacing = 12
        horizontalStack.distribution = .equalSpacing
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        
      
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(horizontalStack)
        NSLayoutConstraint.activate([
            horizontalStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            horizontalStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            horizontalStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            horizontalStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            
            
            titleStackView.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
            motivationalLabel.widthAnchor.constraint(lessThanOrEqualTo: titleStackView.widthAnchor),
            nameLabel.widthAnchor.constraint(lessThanOrEqualTo: titleStackView.widthAnchor)
        ])
        navigationItem.titleView = containerView
        if let containerWidth = navigationController?.navigationBar.frame.width {
            containerView.widthAnchor.constraint(equalToConstant: containerWidth).isActive = true
        }
        containerView.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }*/

       
        
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

                // Get the title label (create if it doesn't exist)
                let titleLabel: UILabel
                if let existingLabel = headerView.subviews.first(where: { $0 is UILabel }) as? UILabel {
                    titleLabel = existingLabel
                } else {
                    titleLabel = UILabel()
                    titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
                    titleLabel.translatesAutoresizingMaskIntoConstraints = false
                    headerView.addSubview(titleLabel)
                    NSLayoutConstraint.activate([
                        titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
                        titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
                    ])
                }
                titleLabel.text = sectionTitles[indexPath.section] // Configure the text

                let chevronButtonTag = 100
                if indexPath.section == 1 || indexPath.section == 2 {
                    let chevronButton: UIButton
                    if let existingButton = headerView.viewWithTag(chevronButtonTag) as? UIButton {
                        chevronButton = existingButton
                    } else {
                        chevronButton = UIButton(type: .system)
                        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
                        chevronButton.setImage(UIImage(systemName: "chevron.right", withConfiguration: config), for: .normal)
                        chevronButton.translatesAutoresizingMaskIntoConstraints = false
                        chevronButton.tag = chevronButtonTag
                        headerView.addSubview(chevronButton)

                        NSLayoutConstraint.activate([
                            chevronButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
                            chevronButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
                            chevronButton.widthAnchor.constraint(equalToConstant: 30),
                            chevronButton.heightAnchor.constraint(equalToConstant: 30)
                        ])
                        chevronButton.removeTarget(nil, action: nil, for: .touchUpInside)

                        if indexPath.section == 1 {
                            chevronButton.addTarget(self, action: #selector(chevronButtonTapped), for: .touchUpInside)
                        } else {
                            chevronButton.addTarget(self, action: #selector(subjectsChevronButtonTapped), for: .touchUpInside)
                        }
                    }
                    // Ensure titleLabel is added for these sections
                    if !headerView.subviews.contains(titleLabel) {
                        headerView.addSubview(titleLabel)
                    }
                } else {
                    // Ensure titleLabel is added for other sections
                    if !headerView.subviews.contains(titleLabel) {
                        headerView.addSubview(titleLabel)
                    }
                    // Remove chevron button if it exists for other sections
                    if let existingButton = headerView.viewWithTag(chevronButtonTag) {
                        existingButton.removeFromSuperview()
                    }
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
                cell.button.removeTarget(nil, action: nil, for: .touchUpInside)
                cell.button.addAction(UIAction { [weak self] _ in
                    Task{
                        let topic = try await topicsDb.findAll(where: ["id":module.topicId]).first
                        self?.performSegue(withIdentifier:module.topicType == TopicsType.flashcards ? "toFLS" : "toQTS", sender: topic)
                    }
                    }, for: .touchUpInside)
                return cell
                
            case 2:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubjectsHomeCell", for: indexPath) as? SubjectsHomeCollectionViewCell else {
                    return UICollectionViewCell()
                }
               
                cell.subjectTitle.text = subjects[indexPath.row].name
                cell.button.removeTarget(nil, action: nil, for: .touchUpInside)
                cell.button.addAction(UIAction { [weak self] _ in
                    self?.performSegue(withIdentifier: "toSubjectList", sender: self?.subjects[indexPath.row])
                    }, for: .touchUpInside)
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
                var topic: TopicsType
                switch indexPath.row {
                case 0:
                    topic = TopicsType.flashcards
                case 1:
                    topic = TopicsType.quizzes
                case 2:
                    topic = TopicsType.summary
                default:
                    topic = TopicsType.flashcards
                }
                cell.updateCompletionStatus(topic: topic)
                cell.button.removeTarget(nil, action: nil, for: .touchUpInside)
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "toSubjectList" {
                let destination = segue.destination as! subjectViewController
                if let subject = sender as? Subject {
                    destination.subject = subject
                }
                
            }
        if segue.identifier == "toFLS" || segue.identifier == "toQTS"{
            if let destinationVC = segue.destination as? SRScheduleViewController {
                if let topic = sender as? Topics {
                    destinationVC.topic = topic
                }
            } else if let destinationVC = segue.destination as? ARScheduleViewController {
                if let topic = sender as? Topics {
                    destinationVC.topic = topic
                }
            }
        }
        }
}
    

    

