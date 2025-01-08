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
            return questions.filter { que in
               
                let matchesSegment = filterState == .ongoing ? (que.completed == nil) : que.completed != nil
                let matchesSearch = searchBar.text?.isEmpty ?? true || que.title.lowercased().contains(searchBar.text!.lowercased())
                return matchesSegment && matchesSearch
            }
        }
        var filterState: FilterState = .ongoing
        
        // Search bar for filtering
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            ARList.dataSource = self
            ARList.delegate = self
            ARList.setCollectionViewLayout(generateLayout(), animated: true)
           
            segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
          
            searchBar.delegate = self
            Task{
                questions = try await topicsDb.findAll(where: ["type": TopicsType.quizzes.rawValue])
                
            }
            ARList.reloadData()

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
            
            if let cell = cell as? ARCollectionViewCell {
                cell.titleLabel.text = question.title
                cell.subtitleLabel.text = question.subtitle == "" ? "6 more to go" : question.subtitle
                
                if (question.completed != nil) {
                    cell.continueButtonTapped.setTitle("Review", for: .normal)
                } else {
                    cell.continueButtonTapped.setTitle("Continue Studying", for: .normal)
                }
                
                cell.continueButtonTapped.tag = indexPath.item // Use the tag to identify
                cell.continueButtonTapped.addTarget(self, action: #selector(detailButtonTapped(_:)), for: .touchUpInside)
            }
            
            return cell
        }
        
        func generateLayout() -> UICollectionViewLayout {
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.30))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            
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

    @objc func detailButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toARschedule", sender: sender.tag)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task{
            questions = try await topicsDb.findAll(where: ["type": TopicsType.quizzes.rawValue])
            ARList.reloadData()
        }
    }

}

   
