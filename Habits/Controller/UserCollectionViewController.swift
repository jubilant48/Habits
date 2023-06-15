//
//  UserCollectionViewController.swift
//  Habits
//
//  Created by macbook on 11.05.2023.
//

import UIKit

final class UserCollectionViewController: UICollectionViewController {
    // MARK: - Strucure
    
    struct Model {
        var usersByID = [String: User]()
        var followedUsers: [User] {
            return Array(usersByID.filter { Settnigs.shared.followedUserIDs.contains($0.key) }.values )
        }
    }
    
    // MARK: - Enumerations
    
    enum ViewModel {
        typealias Section = Int
        
        struct Item: Hashable {
            let user: User
            let isFollowed: Bool
            
            func hash(into hasher: inout Hasher) {
                hasher.combine(user)
            }
            
            static func ==(_ lhs: Item, _ rhs: Item) -> Bool {
                return lhs.user == rhs.user
            }
        }
    }
    
    // MARK: - Properties
    
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    var usersRequestTask: Task<Void, Never>? = nil
    
    var dataSource: DataSourceType!
    var model = Model()
    
    
    // MARK:  - Init
    
    deinit { usersRequestTask?.cancel() }

    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = createLayout()
        
        update()
    }
    
    // MARK: - Segue
    
    @IBSegueAction func showUserDetail(_ coder: NSCoder, sender: UICollectionViewCell?) -> UserDetailViewController? {
        guard let cell = sender,
              let indexPath = collectionView.indexPath(for: cell),
              let item = dataSource.itemIdentifier(for: indexPath) else { return nil }
        
        return UserDetailViewController(coder: coder, user: item.user)
    }
    
    // MARK: - Collection view delegate
    
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { elements in
            guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return nil }
            
            let favoriteToggle = UIAction(title: item.isFollowed ? "Unfollow" : "Follow") { action in
                Settnigs.shared.toggleFollowed(user: item.user)
                self.updateCollectionView()
            }
            
            return UIMenu(title: "", image: nil, identifier: nil, options: [], children: [favoriteToggle]) 
        }
        
        return config
    }
    
    // MARK: - Methods
    
    private func update() {
        usersRequestTask?.cancel()
        
        usersRequestTask = Task {
            if let users = try? await UserRequest().send() {
                self.model.usersByID = users
            } else {
                self.model.usersByID = [:]
            }
            
            self.updateCollectionView()
            
            usersRequestTask = nil
        }
    }
    
    private func updateCollectionView() {
        let users = self.model.usersByID.values.sorted().reduce(into: [ViewModel.Item]()) { partial, user in
            partial.append(ViewModel.Item(user: user, isFollowed: model.followedUsers.contains(user)))
        }
        
        let itemsBySection = [0: users]
        
        dataSource.applySnapshotUsing(sectionIDs: [0], itemsBySection: itemsBySection)
    }
}

// MARK: - Compositional layout

extension UserCollectionViewController {
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalHeight(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.45))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(20)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 20
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

// MARK: - Diffable data source

extension UserCollectionViewController {
    private func createDataSource() -> DataSourceType {
        let dataSource = DataSourceType(collectionView: collectionView) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "User", for: indexPath) as! UICollectionViewListCell
            
            var content = cell.defaultContentConfiguration()
            content.text = item.user.name
            content.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 11, leading: 8, bottom: 11, trailing: 8)
            content.textProperties.alignment = .center
            cell.contentConfiguration = content
            
            var backgroundConfiguration = UIBackgroundConfiguration.clear()
            backgroundConfiguration.backgroundColor = item.user.color?.uiColor ?? UIColor.systemGray4
            backgroundConfiguration.cornerRadius = 8
            
            cell.backgroundConfiguration = backgroundConfiguration
            
            return cell
        }
        
        return dataSource
    }
}
