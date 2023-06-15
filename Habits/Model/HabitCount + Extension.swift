//
//  HabitCount + Extension.swift
//  Habits
//
//  Created by macbook on 06.06.2023.
//

import UIKit

// MARK: - Structure

struct HabitCount {
    let habit: Habit
    let count: Int
}

// MARK: - Extension

extension HabitCount: Codable { }

extension HabitCount: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(habit)
    }
    
    static func ==(_ lhs: HabitCount, _ rhs: HabitCount) -> Bool {
        return lhs.habit == rhs.habit
    }
}

extension HabitCount: Comparable {
    static func < (lhs: HabitCount, rhs: HabitCount) -> Bool {
        return lhs.habit < rhs.habit
    }
}
