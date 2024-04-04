//
//  TaskView.swift
//  SwiftConcurrency
//
//  Created by Oleksandr Isaiev on 03.04.2024.
//

import SwiftUI

final class TaskViewModel: ObservableObject {

    @Published var image: UIImage?  = nil
    @Published var image2: UIImage?  = nil

    let url = URL(string: "https://picsum.photos/1000")!

    func fetchImage() async {
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        do {
            guard let url = URL(string: "https://picsum.photos/200") else { return }
            let (data, _) = try await URLSession.shared.data(from: url)

            await MainActor.run {
                print("SUCCESS")
                self.image = UIImage(data: data)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct TaskHomeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink("Click me! 🎲") {
                    TaskView()
                }
            }
        }
    }
}

struct TaskView: View {

    @StateObject private var viewModel = TaskViewModel()
    @State private var fetchImageTask: Task<(), Never>? = nil

    var body: some View {
        VStack(spacing: 40) {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }

            if let image = viewModel.image2 {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        .task {
            await viewModel.fetchImage()
        }
        /*
        .onDisappear {
            fetchImageTask?.cancel()
        }
         */
        /*
        .onAppear {
            fetchImageTask = Task {
                await viewModel.fetchImage()
            }
        }
        */
    }
}

#Preview {
    TaskHomeView()
}
