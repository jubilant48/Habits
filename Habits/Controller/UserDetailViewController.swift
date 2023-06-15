//
//  UserDetailViewController.swift
//  Habits
//
//  Created by macbook on 11.05.2023.
//

import UIKit

final class UserDetailViewController: UIViewController {
    // MARK: - Structure
    
    struct Model {
        var userStats: UserStatistics?
        var leadingStats: UserStatistics?
    }
    
    // MARK: - Enmeration
    
    enum ViewModel {
        enum Section: Hashable, Comparable {

            case leading
            case category(_ category: Category)
            
            var sectionColor: UIColor {
                switch self {
                case .leading:
                    return .systemGray4
                case .category(let category):
                    return category.color.uiColor
                }
            }
            
            static func < (_ lhs: Section, _ rhs: Section) -> Bool {
                switch (lhs, rhs) {
                case (.leading, .category), (.leading, .leading):
                    return true
                case (.category, .leading):
                    return false
                case (.category(let category1), .category(let category2)):
                    return category1.name > category2.name
                }
            }
        }
        
        typealias Item = HabitCount
    }
    
    enum SectionHeader: String {
        case kind = "SectionHeader"
        case reuse = "HeaderView"
        
        var identifier: String { rawValue }
    }
    
    // MARK: - Outletes

    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var bioLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    
    // MARK: - Properties
    
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    var imageRequestTask: Task<Void, Never>? = nil
    var userStatisticsRequestTask: Task<Void, Never>? = nil
    var habitLeadStatisticsRequestTask: Task<Void, Never>? = nil
    
    var dataSource: DataSourceType!
    var model = Model()
    
    var user: User!
    var updateTimer: Timer?
    
    // MARK: - Init
    
    init?(coder: NSCoder, user: User) {
        self.user = user
        
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        imageRequestTask?.cancel()
        userStatisticsRequestTask?.cancel()
        habitLeadStatisticsRequestTask?.cancel()
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = user.color?.uiColor ?? .white
        
        let tabBarApperance = UITabBarAppearance()
        tabBarApperance.backgroundColor = .quaternarySystemFill
        tabBarController?.tabBar.scrollEdgeAppearance = tabBarApperance
        
        let navBarApperance = UINavigationBarAppearance()
        navBarApperance.backgroundColor = .quaternarySystemFill
        navigationItem.scrollEdgeAppearance = navBarApperance
        
        userNameLabel.text = user.name
        bioLabel.text = user.bio
        
        collectionView.register(NamedSectionHeaderView.self, forSupplementaryViewOfKind: SectionHeader.kind.identifier, withReuseIdentifier: SectionHeader.reuse.identifier)
        
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = createLayout()
        
        imageRequestTask = Task {
            if let image = try? await ImageRequest(imageID: user.id).send() {
                self.profileImageView.image = image
            }
            
            imageRequestTask = nil
        }
        
        update()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        update()
        
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.update()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    // MARK: - Methods
    
    private func update() {
        userStatisticsRequestTask?.cancel()
        userStatisticsRequestTask = Task {
            if let userStats = try? await UserStatisticsRequest(userIDs: [user.id]).send(),
               userStats.count > 0 {
                self.model.userStats = userStats[0]
            } else {
                self.model.userStats = nil
            }
            
            self.updateCollectionView()
            
            userStatisticsRequestTask = nil
        }
        
        habitLeadStatisticsRequestTask?.cancel()
        habitLeadStatisticsRequestTask = Task {
            if let userStats = try? await HabitLeadStatisticsRequest(userID: user.id).send() {
                self.model.leadingStats = userStats
            } else {
                self.model.leadingStats = nil
            }
            
            self.updateCollectionView()
            
            habitLeadStatisticsRequestTask = nil
        }
    }
    
    private func updateCollectionView() {
        guard let userSatatistics = model.userStats,
              let leadingStatistics = model.leadingStats else { return }
        
        var itemsBySection = userSatatistics.habitCounts.reduce(into: [ViewModel.Section : [ViewModel.Item]]()) { partial, habitCount in
            let section: ViewModel.Section
            
            if leadingStatistics.habitCounts.contains(habitCount) {
                section = .leading
            } else {
                section = .category(habitCount.habit.category)
            }
            
            partial[section, default: []].append(habitCount)
        }
        
        itemsBySection = itemsBySection.mapValues { $0.sorted() }
        
        let sectionIDs = itemsBySection.keys.sorted()
        
        dataSource.applySnapshotUsing(sectionIDs: sectionIDs, itemsBySection: itemsBySection)
    }
}

// MARK: - Compositional Layout

extension UserDetailViewController {
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 12)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(44))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(36))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: SectionHeader.kind.identifier, alignment: .top)
        sectionHeader.pinToVisibleBounds = true
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0)
        section.boundarySupplementaryItems = [sectionHeader]
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

// MARK: - Diffabel data source

extension UserDetailViewController {
    private func createDataSource() -> DataSourceType {
        let dataSource = DataSourceType(collectionView: collectionView) { collectionView, indexPath, habitStat in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HabitCount", for: indexPath) as! UICollectionViewListCell
            
            var content = UIListContentConfiguration.subtitleCell()
            content.text = habitStat.habit.name
            content.secondaryText = "\(habitStat.count)"
            
            content.prefersSideBySideTextAndSecondaryText = true
            content.textProperties.font = .preferredFont(forTextStyle: .headline)
            content.secondaryTextProperties.font = .preferredFont(forTextStyle: .body)
            
            cell.contentConfiguration = content
            
            return cell
        }
        
        dataSource.supplementaryViewProvider = { (collectionView, category, indexPath) -> UICollectionReusableView  in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: SectionHeader.kind.identifier, withReuseIdentifier: SectionHeader.reuse.identifier, for: indexPath) as! NamedSectionHeaderView
            
            let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
            
            switch section {
            case .leading:
                header.nameLabel.text = "Leading"
            case .category(let category):
                header.nameLabel.text = category.name
            }
            
            header.backgroundColor = section.sectionColor
            
            return header
        }
        
        return dataSource
    }
}
