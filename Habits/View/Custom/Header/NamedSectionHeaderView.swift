//
//  NamedSectionHeaderView.swift
//  Habits
//
//  Created by macbook on 23.05.2023.
//

import UIKit

// MARK: - Class

final class NamedSectionHeaderView: UICollectionReusableView {
    // MARK: - Properties
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.boldSystemFont(ofSize: 17)
        
        return label
    }()
    
    var _centerYConstraint: NSLayoutConstraint?
    var centerYConstraint: NSLayoutConstraint {
        if _centerYConstraint == nil {
            _centerYConstraint = nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        }
        
        return _centerYConstraint!
    }
    
    var _topYConstraint: NSLayoutConstraint?
    var topYConstraint: NSLayoutConstraint {
        if _topYConstraint == nil {
            _topYConstraint = nameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 12)
        }
        
        return _topYConstraint!
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Methods
    
    func alignLabelToTop() {
        topYConstraint.isActive = true
        centerYConstraint.isActive = false
    }
    
    func alignLabelToYCenter() {
        topYConstraint.isActive = false
        centerYConstraint.isActive = true
    }
    
    private func setupView() {
        // Congigure self
        backgroundColor = .systemGray5
        
        // Configure nameLabel
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Adding subview
        addSubview(nameLabel)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
        ])
        
        alignLabelToYCenter()
    }
}
