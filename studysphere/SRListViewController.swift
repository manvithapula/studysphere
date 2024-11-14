//
//  SRListViewController.swift
//  studysphere
//
//  Created by dark on 29/10/24.
//

import UIKit

class SRListViewController: UIViewController ,UICollectionViewDataSource{
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var queryF: UITextField!
    
    var query:String = ""
    var isComplete:Bool = false
    var filteredCards: [Card] {
        if query.isEmpty {
            return cards.filter{
                $0.isCompleted == isComplete
            }
        }
        return cards.filter {
            $0.title.lowercased().contains(query.lowercased()) && $0.isCompleted == isComplete
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCards.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "spaced", for: indexPath)
        let card = filteredCards[indexPath.row]
        if let cell = cell as? spacedCollectionViewCell {
            cell.title.text = card.title
            cell.subTitle.text = card.subtitle

        }
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        collection.dataSource = self
        collection.setCollectionViewLayout(generateLayout(), animated: true)

    }
    func generateLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.22))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)

        return UICollectionViewCompositionalLayout(section: section)
    }

    @IBAction func searchQueryChanged(_ sender: UITextField) {
        query = sender.text ?? ""
        collection.reloadData()
    }
    @IBAction func toggleCompleted(_ sender: UISegmentedControl) {
        isComplete = sender.selectedSegmentIndex == 1
        collection.reloadData()
    }
    
}
