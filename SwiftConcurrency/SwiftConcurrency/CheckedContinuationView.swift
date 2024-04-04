//
//  CheckedContinuationView.swift
//  SwiftConcurrency
//
//  Created by Oleksandr Isaiev on 03.04.2024.
//

import SwiftUI

final class CheckedContinuationNetworkManager {

    func getData(url: URL) async throws -> Data {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch {
            throw error
        }
    }

    func getData2(url: URL) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data {
                    continuation.resume(returning: data)
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: URLError(.badURL))
                }
            }
            .resume()
        }
    }

    func getHeartImageFromDatabase(completionHandler: @escaping (_ image: UIImage) -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completionHandler(UIImage(systemName: "heart.fill")!)
        }
    }

    func getHeartImageFromDatabase() async -> UIImage {
        await withCheckedContinuation { continuation in
            getHeartImageFromDatabase { image in
                continuation.resume(returning: image)
            }
        }
    }
}

final class CheckedContinuationViewModel: ObservableObject {

    @Published var image: UIImage? = nil
    let networkManager: CheckedContinuationNetworkManager

    init(networkManager: CheckedContinuationNetworkManager) {
        self.networkManager = networkManager
    }

    func getImage() async {
        guard let url = URL(string: "https://picsum.photos/300") else { return }

        do {
            let data = try await networkManager.getData2(url: url)
            if let image = UIImage(data: data) {
                await MainActor.run {
                    self.image = image
                }
            }
        } catch {
            print(error)
        }
    }

    func getHeartImage() {
        networkManager.getHeartImageFromDatabase { [weak self] image in
            self?.image = image
        }
    }

    func getHeartImage() async {
        self.image = await networkManager.getHeartImageFromDatabase()
    }

}

struct CheckedContinuationView: View {

    @StateObject private var viewModel = CheckedContinuationViewModel(networkManager: CheckedContinuationNetworkManager())

    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        .task {
//            await viewModel.getImage()
            await viewModel.getHeartImage()
        }
    }
}

#Preview {
    CheckedContinuationView()
}
