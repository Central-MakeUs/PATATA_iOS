//
//  PhotoPickerView.swift
//  Patata
//
//  Created by 김진수 on 1/31/25.
//

import PhotosUI
import SwiftUI

public struct PhotoPickerView<Content: View>: View {
    @State private var isPhotoLibraryAuthorized: Bool = false
    @State private var selectedPhotos: [PhotosPickerItem]
    @Binding private var showPermissionAlert: Bool
    @Binding private var selectedImages: [UIImage]
    @Binding private var isPresentedError: Bool
    
    private let maxSelectedCount: Int
    private var permissionManager = PermissionManager.shared
    private var disabled: Bool {
        selectedImages.count >= maxSelectedCount || !isPhotoLibraryAuthorized
    }
    private var availableSelectedCount: Int {
        maxSelectedCount - selectedImages.count
    }
    private let matching: PHPickerFilter
    private let photoLibrary: PHPhotoLibrary
    private let content: () -> Content
    
    public init(
        selectedPhotos: [PhotosPickerItem] = [],
        selectedImages: Binding<[UIImage]>,
        isPresentedError: Binding<Bool> = .constant(false),
        showPermissionAlert: Binding<Bool>,
        maxSelectedCount: Int = 3,
        matching: PHPickerFilter = .images,
        photoLibrary: PHPhotoLibrary = .shared(),
        content: @escaping () -> Content
    ) {
        self.selectedPhotos = selectedPhotos
        self._selectedImages = selectedImages
        self._isPresentedError = isPresentedError
        self._showPermissionAlert = showPermissionAlert
        self.maxSelectedCount = maxSelectedCount
        self.matching = matching
        self.photoLibrary = photoLibrary
        self.content = content
    }
    
    public var body: some View {
        contentView
    }
    
    private var contentView: some View {
        PhotosPicker(
            selection: $selectedPhotos,
            maxSelectionCount: availableSelectedCount,
            matching: matching,
            photoLibrary: photoLibrary
        ) {
            content()
                .disabled(disabled)
        }
        .disabled(disabled)
        .onChange(of: selectedPhotos) { newValue in
            handleSelectedPhotos(newValue)
        }
        .onAppear {
            permissionManager.checkPhotoPermission { granted in
                isPhotoLibraryAuthorized = granted
                showPermissionAlert = !granted
            }
        }
    }

}

extension PhotoPickerView {
    private func handleSelectedPhotos(_ newPhotos: [PhotosPickerItem]) {
        Task {
            do {
                for newPhoto in newPhotos {
                    if let data = try await newPhoto.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        await MainActor.run {
                            if !selectedImages.contains(where: { $0.pngData() == uiImage.pngData() }) {
                                selectedImages.append(uiImage)
                            }
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    isPresentedError = true
                }
            }
            
            await MainActor.run {
                selectedPhotos.removeAll()
            }
        }
    }
}
