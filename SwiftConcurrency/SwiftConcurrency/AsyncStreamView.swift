//
//  AsyncStreamView.swift
//  SwiftConcurrency
//
//  Created by Oleksandr Isaiev on 06.04.2024.
//

import SwiftUI

final class AsyncStreamDataManager {

    func getAsyncStream() -> AsyncThrowingStream<Int, Error> {
        AsyncThrowingStream { [weak self] continuation in
            self?.getFakeData(newValue: { value in
                continuation.yield(value)
            }, onFinish: { error in
                continuation.finish(throwing: error)
            })
        }
    }

    func getFakeData(
        newValue: @escaping (_ value: Int) -> Void,
        onFinish: @escaping (_ error: Error?) -> Void
    ) {
        let items = [1, 2, 3, 4, 5, 6,7, 8, 9, 10]

        for item in items {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(item)) {
                newValue(item)

                if item == items.last {
                    onFinish(nil)
                }
            }
        }
    }
}

@MainActor
final class AsyncStreamViewModel: ObservableObject {

    @Published private(set) var currentNumber: Int = 0
    let manager: AsyncStreamDataManager

    init(manager: AsyncStreamDataManager) {
        self.manager = manager
    }

    func onViewAppear() {
//        manager.getFakeData { [weak self] value in
//            self?.currentNumber = value
//        }

       let task = Task {
            do {
                for try await value in manager.getAsyncStream() {
                    currentNumber = value
                }
            } catch {
                print(error)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            task.cancel()
        }
    }
}

struct AsyncStreamView: View {

    @StateObject private var viewModel = AsyncStreamViewModel(manager: AsyncStreamDataManager())

    var body: some View {
        Text("\(viewModel.currentNumber)")
            .onAppear {
                viewModel.onViewAppear()
            }
    }
}

#Preview {
    AsyncStreamView()
}
