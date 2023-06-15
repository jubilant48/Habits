//
//  HabitDetailViewController.swift
//  Habits
//
//  Created by macbook on 11.05.2023.
//

import UIKit

final class HabitDetailViewController: UIViewController {
    // MARK: - Structure
    
    struct Model {
        var habitStaticts: HabitStatistics?
        var userCounts: [UserCount] { habitStaticts?.userCounts ?? [] }
    }
    
    // MARK: - Enumeration
    
    enum ViewModel {
        enum Section: Hashable {
            case leaders(count: Int)
            case remaining
        }
        
        enum Item: Hashable, Comparable {
            case single(_ stat: UserCount)
            case multiple(_ stats: [UserCount])
            
            static func < (_ lhs: Item, _ rhs: Item) -> Bool {
                switch (lhs, rhs) {
                case (.single(let lCount), .single(let rCount)):
                    return lCount.count < rCount.count
                case (.multiple(let lCounts), .multiple(let rCounts)):
                    return lCounts.first!.count < rCounts.first!.count
                case (.single, .multiple):
                    return false
                case (.multiple, .single):
                    return true
                }
            }
        }
    }
    
    // MARK: - Outletes
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    
    // MARK: - Properties
    
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    var habitStatisticsRequestTask: Task<Void, Never>? = nil
    
    var dataSource: DataSourceType!
    var model = Model()
    
    var habit: Habit!
    var updateTimer: Timer?
    
    // MARK: - Init
    
    init?(coder: NSCoder, habit: Habit) {
        self.habit = habit
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit { habitStatisticsRequestTask?.cancel() }
    
    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = habit.name
        categoryLabel.text = habit.category.name
        infoLabel.text = habit.info
        
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = createLayout()
        
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
        habitStatisticsRequestTask?.cancel()
        
        habitStatisticsRequestTask = Task {
            if let statistics = try? await HabitStatisticsRequest(habitNames: [habit.name]).send(),
               statistics.count > 0 {
                self.model.habitStaticts = statistics[0]
            } else {
                self.model.habitStaticts = nil
            }
            
            self.updateCollectionView()
            
            habitStatisticsRequestTask = nil
        }
    }
    
    private func updateCollectionView() {
        let items = (self.model.habitStaticts?.userCounts.map { ViewModel.Item.single($0) } ?? []).sorted(by: >)
        
        dataSource.applySnapshotUsing(sectionIDs: [.remaining], itemsBySection: [.remaining: items])
    }
}

// MARK: - Compositional layout

extension HabitDetailViewController {
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 12)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(44))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

// MARK: - Diffable data source

extension HabitDetailViewController {
    private func createDataSource() -> DataSourceType {
        return DataSourceType(collectionView: collectionView) { collectionView, indexPath, grouping in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserCount", for: indexPath) as! UICollectionViewListCell
            
            var content = UIListContentConfiguration.subtitleCell()
            content.prefersSideBySideTextAndSecondaryText = true
            
            switch grouping {
            case .single(let userStat):
                content.text = userStat.user.name
                content.secondaryText = "\(userStat.count)"
                content.textProperties.font = .preferredFont(forTextStyle: .headline)
                content.secondaryTextProperties.font = .preferredFont(forTextStyle: .body)
            default:
                break
            }
            
            cell.contentConfiguration = content
            
            return cell
        }
    }
}
