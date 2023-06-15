//
//  APIRequestError.swift
//  Habits
//
//  Created by macbook on 11.05.2023.
//

import UIKit

// MARK: - Enumeration

enum APIRequestError: Error {
    case itemsNotFound
    case requestFailed
}
