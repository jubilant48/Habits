//
//  Settings.swift
//  Habits
//
//  Created by macbook on 23.05.2023.
//

import UIKit

// MARK: - Structures

struct Settnigs {
    // MARK: - Enmeration
    
    enum Setting {
        static let favoriteHabits = "favoriteHabits"
        static let followedUserIDs = "followedUserIDs"
    }
    
    // MARK: - Properties
    
    static var shared = Settnigs()
    
    private let defaults = UserDefaults.standard
    
    var favoriteHabits: [Habit] {
        get { return unarchiveJSON(key: Setting.favoriteHabits) ?? [] }
        set { archiveJSON(value: newValue, key: Setting.favoriteHabits) }
    }
    var followedUserIDs: [String] {
        get { return unarchiveJSON(key: Setting.followedUserIDs) ?? [] }
        set { archiveJSON(value: newValue, key: Setting.followedUserIDs) }
    }
    let currentUser = User(id: "user0", name: "Mikhail Dmitriev", color: nil, bio: nil)
    
    // MARK: - Methods
    
    private func archiveJSON<T: Encodable>(value: T, key: String) {
        let data = try! JSONEncoder().encode(value)
        let string = String(data: data, encoding: .utf8)
        
        defaults.set(string, forKey: key)
    }
    
    private func unarchiveJSON<T: Decodable>(key: String) -> T? {
        guard let string = defaults.string(forKey: key),
              let data = string.data(using: .utf8) else { return nil }
        
        return try! JSONDecoder().decode(T.self, from: data)
    }
    
    mutating func toggleFavorite(_ habit: Habit) {
        var favorites = favoriteHabits
        
        if favorites.contains(habit) {
            favorites = favorites.filter { $0 != habit }
        } else {
            favorites.append(habit)
        }
        
        favoriteHabits = favorites
    }
    
    mutating func toggleFollowed(user: User) {
        var updated = followedUserIDs
        
        if updated.contains(user.id) {
            updated = updated.filter { $0 != user.id }
        } else {
            updated.append(user.id)
        }
        
        followedUserIDs = updated
    }
}
