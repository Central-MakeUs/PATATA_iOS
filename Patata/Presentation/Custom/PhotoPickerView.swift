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
    @Binding private var isImageSizeValid: Bool
    @Binding private var resizedImageDatas: [Data]
    @Binding private var isResizing: Bool
    
    private let imageResizeManager = ImageResizeManager()
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
        isImageSizeValid: Binding<Bool>,  // 추가: 바인딩 파라미터
        resizedImageDatas: Binding<[Data]>,
        isResizing: Binding<Bool>,
        maxSelectedCount: Int = 3,
        matching: PHPickerFilter = .images,
        photoLibrary: PHPhotoLibrary = .shared(),
        content: @escaping () -> Content
    ) {
        self.selectedPhotos = selectedPhotos
        self._selectedImages = selectedImages
        self._isPresentedError = isPresentedError
        self._showPermissionAlert = showPermissionAlert
        self._isImageSizeValid = isImageSizeValid  // 추가: 바인딩 초기화
        self._resizedImageDatas = resizedImageDatas
        self._isResizing = isResizing
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
        .onTapGesture {
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
            await MainActor.run {
                isResizing = true  // 리사이징 시작
            }
            
            do {
                let loadedImages = try await withThrowingTaskGroup(of: Data?.self) { group in
                    for photo in newPhotos {
                        group.addTask {
                            try await photo.loadTransferable(type: Data.self)
                        }
                    }
                    
                    var results: [Data?] = []
                    for try await result in group {
                        results.append(result)
                    }
                    return results
                }
                
                var tempImages: [UIImage] = []
                for imageData in loadedImages {
                    if let data = imageData,
                       let uiImage = UIImage(data: data) {
                        if !tempImages.contains(where: { $0.pngData() == uiImage.pngData() }) {
                            tempImages.append(uiImage)
                        }
                    }
                }
                
                // 기존 이미지와 새로운 이미지를 합침
                let combinedImages = selectedImages + tempImages
                
                do {
                    let resizedDatas = try await imageResizeManager.resizeImages(combinedImages)
                    await MainActor.run {
                        selectedImages = combinedImages
                        resizedImageDatas = resizedDatas
                        isImageSizeValid = true
                        isResizing = false
                    }
                } catch PAError.imageResizeError(.totalSizeExceeded) {
                    let updatedImages = !combinedImages.isEmpty ? Array(combinedImages.dropLast()) : []
                    
                    // 리사이즈 재시도
                    do {
                        let retryResizedDatas = try await imageResizeManager.resizeImages(updatedImages)
                        
                        // UI 업데이트는 MainActor에서
                        await MainActor.run {
                            selectedImages = updatedImages
                            resizedImageDatas = retryResizedDatas
                            isImageSizeValid = true
                            isResizing = false
                        }
                    } catch {
                        await MainActor.run {
                            isImageSizeValid = false
                            isResizing = false
                        }
                    }
                } catch PAError.imageResizeError(.invalidImage) {
                    await MainActor.run {
                        isImageSizeValid = false
                        isResizing = false
                    }
                }
            } catch {
                await MainActor.run {
                    isPresentedError = true
                    isResizing = false
                }
            }
            
            await MainActor.run {
                selectedPhotos.removeAll()
            }
        }
    }
}
