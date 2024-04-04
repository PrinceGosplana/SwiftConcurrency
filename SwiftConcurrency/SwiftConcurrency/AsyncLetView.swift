//
//  AsyncLetView.swift
//  SwiftConcurrency
//
//  Created by Oleksandr Isaiev on 03.04.2024.
//

import SwiftUI

struct AsyncLetView: View {

    @State private var images: [UIImage] = []
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    let url = URL(string: "https://picsum.photos/300")!

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }
                }
            }
            .navigationTitle("Async let 🎡")
            .onAppear {
                Task {
                    do {
                        async let fetchTitle1 = fetchTitle()
                        async let fetchImage1 = fetchImage()
                        async let fetchImage2 = fetchImage()
                        async let fetchImage3 = fetchImage()
                        async let fetchImage4 = fetchImage()

                        let (title1, image1, image2, image3, image4) = await (try fetchTitle1, try fetchImage1, try fetchImage2, try fetchImage3, try fetchImage4)
                        self.images.append(contentsOf: [image1, image2, image3, image4])
                        /*
                        let image = try await fetchImage()
                        self.images.append(image)

                        let image2 = try await fetchImage()
                        self.images.append(image2)

                        let image3 = try await fetchImage()
                        self.images.append(image3)

                        let image4 = try await fetchImage()
                        self.images.append(image4)
                        */
                    } catch {

                    }
                }
            }
        }
    }

    func fetchTitle() async -> String {
        "New title"
    }

    func fetchImage() async throws -> UIImage {
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

#Preview {
    AsyncLetView()
}
