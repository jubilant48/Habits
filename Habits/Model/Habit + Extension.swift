//
//  Habit + Extension.swift
//  Habits
//
//  Created by macbook on 11.05.2023.
//

import UIKit

// MARK: - Structure

struct Habit {
    let name: String
    let category: Category
    let info: String
}

// MARK: - Extension

extension Habit: Codable {}

extension Habit: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: Habit, rhs: Habit) -> Bool {
        return lhs.name == rhs.name
    }
}

extension Habit: Comparable {
    static func < (lhs: Habit, rhs: Habit) -> Bool {
        lhs.name < rhs.name
    }
}
