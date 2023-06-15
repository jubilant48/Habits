//
//  ImageRequestError.swift
//  Habits
//
//  Created by macbook on 06.06.2023.
//

import UIKit

// MARK: - Enumeration

enum ImageRequestError: Error {
    case couldNotInitializeFromData
    case imageDataMissing
}

