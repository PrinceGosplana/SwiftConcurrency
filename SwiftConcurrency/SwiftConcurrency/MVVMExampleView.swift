//
//  MVVMExampleView.swift
//  SwiftConcurrency
//
//  Created by Oleksandr Isaiev on 05.04.2024.
//

import SwiftUI

final class MyManagerClass {
    func getData() async throws -> String {
        "Some class data"
    }
}

actor MyManagerActor {
    func getData() async throws -> String {
        "Some actor data"
    }
}

@MainActor
final class MVVMViewModel: ObservableObject {

    let managerClass: MyManagerClass
    let managerActor: MyManagerActor

    @Published private(set) var myData: String = "Starting text"
    private var tasks: [Task<Void, Never>] = []

    init(managerClass: MyManagerClass, managerActor: MyManagerActor) {
        self.managerClass = managerClass
        self.managerActor = managerActor
    }

    func cancelTasks() {
        tasks.forEach { $0.cancel()}
        tasks = []
    }

    func onCalledActionButtonPressed() {
        let task = Task {
            do {
//                myData = try await managerClass.getData()
                myData = try await managerActor.getData()
            } catch {
                print(error.localizedDescription)
            }
        }
        tasks.append(task)
    }
}

struct MVVMExampleView: View {

    @StateObject private var viewModel = MVVMViewModel(managerClass: MyManagerClass(), managerActor: MyManagerActor())

    var body: some View {
        VStack {
            Button("Click me") {
                viewModel.onCalledActionButtonPressed()
            }
            Text(viewModel.myData)
        }
        .onDisappear {
            viewModel.cancelTasks()
        }
    }
}

#Preview {
    MVVMExampleView()
}
