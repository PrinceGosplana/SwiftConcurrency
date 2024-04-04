//
//  AsyncAwaitView.swift
//  SwiftConcurrency
//
//  Created by Oleksandr Isaiev on 03.04.2024.
//

import SwiftUI

final class AsyncAwaitViewModel: ObservableObject {
    @Published var dataArray: [String] = []

    func addTitle1() async {
        let title = "Title 1 - \(Thread.current)"
        self.dataArray.append(title)

        try? await Task.sleep(nanoseconds: 2_000_000_000)

        let title2 = "Title 2 - \(Thread.current)"

        await MainActor.run {
            self.dataArray.append(title2)

            let title3 = "Title 3 - \(Thread.current)"
            self.dataArray.append(title3)
        }
    }

    func addSomething() async {
        try? await Task.sleep(nanoseconds: 2_000_000_000)

        let something1 = "Something 1 - \(Thread.current)"

        await MainActor.run {
            self.dataArray.append(something1)

            let something2 = "Something 2 - \(Thread.current)"
            self.dataArray.append(something2)
        }
    }
}

struct AsyncAwaitView: View {

    @StateObject private var viewModel = AsyncAwaitViewModel()

    var body: some View {
        List {
            ForEach(viewModel.dataArray, id: \.self) { data in
                Text(data)
            }
        }
        .onAppear {
            Task {
                await viewModel.addTitle1()
                await viewModel.addSomething()
                let finalText = "FINAL TITLE - \(Thread.current)"
                viewModel.dataArray.append(finalText)
            }
        }
    }
}

#Preview {
    AsyncAwaitView()
}
