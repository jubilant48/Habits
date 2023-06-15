//
//  CombinedStatistics + Extension.swift
//  Habits
//
//  Created by macbook on 12.06.2023.
//

import UIKit

// MARK: - Structure

struct CombinedStatistics {
    let userStatistics: [UserStatistics]
    let habitStatistics: [HabitStatistics]
}

// MARK: - Extension

extension CombinedStatistics: Codable { }
