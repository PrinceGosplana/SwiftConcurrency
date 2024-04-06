//
//  SearchableViewModel.swift
//  SwiftConcurrency
//
//  Created by Oleksandr Isaiev on 05.04.2024.
//

import Combine
import SwiftUI

@MainActor
final class SearchableViewModel: ObservableObject {

    @Published private(set) var allRestaurants: [Restaurant] = []
    @Published private(set) var filteredRestaurants: [Restaurant] = []
    @Published var searchText: String = ""
    @Published var searchScope: SearchScopeOption = .all
    @Published private(set) var allSearchScopes: [SearchScopeOption] = []
    
    let manager: RestaurantManager
    private var cancellables = Set<AnyCancellable>()

    var isSearching: Bool {
        !searchText.isEmpty
    }

    var showSearchSuggestions: Bool {
        searchText.count < 3
    }

    enum SearchScopeOption: Hashable {
        case all
        case cuisine(option: CuisineOption)

        var title: String {
            switch self {
            case .all:
                return "All"
            case .cuisine(let option):
                return option.rawValue.capitalized
            }
        }
    }

    init(manager: RestaurantManager) {
        self.manager = manager
        addSubscribers()
    }

    private func addSubscribers() {
        $searchText
            .combineLatest($searchScope)
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] searchText, searchScope in
                self?.filterRestaurants(searchText: searchText, currentSearchScope: searchScope)
            }
            .store(in: &cancellables)
    }

    private func filterRestaurants(searchText: String, currentSearchScope: SearchScopeOption) {
        guard !searchText.isEmpty else {
            filteredRestaurants = []
            searchScope = .all
            return
        }

        // Filter on search scope
        var restaurantsInScope = allRestaurants
        switch currentSearchScope {
        case .all:
            break
        case .cuisine(let option):
            restaurantsInScope = allRestaurants.filter({ $0.cuisine == option })
        }

        // Filter on search text
        let search = searchText.lowercased()
        filteredRestaurants = restaurantsInScope.filter({ restaurant in
            let titleContainsSearch = restaurant.title.lowercased().contains(search)
            let cousinContainsSearch = restaurant.cuisine.rawValue.lowercased().contains(search)
            return titleContainsSearch || cousinContainsSearch
        })
    }

    func loadRestaurants() async {
        do {
            allRestaurants = try await manager.getAllRestaurants()

            let allCuisines = Set(allRestaurants.map { $0.cuisine })
            allSearchScopes = [.all] + allCuisines.map({ SearchScopeOption.cuisine(option: $0) })
        } catch {
            print(error.localizedDescription)
        }
    }

    func getSearchSuggestions() -> [String] {

        guard showSearchSuggestions else { return [] }
        
        var suggestions: [String] = []

        let search = searchText.lowercased()
        if search.contains("pa") {
            suggestions.append("Pasta")
        }
        if search.contains("su") {
            suggestions.append("Sushi")
        }
        if search.contains("bu") {
            suggestions.append("Burger")
        }
        suggestions.append("Market")
        suggestions.append(CuisineOption.american.rawValue.capitalized)
        suggestions.append(CuisineOption.italian.rawValue.capitalized)
        
        return suggestions
    }
}
