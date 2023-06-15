//
//  Color + Extension.swift
//  Habits
//
//  Created by macbook on 11.05.2023.
//

import UIKit

// MARK: - Structure

struct Color {
    let hue: Double
    let saturation: Double
    let brightness: Double
}

// MARK: - Extension

extension Color: Codable {
    // MARK: - Enumeration
    
    enum CodingKeys: String, CodingKey {
        case hue = "h"
        case saturation = "s"
        case brightness = "b"
    }
}

extension Color {
    var uiColor: UIColor {
        return UIColor(hue: CGFloat(hue), saturation: CGFloat(saturation), brightness: CGFloat(brightness), alpha: 1)
    }
}

extension Color: Hashable { }
