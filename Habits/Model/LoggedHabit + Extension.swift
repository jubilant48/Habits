//
//  LoggedHabit + Extension.swift
//  Habits
//
//  Created by macbook on 06.06.2023.
//

import UIKit

// MARK: - Structure

struct LoggedHabit {
    let userID: String
    let habitName: String
    let timestamp: Date
}

// MARK: - Extension

extension LoggedHabit: Codable { }
