//
//  UserCount + Extension.swift
//  Habits
//
//  Created by macbook on 31.05.2023.
//

import UIKit

// MARK: - Structure

struct UserCount {
    let user: User
    let count: Int
}

// MARK: - Extension

extension UserCount: Codable { }

extension UserCount: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(user)
    }
    
    static func ==(_ lhs: UserCount, _ rhs: UserCount) -> Bool {
        return lhs.user == rhs.user
    }
}
