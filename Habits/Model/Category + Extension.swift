//
//  Category + Extension.swift
//  Habits
//
//  Created by macbook on 11.05.2023.
//

import UIKit

// MARK: - Structure

struct Category {
    let name: String
    let color: Color
}

// MARK: - Extension

extension Category: Codable {}

extension Category: Hashable {
    func hash(into hasher: inout Hasher) {
        return hasher.combine(name)
    }
    
    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.name == rhs.name
    }
}
