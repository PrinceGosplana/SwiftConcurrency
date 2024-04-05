//
//  RefreshableView.swift
//  SwiftConcurrency
//
//  Created by Oleksandr Isaiev on 05.04.2024.
//

import SwiftUI

/*
actor RefreshableDataService {

    func getData() throws -> [String] {
        ["Garry", "Hermione", "Grizly"].shuffled()
    }
}

@MainActor
final class RefreshableViewModel: ObservableObject {
    @Published private(set) var items: [String] = []
    private let service: RefreshableDataService

    init(service: RefreshableDataService) {
        self.service = service
    }

    func loadData() {
        Task {
            do {
                items = try await service.getData()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

struct RefreshableView: View {

    @StateObject private var viewModel = RefreshableViewModel(service: RefreshableDataService())

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    ForEach(viewModel.items, id: \.self) { item in
                        Text(item)
                            .font(.headline)
                    }
                }
            }
            .refreshable {
                viewModel.loadData()
            }
            .navigationTitle("Refreshable")
            .onAppear {
                viewModel.loadData()
            }
        }
    }
}
*/

actor RefreshableDataService {

    func getData() async throws -> [String] {
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        return ["Garry", "Hermione", "Grizly"].shuffled()
    }
}

@MainActor
final class RefreshableViewModel: ObservableObject {
    @Published private(set) var items: [String] = []
    private let service: RefreshableDataService

    init(service: RefreshableDataService) {
        self.service = service
    }

    func loadData() async {
        do {
            items = try await service.getData()
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct RefreshableView: View {

    @StateObject private var viewModel = RefreshableViewModel(service: RefreshableDataService())

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    ForEach(viewModel.items, id: \.self) { item in
                        Text(item)
                            .font(.headline)
                    }
                }
            }
            .refreshable {
               await viewModel.loadData()
            }
            .navigationTitle("Refreshable")
            .task {
                await viewModel.loadData()
            }
        }
    }
}
#Preview {
    RefreshableView()
}
