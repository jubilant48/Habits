//
//  SupplementaryItem + Extension.swift
//  Habits
//
//  Created by macbook on 15.06.2023.
//

import UIKit

// MARK: - Protocol

protocol SupplementaryItem {
    associatedtype ViewClass: UICollectionReusableView
    
    var itemType: SupplementaryItemType { get }
    
    var reuseIdentifier: String { get }
    var viewKind: String { get }
    var viewClass: ViewClass.Type { get }
}

// MARK: - Extension

extension SupplementaryItem {
    func register(on collectionView: UICollectionView) {
        switch itemType {
        case .collectionSupplementaryView:
            collectionView.register(viewClass.self, forSupplementaryViewOfKind: viewKind, withReuseIdentifier: reuseIdentifier)
        case .layoutDecorationView:
            collectionView.collectionViewLayout.register(viewClass.self, forDecorationViewOfKind: viewKind)
        }
    }
}
