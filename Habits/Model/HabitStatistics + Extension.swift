//
//  HabitStatistics + Extension.swift
//  Habits
//
//  Created by macbook on 31.05.2023.
//

import UIKit

// MARK: - Structure

struct HabitStatistics {
    let habit: Habit
    let userCounts: [UserCount]
}

// MARK: - Extension

extension HabitStatistics: Codable { }
