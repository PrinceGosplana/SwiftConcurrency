//
//  AsyncPublisherView.swift
//  SwiftConcurrency
//
//  Created by Oleksandr Isaiev on 04.04.2024.
//

import SwiftUI

actor AsyncPublisherDataManager {
    
    @Published var myData: [String] = []

    func addData() async {
        myData.append("Apple")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Banana")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Orange")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Watermelon")
    }
}

final class AsyncPublisherViewModel: ObservableObject {
    @MainActor @Published var dataArray: [String] = []
    private let manager: AsyncPublisherDataManager

    init(manager: AsyncPublisherDataManager) {
        self.manager = manager
        addSubscribers()
    }

    private func addSubscribers() {

        Task {
            for await value in await manager.$myData.values {
                await MainActor.run {
                    self.dataArray = value
                }
            }
        }
    }

    func start() async {
        await manager.addData()
    }
}

struct AsyncPublisherView: View {

    @StateObject private var viewModel = AsyncPublisherViewModel(manager: AsyncPublisherDataManager())

    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.dataArray, id: \.self) {
                    Text($0)
                        .font(.headline)
                }
            }
        }
        .task {
            await viewModel.start()
        }
    }
}

#Preview {
    AsyncPublisherView()
}
