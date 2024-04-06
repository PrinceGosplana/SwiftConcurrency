//
//  NewObservable.swift
//  SwiftConcurrency
//
//  Created by Oleksandr Isaiev on 06.04.2024.
//

import SwiftUI
/// work only if iOS 17
/*
actor TitleDataBase {

    func getNewTitle() -> String {
        "Some actor title"
    }
}

@Observable
final class ObservableViewModel {

    @MainActor var title: String = "Starting title"
    @ObservationIgnored private let database: TitleDataBase

    init(database: TitleDataBase) {
        self.database = database
    }

//    @MainActor
    func updateTitle() {
        /// Solution when the whole func is MainActor
        /*
        let title = await database.getNewTitle()

        await MainActor.run {
            self.title = title
        }
         */

        Task { @MainActor in
            title = await database.getNewTitle()
        }
    }
}
struct NewObservableView: View {

    @State private var viewModel = ObservableViewModel(database: TitleDataBase())

    var body: some View {
        Text(viewModel.title)
        /// when func in viewModel is MainActor
        /*
            .task {
                await viewModel.updateTitle()
            }
         */
            .onAppear {
                viewModel.updateTitle()
            }
    }
}

#Preview {
    NewObservableView()
}
*/
