//
//  Helper.swift
//  Habits
//
//  Created by macbook on 12.06.2023.
//

import UIKit

// MARK: - Class

final class Helper {
    // MARK: - Properties
    
    static let formatter: NumberFormatter = {
        var f = NumberFormatter()
        f.numberStyle = .ordinal
        
        return f
    }()
    
    // MARK: - Methods
    
    static func userRankingString(from userCount: UserCount, currentUser: User, index: Int?) -> String {
        var name = userCount.user.name
        var ranking = ""
        
        if userCount.user.id == currentUser.id {
            name = "You"
            ranking = " (\(ordinalString(from: index!))) "
        }
        
        return "\(name) \(userCount.count)" + ranking
    }
    
    static func loggedHabitNames(for user: User, statistics: [UserStatistics]) -> Set<String> {
        var names = [String]()
        
        if let stats = statistics.first(where: { $0.user == user }) {
            names = stats.habitCounts.map { $0.habit.name }
        }
        
        return Set(names)
    }
    
    static func ordinalString(from number: Int) -> String {
        return Self.formatter.string(from: NSNumber(integerLiteral: number + 1))!
    }
}
