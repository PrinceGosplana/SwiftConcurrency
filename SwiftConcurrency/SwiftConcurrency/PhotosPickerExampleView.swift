//
//  PhotosPickerExampleView.swift
//  SwiftConcurrency
//
//  Created by Oleksandr Isaiev on 06.04.2024.
//

import PhotosUI
import SwiftUI

@MainActor
final class PhotoPickerViewModel: ObservableObject {

    @Published private(set) var selectedImage: UIImage? = nil
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            setImage(form: imageSelection)
        }
    }

    @Published private(set) var selectedImages: [UIImage] = []
    @Published var imageSelections: [PhotosPickerItem] = [] {
        didSet {
            setImages(form: imageSelections)
        }
    }

    private func setImage(form selection: PhotosPickerItem?) {
        guard let selection else { return }

        Task {
            /*
             /// One option how to show selected image
            if let data = try? await selection.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                selectedImage = uiImage
                return
            }
             */
            do {
                let data = try await selection.loadTransferable(type: Data.self)

                guard let data, let uiImage = UIImage(data: data) else {
                    throw URLError(.badServerResponse)
                }
                selectedImage = uiImage
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    private func setImages(form selections: [PhotosPickerItem]) {
        Task {
            var images: [UIImage] = []
            for selection in selections {
                if let data = try? await selection.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    images.append(uiImage)
                }
            }
            selectedImages = images
        }
    }
}

struct PhotosPickerExampleView: View {

    @StateObject private var viewModel = PhotoPickerViewModel()

    var body: some View {
        VStack(spacing: 40) {
            if let image = viewModel.selectedImage {
                SelectedImageView(image: image, size: 200)
            }

            PhotosPicker(selection: $viewModel.imageSelection, matching: .images) {
                SelectButton(title: "Open the photo picker")
            }

            if !viewModel.selectedImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 5) {
                        ForEach(viewModel.selectedImages, id: \.self) { image in
                            SelectedImageView(image: image, size: 100)
                        }
                    }
                }
            }
            PhotosPicker(selection: $viewModel.imageSelections, matching: .images) {
                SelectButton(title: "Open the photos picker")
            }
        }
    }
}

#Preview {
    PhotosPickerExampleView()
}

struct SelectedImageView: View {

    let image: UIImage
    let size: CGFloat

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct SelectButton: View {

    var title: String

    var body: some View {
        Text(title)
            .bold()
            .frame(width: 280, height: 44)
            .background(.indigo)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
