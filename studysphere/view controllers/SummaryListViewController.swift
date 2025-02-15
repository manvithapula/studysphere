//
//  SummaryViewController.swift
//  studysphere
//
//  Created by admin64 on 07/11/24.
//

import UIKit

class SummaryListViewController: UIViewController{
 
 
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var summaryList: UICollectionView!
    private var gradientLayer = CAGradientLayer()
   
   
      var cards: [Topics] = []
      var filteredCards: [Topics] {
          return cards.filter { card in
              searchBar.text?.isEmpty ?? true ||
              card.title.lowercased().contains(searchBar.text!.lowercased())
          }
      }
      
      // MARK: - Lifecycle
      override func viewDidLoad() {
          super.viewDidLoad()
          setupUI()
          setupCollectionView()
          setupSearchBar()
          loadData()
      }
      
      override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
          setupGradient()
          loadData()
      }
      
      // MARK: - Setup Methods
      private func setupUI() {
          view.backgroundColor = .systemGray6
          navigationController?.navigationBar.prefersLargeTitles = false
          title = "Summaries"
      }
      
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
      
      private func setupSearchBar() {
          searchBar.backgroundColor = .white
          searchBar.layer.cornerRadius = 16
          searchBar.clipsToBounds = true
          searchBar.searchTextField.backgroundColor = .systemGray6
          searchBar.delegate = self
          searchBar.searchBarStyle = .minimal
          searchBar.placeholder = "Search summaries..."
          searchBar.tintColor = AppTheme.primary
          
          // Add shadow to searchBar
          searchBar.layer.shadowColor = UIColor.black.cgColor
          searchBar.layer.shadowOpacity = 0.05
          searchBar.layer.shadowRadius = 5
          searchBar.layer.shadowOffset = CGSize(width: 0, height: 2)
      }
      
      private func setupCollectionView() {
          summaryList.delegate = self
          summaryList.dataSource = self
          summaryList.backgroundColor = .clear
          summaryList.contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
          summaryList.setCollectionViewLayout(generateLayout(), animated: true)
          summaryList.showsVerticalScrollIndicator = false
      }
      
    private func generateLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0), // Full width
            heightDimension: .estimated(100) // Flexible height
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8 // Reduce spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)

        return UICollectionViewCompositionalLayout(section: section)
    }

   // override func viewDidLayoutSubviews() {
      //  super.viewDidLayoutSubviews()
      //  gradientLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 10) // Adjust for screen width
   // }

      private func loadData() {
          Task {
              cards = try await topicsDb.findAll(where: ["type": TopicsType.summary.rawValue])
              summaryList.reloadData()
          }
      }
      
      // MARK: - Navigation
      override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
          if segue.identifier == "toSummary",
             let destinationVC = segue.destination as? SummariserViewController,
             let selectedIndex = sender as? Int {
              let selectedCard = filteredCards[selectedIndex]
              destinationVC.topic = selectedCard
              
              destinationVC.completionHandler = { [weak self] updatedTopic in
                  guard let self = self else { return }
                  
                  if let index = self.cards.firstIndex(where: { $0.id == updatedTopic.id }) {
                      self.cards[index] = updatedTopic
                  }
                  
                  self.summaryList.reloadData()
              }
          }
      }
  }

  // MARK: - UICollectionView DataSource & Delegate
  extension SummaryListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
      func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
          return filteredCards.count
      }
      
      func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
          guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "summary", for: indexPath) as? SummaryCollectionViewCell else {
              return UICollectionViewCell()
          }
          
          let card = filteredCards[indexPath.item]
          cell.updateSubject(topic: card)
          return cell
      }
      
      func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
          performSegue(withIdentifier: "toSummary", sender: indexPath.item)
      }
  }

  // MARK: - UISearchBar Delegate
  extension SummaryListViewController: UISearchBarDelegate {
      func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
          summaryList.reloadData()
      }
  }
