//
//  UserStatisticts + Extension.swift
//  Habits
//
//  Created by macbook on 06.06.2023.
//

import UIKit

// MARK: - Structure

struct UserStatistics {
    let user: User
    let habitCounts: [HabitCount]
}

// MARK: - Extension

extension UserStatistics: Codable { }
