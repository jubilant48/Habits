//
//  FollowedUserCollectionViewCell.swift
//  Habits
//
//  Created by macbook on 12.06.2023.
//

import UIKit

// MARK: - Class

final class FollowedUserCollectionViewCell: UICollectionViewCell {
    // MARK: - Outletes
    
    @IBOutlet var primaryTextLabel: UILabel!
    @IBOutlet var secondaryTextLabel: UILabel!
    @IBOutlet var seporatorLineView: UIView!
    @IBOutlet var separatorLineHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Life cycle
    
    override func awakeFromNib() {
        separatorLineHeightConstraint.constant = 1 / UITraitCollection.current.displayScale
    }
}
