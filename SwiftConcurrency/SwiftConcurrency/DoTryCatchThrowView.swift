//
//  DoTryCatchThrowView.swift
//  SwiftConcurrency
//
//  Created by Oleksandr Isaiev on 02.04.2024.
//

import SwiftUI

final class DoTryCatchThrowDataSource {

    let isActive = false

    func getTitle() throws -> String {
        if isActive {
            return "NEW TEXT"
        } else {
            throw URLError(.badServerResponse)
        }
    }
}

final class DoTryCatchThrowViewModel: ObservableObject {

    @Published var text: String = "Start text"
    let textService: DoTryCatchThrowDataSource

    func fetchTitle() {
        do {
            let newTitle = try textService.getTitle()
            text = newTitle
        } catch {
            text = error.localizedDescription
        }
    }

    init(textService: DoTryCatchThrowDataSource) {
        self.textService = textService
    }
}

struct DoTryCatchThrowView: View {

    @StateObject private var viewModel = DoTryCatchThrowViewModel(textService: DoTryCatchThrowDataSource())

    var body: some View {
        Text(viewModel.text)
            .font(.title)
            .frame(minWidth: 300, minHeight: 300)
            .padding()
            .background(.indigo)
            .foregroundStyle(.white)
            .onTapGesture {
                viewModel.fetchTitle()
            }
    }
}

#Preview {
    DoTryCatchThrowView()
}
