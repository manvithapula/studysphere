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
    @IBOutlet weak var segmentControl: UISegmentedControl!
    private var gradientLayer = CAGradientLayer()
   
   
    // MARK: - Properties
      enum FilterState {
          case ongoing, completed
      }
      
      var cards: [Topics] = []
      var filteredCards: [Topics] {
          return cards.filter { card in
              let matchesSegment = filterState == .ongoing ? card.completed == nil : card.completed != nil
              let matchesSearch = searchBar.text?.isEmpty ?? true || card.title.lowercased().contains(searchBar.text!.lowercased())
              return matchesSegment && matchesSearch
          }
      }
      var filterState: FilterState = .ongoing
      
      // MARK: - Lifecycle
      override func viewDidLoad() {
          super.viewDidLoad()
          setupUI()
          configureCollectionView()
          setupActions()
          loadData()
      }
      
      override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
          tabBarController?.isTabBarHidden = true

          loadData()
      }
      
      // MARK: - Setup Methods
      private func setupUI() {
          // Configure view
          view.backgroundColor = .systemGray6
          title = "Summaries"
          
          // Configure search bar
          searchBar.searchBarStyle = .minimal
          searchBar.placeholder = "Search summaries"
          searchBar.delegate = self
          
          // Configure segment control
          segmentControl.backgroundColor = .white
          segmentControl.selectedSegmentTintColor = .systemBlue
          segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.systemGray], for: .normal)
          segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
      }
      
      private func configureCollectionView() {
          summaryList.delegate = self
          summaryList.dataSource = self
          summaryList.backgroundColor = .clear
          summaryList.setCollectionViewLayout(generateLayout(), animated: false)
          summaryList.register(SummaryCollectionViewCell.self, forCellWithReuseIdentifier: "summary")
      }
      
      private func setupActions() {
          segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
      }
      
      private func loadData() {
          Task {
              cards = try await topicsDb.findAll(where: ["type": TopicsType.summary.rawValue])
              summaryList.reloadData()
          }
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
      
      // MARK: - Actions
      @objc private func segmentChanged() {
          filterState = segmentControl.selectedSegmentIndex == 0 ? .ongoing : .completed
          summaryList.reloadData()
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

  // MARK: - UICollectionViewDelegate & DataSource
  extension SummaryListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
      func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
          return filteredCards.count
      }
      
      func numberOfSections(in collectionView: UICollectionView) -> Int {
          return 1
      }
      
      func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
          guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "summary", for: indexPath) as? SummaryCollectionViewCell else {
              return UICollectionViewCell()
          }
          
          let topic = filteredCards[indexPath.item]
          cell.updateSubject(topic: topic)
          
          return cell
      }
      
      func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
          performSegue(withIdentifier: "toSummary", sender: indexPath.row)
      }
      
      override func viewWillDisappear(_ animated: Bool) {
          super.viewWillDisappear(animated)
          tabBarController?.isTabBarHidden = false
      }
  }

  // MARK: - UISearchBarDelegate
  extension SummaryListViewController: UISearchBarDelegate {
      func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
          summaryList.reloadData()
      }
      
      func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
          searchBar.resignFirstResponder()
      }
  }
