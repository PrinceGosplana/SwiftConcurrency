//
//  DownloadImageAsync.swift
//  SwiftConcurrency
//
//  Created by Oleksandr Isaiev on 02.04.2024.
//

import SwiftUI

final class DownloadImageAsyncImageLoader {

    let url = URL(string: "https://picsum.photos/200")!

    func handleResponse(data: Data?, response: URLResponse?) -> UIImage? {
        guard let data,
              let image = UIImage(data: data),
              let response = response as? HTTPURLResponse,
              response.statusCode >= 200 && response.statusCode < 300 else {
            return nil
        }
        return image
    }

    func download() async throws -> UIImage? {
        do {
            let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
            return handleResponse(data: data, response: response)
        } catch {
            throw error
        }
    }
}

final class DownloadImageAsyncViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    let loader: DownloadImageAsyncImageLoader

    init(loader: DownloadImageAsyncImageLoader) {
        self.loader = loader
    }

    func fetchImage() async {
        let image = try? await loader.download()
        
        await MainActor.run {
            /// number = 1, name = main
            print(Thread.current)
            self.image = image
        }
    }
}

struct DownloadImageAsync: View {

    @StateObject private var viewModel = DownloadImageAsyncViewModel(loader: DownloadImageAsyncImageLoader())

    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchImage()
            }
        }
    }
}

#Preview {
    DownloadImageAsync()
}
