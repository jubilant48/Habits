//
//  HabitCollectionViewController.swift
//  Habits
//
//  Created by macbook on 11.05.2023.
//

import UIKit

let favoriteHabitColor = UIColor(hue: 0.15, saturation: 1,
   brightness: 0.9, alpha: 1)

class HabitCollectionViewController: UICollectionViewController {
    // MARK: - Structures
    
    struct Model {
        var habitsByName = [String: Habit]()
        var favoriteHabits: [Habit] { Settnigs.shared.favoriteHabits }
    }
    
    // MARK: - Enumerations
    
    enum ViewModel {
        enum Section: Hashable, Comparable {
            case favorites
            case category(_ category: Category)
            
            var sectionColor: UIColor {
                switch self {
                case .favorites:
                    return favoriteHabitColor
                case .category(let category):
                    return category.color.uiColor
                }
            }
            
            static func < (lhs: Section, rhs: Section) -> Bool {
                switch (lhs, rhs) {
                case (.category(let l), .category(let r)):
                    return l.name < r.name
                case (.favorites, _):
                    return true
                case (_, .favorites):
                    return false
                }
            }
        }
        
        typealias Item = Habit
    }
    
    enum SectionHeader: String {
        case kind = "SectionHeader"
        case reuse = "HeaderView"
        
        var identifier: String { rawValue }
    }
    
    // MARK: - Properties
    
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    var dataSource: DataSourceType!
    var model = Model()
    var habitsRequestTask: Task<Void, Never>? = nil
    
    // MARK: - Init
    
    deinit { habitsRequestTask?.cancel() }
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = createDaraSource()
        
        collectionView.register(NamedSectionHeaderView.self, forSupplementaryViewOfKind: SectionHeader.kind.identifier, withReuseIdentifier: SectionHeader.reuse.identifier)
        
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = createLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        update()
    }
    
    // MARK: - Segue
    
    @IBSegueAction func showHabitDetail(_ coder: NSCoder, sender: UICollectionViewCell?) -> HabitDetailViewController? {
        guard let cell = sender,
              let indexPath = collectionView.indexPath(for: cell),
              let item = dataSource.itemIdentifier(for: indexPath) else { return nil }
        
        return HabitDetailViewController(coder: coder, habit: item)
    }
    
    // MARK: - Collection view delegate

    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let item = self.dataSource.itemIdentifier(for: indexPath)!
            
            let favoriteToggle = UIAction(title: self.model.favoriteHabits.contains(item) ? "Unfavorite": "Favorite") { action in
                Settnigs.shared.toggleFavorite(item)
                self.updateCollectionView()
            }
            
            return UIMenu(title: "", image: nil, identifier: nil, options: [], children: [favoriteToggle])
        }
        
        return config
    }
    
    // MARK: - Methods
    
    private func update() {
        habitsRequestTask?.cancel()
        
        habitsRequestTask = Task {
            if let habits = try? await HabitReuest().send() {
                self.model.habitsByName = habits
            } else {
                self.model.habitsByName = [:]
            }
            
            self.updateCollectionView()
            
            habitsRequestTask = nil
        }
    }
    
    private func updateCollectionView() {
        var itemsBySection = model.habitsByName.values.reduce(into: [ViewModel.Section: [ViewModel.Item]]()) { partial, habit in
            let item = habit
            
            let section: ViewModel.Section
            
            if model.favoriteHabits.contains(habit) {
                section = .favorites
            } else {
                section = .category(habit.category)
            }
            
            partial[section, default: []].append(item)
        }
        
        itemsBySection = itemsBySection.mapValues { $0.sorted() }
        let sectionIDs = itemsBySection.keys.sorted()
        
        dataSource.applySnapshotUsing(sectionIDs: sectionIDs, itemsBySection: itemsBySection)
    }
    
   // MARK: - Compositional layout

    func createLayout() -> UICollectionViewCompositionalLayout {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(36))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: SectionHeader.kind.identifier, alignment: .top)
        sectionHeader.pinToVisibleBounds = true

        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(44))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        section.boundarySupplementaryItems = [sectionHeader]

        return UICollectionViewCompositionalLayout(section: section)
    }
    
    // MARK: - Diffabel data source
    
    func configureCell(_ cell: UICollectionViewListCell, withItem item: ViewModel.Item) {
        var content = cell.defaultContentConfiguration()
        content.text = item.name
        cell.contentConfiguration = content
    }
    
    func createDaraSource() -> DataSourceType {
        let dataSource = DataSourceType(collectionView: collectionView) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Habit", for: indexPath) as! UICollectionViewListCell
            
            self.configureCell(cell, withItem: item)
            
            return cell
        }
        
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: SectionHeader.kind.identifier, withReuseIdentifier: SectionHeader.reuse.identifier, for: indexPath) as! NamedSectionHeaderView
            
            let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
            
            switch section {
            case .favorites:
                header.nameLabel.text = "Favorites"
            case .category(let category):
                header.nameLabel.text = category.name
            }
            
            header.backgroundColor = section.sectionColor
            
            return header
        }
        
        return dataSource
    }
}

