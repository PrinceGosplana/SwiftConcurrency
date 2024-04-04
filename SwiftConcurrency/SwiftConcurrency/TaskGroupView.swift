//
//  TaskGroupView.swift
//  SwiftConcurrency
//
//  Created by Oleksandr Isaiev on 03.04.2024.
//

import SwiftUI

final class TaskGroupDataManager {

    func fetchImagesWithAsyncLet() async throws -> [UIImage] {
        async let fetchImage1 = fetchImage(urlString: "https://picsum.photos/300")
        async let fetchImage2 = fetchImage(urlString: "https://picsum.photos/300")
        async let fetchImage3 = fetchImage(urlString: "https://picsum.photos/300")
        async let fetchImage4 = fetchImage(urlString: "https://picsum.photos/300")

        let (image1, image2, image3, image4) = await (try fetchImage1, try fetchImage2, try fetchImage3, try fetchImage4)
        return [image1, image2, image3, image4]
    }
    
    func fetchImagesWithTaskGroup() async throws -> [UIImage] {
        
        return try await withThrowingTaskGroup(of: UIImage.self) { group in
            var images: [UIImage] = []

            group.addTask {
                try await self.fetchImage(urlString: "https://picsum.photos/300")
            }
            group.addTask {
                try await self.fetchImage(urlString: "https://picsum.photos/300")
            }
            group.addTask {
                try await self.fetchImage(urlString: "https://picsum.photos/300")
            }
            group.addTask {
                try await self.fetchImage(urlString: "https://picsum.photos/300")
            }

            for try await image in group {
                images.append(image)
            }

            return images
        }
    }

    func fetchImagesWithTaskGroup2() async throws -> [UIImage] {

        let urlStrings = [
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300"
        ]
        return try await withThrowingTaskGroup(of: UIImage?.self) { group in
            var images: [UIImage] = []
            /// perform boost of array
            images.reserveCapacity(urlStrings.count)

            for urlString in urlStrings {
                group.addTask {
                    try? await self.fetchImage(urlString: urlString)
                }
            }

            for try await image in group {
                if let image {
                    images.append(image)
                }
            }

            return images
        }
    }

    private func fetchImage(urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                return image
            } else {
                throw URLError(.badURL)
            }

        } catch {
            throw error
        }
    }
}

final class TaskGroupViewModel: ObservableObject {
    
    @Published var images: [UIImage] = []
    let manager: TaskGroupDataManager

    init(manager: TaskGroupDataManager) {
        self.manager = manager
    }

    func getImages() async {
        /*
        if let images = try? await manager.fetchImagesWithAsyncLet() {
            self.images.append(contentsOf: images)
        }
        */
        if let images = try? await manager.fetchImagesWithTaskGroup2() {
            self.images.append(contentsOf: images)
        }
    }
}

struct TaskGroupView: View {

    @StateObject private var viewModel = TaskGroupViewModel(manager: TaskGroupDataManager())
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    let url = URL(string: "https://picsum.photos/300")!

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(viewModel.images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }
                }
            }
            .navigationTitle("Task Group 🎡")
            .task {
                await viewModel.getImages()
            }
        }
    }
}

#Preview {
    TaskGroupView()
}
