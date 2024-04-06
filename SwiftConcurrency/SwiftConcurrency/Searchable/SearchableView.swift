//
//  SearchableView.swift
//  SwiftConcurrency
//
//  Created by Oleksandr Isaiev on 05.04.2024.
//

import SwiftUI

struct SearchableView: View {

    @StateObject private var viewModel = SearchableViewModel(manager: RestaurantManager())

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(viewModel.isSearching ? viewModel.filteredRestaurants : viewModel.allRestaurants) { restaurant in
//                    NavigationLink(value: restaurant) {
                        restaurantRow(restaurant: restaurant)
//                    }
                }
            }
            .padding(.leading, 20)
        }
        .searchable(text: $viewModel.searchText, placement: .automatic, prompt: "Search restaurants...")
        .searchScopes($viewModel.searchScope, scopes: {
            ForEach(viewModel.allSearchScopes, id:\.self) { scope in
                Text(scope.title)
                    .tag(scope)
            }
        })
        .searchSuggestions({
            ForEach(viewModel.getSearchSuggestions(), id: \.self) { suggestion in
                Text(suggestion)
                    .searchCompletion(suggestion)
            }
        })
//        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Restaurants")
        .navigationDestination(for: Restaurant.self) { restaurant in
            VStack(spacing: 10) {
                Text(restaurant.title.uppercased())
                Text(restaurant.cuisine.rawValue.uppercased())
            }
            .padding()
        }
        .task {
            await viewModel.loadRestaurants()
        }
    }

    private func restaurantRow(restaurant: Restaurant) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(restaurant.title)
                .font(.headline)
            Text(restaurant.cuisine.rawValue.capitalized)
                .font(.caption)
            Text(12, format: .currency(code: "USD"))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.05))
    }
}

#Preview {
    NavigationView {
        SearchableView()
    }
}
