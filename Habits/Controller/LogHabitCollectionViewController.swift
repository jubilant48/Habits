//
//  LogHabitCollectionViewController.swift
//  Habits
//
//  Created by macbook on 11.05.2023.
//

import UIKit


final class LogHabitCollectionViewController: HabitCollectionViewController {
    // MARK: - Collection view delegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        
        let loggedHabit = LoggedHabit(userID: Settnigs.shared.currentUser.id, habitName: item.name, timestamp: Date())
        
        Task {
            try? await LogHabitRequest(loggedHabit: loggedHabit).send()
        }
    }
    
    // MARK: - Compotisional latout
    
    override func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, enviroment) -> NSCollectionLayoutSection? in
            if sectionIndex == 0 && self.model.favoriteHabits.count > 0 {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.45), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(100))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0)
                
                return section
            } else {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = .fixed(8)
                group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(36))
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: SectionHeader.kind.identifier, alignment: .top)
                sectionHeader.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: nil, top: nil, trailing: nil, bottom: .fixed(40))
                sectionHeader.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0)
                section.boundarySupplementaryItems = [sectionHeader]
                section.interGroupSpacing = 10
                
                return section
            }
        }
    }
    
    // MARK: - Diffabel data source
    
    override func configureCell(_ cell: UICollectionViewListCell, withItem item: HabitCollectionViewController.ViewModel.Item) {
        cell.configurationUpdateHandler = { cell, state in
            var content = UIListContentConfiguration.cell().updated(for: state)
            content.text = item.name
            content.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 11, leading: 8, bottom: 11, trailing: 8)
            content.textProperties.alignment = .center
            cell.contentConfiguration = content
            
            var backgroundConfiguration = UIBackgroundConfiguration.listPlainCell().updated(for: state)
            
            if Settnigs.shared.favoriteHabits.contains(item) {
                backgroundConfiguration.backgroundColor = favoriteHabitColor
            } else {
                backgroundConfiguration.backgroundColor = .systemGray6
            }
            
            if state.isHighlighted {
                backgroundConfiguration.backgroundColorTransformer = .init { $0.withAlphaComponent(0.3) }
            }
            
            backgroundConfiguration.cornerRadius = 8
            cell.backgroundConfiguration = backgroundConfiguration
        }
        
        cell.layer.shadowRadius = 0.3
        cell.layer.shadowColor = UIColor.systemGray3.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.shadowOpacity = 1
        cell.layer.masksToBounds = false
    }
}


