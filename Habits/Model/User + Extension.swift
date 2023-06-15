//
//  User + Extension.swift
//  Habits
//
//  Created by macbook on 31.05.2023.
//

import UIKit

// MARK: - Structure

struct User {
    let id: String
    let name: String
    let color: Color?
    let bio: String?
}

// MARK: - Extension

extension User: Codable { }

extension User: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}

extension User: Comparable {
    static func < (lhs: User, rhs: User) -> Bool {
        return lhs.name < rhs.name
    }
}

