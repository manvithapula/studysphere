//
//  ARListViewController.swift
//  studysphere
//
//  Created by Dev on 18/11/24.
//

import UIKit

class ARListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var ARList: UICollectionView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    
        enum FilterState {
            case ongoing, completed
        }
        
        
    var questions: [Topics] = []
        
       
    var filteredquestions: [Topics] {
        return questions.filter { card in
           
            let matchesSegment = filterState == .ongoing ? (card.completed == nil) : card.completed != nil
            let matchesSearch = searchBar.text?.isEmpty ?? true || card.title.lowercased().contains(searchBar.text!.lowercased())
            return matchesSegment && matchesSearch
        }
        }
        var filterState: FilterState = .ongoing
        
        // Search bar for filtering
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
//            setupTapGesture()
            ARList.dataSource = self
            ARList.delegate = self
            ARList.setCollectionViewLayout(generateLayout(), animated: true)
           
            segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
            segmentControl.selectedSegmentTintColor = AppTheme.primary
            segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.systemGray], for: .normal)
            segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
          
            searchBar.delegate = self
            Task{
                questions = try await topicsDb.findAll(where: ["type": TopicsType.quizzes.rawValue])
                ARList.reloadData()
                
            }

        }
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
       
        @objc func segmentChanged() {
            filterState = segmentControl.selectedSegmentIndex == 0 ? .ongoing : .completed
            ARList.reloadData()
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            ARList.reloadData()
        }
        
      
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return filteredquestions.count
        }
        
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AR", for: indexPath)
            let question = filteredquestions[indexPath.item]
            
            if let cell = cell as? SummaryCollectionViewCell {
                cell.titleLabel.text = question.title
                cell.updateSubject(topic: question)
                cell.timeLabel.text = question.subtitle == "" ? "6 more to go" : question.subtitle


            }
            
            return cell
        }
        
    // MARK: - Layout
    private func generateLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(120)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(120)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)
        section.interGroupSpacing = 8
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toARschedule",
           let destinationVC = segue.destination as? ARScheduleViewController,
           let selectedIndex = sender as? Int { // Extract the tag passed as sender
            let selectedCard = filteredquestions[selectedIndex] // Get the card using the tag
            destinationVC.topic = selectedCard // Pass the data to the destination VC
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task{
            questions = try await topicsDb.findAll(where: ["type": TopicsType.quizzes.rawValue])
            ARList.reloadData()
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toARschedule", sender: indexPath.row)
    }

}

   
