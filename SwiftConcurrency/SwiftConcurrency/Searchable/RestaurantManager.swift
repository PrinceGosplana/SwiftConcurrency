//
//  RestaurantManager.swift
//  SwiftConcurrency
//
//  Created by Oleksandr Isaiev on 05.04.2024.
//

import SwiftUI

enum CuisineOption: String {
    case american, italian, japanese
}

struct Restaurant: Identifiable, Hashable {
    let id: String
    let title: String
    let cuisine: CuisineOption
}

actor RestaurantManager {
    func getAllRestaurants() async throws -> [Restaurant] {
        [
            Restaurant(id: "1", title: "Burger Shack", cuisine: .american),
            Restaurant(id: "2", title: "Pasta Palace", cuisine: .italian),
            Restaurant(id: "3", title: "Sushi Heaven", cuisine: .japanese),
            Restaurant(id: "4", title: "Local Market", cuisine: .american),
        ]
    }
}
