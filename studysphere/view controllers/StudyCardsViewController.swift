//
//  StudyCardsViewController.swift
//  studysphere
//
//  Created by dark on 16/02/25.
//

import UIKit

class StudyCardsViewController: UIViewController {
    private var collectionView: UICollectionView!
    private var items: [(content: String, type: String, pairId: Int)] = []
    private var flippedIndexPaths: Set<IndexPath> = []
    private var matchedPairIds: Set<Int> = []
    private var isProcessingMatch = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupCollectionView()
    }
    
    private func setupData() {
        // Original pairs with unique IDs
        let originalPairs = [
            (title: "Types of pollutant", definition: "Pollutants derived from non-living sources like chemicals and heavy metals.", id: 0),
            (title: "Water pollution", definition: "The contamination of water bodies by harmful substances, causing ecological damage.", id: 1),
            (title: "Sources of Water Pollution", definition: "Origins of contaminants that degrade water quality in natural water bodies.", id: 2),
            (title: "Plastic pollution", definition: "Categories of substances that contaminate air, water, or soil.", id: 3)
        ]
        
        // Create shuffled array with titles and definitions as separate cards
        var allCards: [(String, String, Int)] = []
        for pair in originalPairs {
            allCards.append((pair.title, "title", pair.id))
            allCards.append((pair.definition, "definition", pair.id))
        }
        items = allCards.shuffled()
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.5),
                heightDimension: .fractionalWidth(0.4)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalWidth(0.4)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            return section
        }
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(StudyCardCell.self, forCellWithReuseIdentifier: "StudyCardCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func checkForMatch() {
        guard flippedIndexPaths.count == 2 else { return }
        
        let flippedCards = Array(flippedIndexPaths).map { items[$0.item] }
        let firstCard = flippedCards[0]
        let secondCard = flippedCards[1]
        
        // Check if cards are a matching pair (same pairId but different types)
        let isMatch = firstCard.pairId == secondCard.pairId &&
                     firstCard.type != secondCard.type
        
        if isMatch {
            // Found a match
            matchedPairIds.insert(firstCard.pairId)
            flippedIndexPaths.removeAll()
            isProcessingMatch = false
            
            if matchedPairIds.count == Set(items.map { $0.pairId }).count {
                // Game completed
                showCompletionAlert()
            }
        } else {
            // No match, flip cards back
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else { return }
                self.flippedIndexPaths.forEach { indexPath in
                    if let cell = self.collectionView.cellForItem(at: indexPath) as? StudyCardCell {
                        cell.flipBack()
                    }
                }
                self.flippedIndexPaths.removeAll()
                self.isProcessingMatch = false
            }
        }
    }
    
    private func showCompletionAlert() {
        let alert = UIAlertController(
            title: "Congratulations!",
            message: "You've matched all the cards!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Play Again", style: .default) { [weak self] _ in
            self?.resetGame()
        })
        present(alert, animated: true)
    }
    
    private func resetGame() {
        flippedIndexPaths.removeAll()
        matchedPairIds.removeAll()
        isProcessingMatch = false
        setupData()
        collectionView.reloadData()
    }
}

extension StudyCardsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StudyCardCell", for: indexPath) as! StudyCardCell
        let item = items[indexPath.item]
        cell.configure(content: item.content, isMatched: matchedPairIds.contains(item.pairId))
        cell.isFlipped = flippedIndexPaths.contains(indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !isProcessingMatch,
              !matchedPairIds.contains(items[indexPath.item].pairId),
              !flippedIndexPaths.contains(indexPath) else { return }
        
        if flippedIndexPaths.count == 2 {
            flippedIndexPaths.removeAll()
        }
        
        flippedIndexPaths.insert(indexPath)
        
        if let cell = collectionView.cellForItem(at: indexPath) as? StudyCardCell {
            cell.flip()
        }
        
        if flippedIndexPaths.count == 2 {
            isProcessingMatch = true
            checkForMatch()
        }
    }
}

class StudyCardCell: UICollectionViewCell {
    private let cardView = UIView()
    private let frontView = UIView()
    private let backView = UIView()
    private let contentLabel = UILabel()
    
    var isFlipped = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Card container setup
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)
        
        // Front and back views
        [frontView, backView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .systemGray6
            $0.layer.cornerRadius = 8
            $0.clipsToBounds = true
            cardView.addSubview($0)
        }
        
        backView.backgroundColor = .systemBlue
        
        // Content label
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.numberOfLines = 0
        contentLabel.textAlignment = .center
        contentLabel.font = .systemFont(ofSize: 16)
        frontView.addSubview(contentLabel)
        
        // Constraints
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            frontView.topAnchor.constraint(equalTo: cardView.topAnchor),
            frontView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            frontView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            frontView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
            
            backView.topAnchor.constraint(equalTo: cardView.topAnchor),
            backView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            backView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            backView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
            
            contentLabel.topAnchor.constraint(equalTo: frontView.topAnchor, constant: 16),
            contentLabel.leadingAnchor.constraint(equalTo: frontView.leadingAnchor, constant: 16),
            contentLabel.trailingAnchor.constraint(equalTo: frontView.trailingAnchor, constant: -16),
            contentLabel.bottomAnchor.constraint(equalTo: frontView.bottomAnchor, constant: -16)
        ])
        
        // Initial state
        backView.isHidden = false
        frontView.isHidden = true
    }
    
    func configure(content: String, isMatched: Bool) {
        contentLabel.text = content
        if isMatched {
            frontView.backgroundColor = .systemGreen.withAlphaComponent(0.3)
        } else {
            frontView.backgroundColor = .systemGray6
        }
    }
    
    func flip() {
        let duration: TimeInterval = 0.5
        isFlipped = true
        
        UIView.transition(
            from: backView,
            to: frontView,
            duration: duration,
            options: [.transitionFlipFromRight, .showHideTransitionViews],
            completion: nil
        )
    }
    
    func flipBack() {
        let duration: TimeInterval = 0.5
        isFlipped = false
        
        UIView.transition(
            from: frontView,
            to: backView,
            duration: duration,
            options: [.transitionFlipFromLeft, .showHideTransitionViews],
            completion: nil
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isFlipped = false
        frontView.isHidden = true
        backView.isHidden = false
        frontView.backgroundColor = .systemGray6
    }
}
