//
//  GlobalActorView.swift
//  SwiftConcurrency
//
//  Created by Oleksandr Isaiev on 04.04.2024.
//

import SwiftUI

@globalActor final class MyGlobalActor {
    static var shared = NewDataManager()
}

actor NewDataManager {
    
    func getDataFromDatabase() -> [String] {
        ["Paul", "Victor", "Jessica"]
    }
}

final class GlobalActorViewModel: ObservableObject {

    @MainActor @Published var dataArray: [String] = []
    let manager: NewDataManager

    init(manager: NewDataManager) {
        self.manager = manager
    }

    @MyGlobalActor func getData() async {
        let data = await manager.getDataFromDatabase()
        await MainActor.run {
            self.dataArray = data
        }
    }
}

struct GlobalActorView: View {

    @StateObject private var viewModel = GlobalActorViewModel(manager: MyGlobalActor.shared)

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
            await viewModel.getData()
        }
    }
}

#Preview {
    GlobalActorView()
}
