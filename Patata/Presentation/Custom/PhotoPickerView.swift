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
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var photoItemToImageMap: [PhotosPickerItem: UIImage] = [:]
    @Binding private var showPermissionAlert: Bool
    @Binding private var selectedImages: [UIImage]
    @Binding private var isPresentedError: Bool
    @Binding private var isImageSizeValid: Bool
    @Binding private var resizedImageDatas: [Data]
    @Binding private var isResizing: Bool
    @Binding private var invalidExceed: Bool
    @Binding private var totalExceed: Bool
    @Binding private var deleteIndex: Int?

    private let imageResizeManager = ImageResizeManager()
    @State private var delete: Bool = false
    
    private let maxSelectedCount: Int
    private var permissionManager = PermissionManager.shared
    private var disabled: Bool {
        !isPhotoLibraryAuthorized
    }
    private let matching: PHPickerFilter
    private let photoLibrary: PHPhotoLibrary
    private let content: () -> Content

    public init(
        selectedImages: Binding<[UIImage]>,
        isPresentedError: Binding<Bool> = .constant(false),
        showPermissionAlert: Binding<Bool>,
        isImageSizeValid: Binding<Bool>,
        resizedImageDatas: Binding<[Data]>,
        isResizing: Binding<Bool>,
        invalidExceed: Binding<Bool>,
        totalExceed: Binding<Bool>,
        deleteIndex: Binding<Int?> = .constant(nil),
        maxSelectedCount: Int = 3,
        matching: PHPickerFilter = .images,
        photoLibrary: PHPhotoLibrary = .shared(),
        content: @escaping () -> Content
    ) {
        self._selectedImages = selectedImages
        self._isPresentedError = isPresentedError
        self._showPermissionAlert = showPermissionAlert
        self._isImageSizeValid = isImageSizeValid
        self._resizedImageDatas = resizedImageDatas
        self._isResizing = isResizing
        self._invalidExceed = invalidExceed
        self._totalExceed = totalExceed
        self._deleteIndex = deleteIndex
        self.maxSelectedCount = maxSelectedCount
        self.matching = matching
        self.photoLibrary = photoLibrary
        self.content = content
    }

    public var body: some View {
        PhotosPicker(
            selection: $selectedPhotos,
            maxSelectionCount: maxSelectedCount,
            matching: matching,
            photoLibrary: photoLibrary
        ) {
            content()
        }
        .onChange(of: selectedPhotos) { newValue in
            if !delete {
                handleSelectedPhotos(newValue)
            } else {
                delete = false
            }
        }
        .onChange(of: deleteIndex) { newValue in
            if selectedPhotos.count == 0 {
                deleteIndex = nil
            }
            
            guard let index = newValue, index >= 0, index < selectedPhotos.count else { return }
            let photoToRemove = selectedPhotos[index]
            
            selectedPhotos.remove(at: index)
            photoItemToImageMap.removeValue(forKey: photoToRemove)
            
            delete = true
            deleteIndex = nil
        }
    }
}

extension PhotoPickerView {
    private func handleSelectedPhotos(_ newPhotos: [PhotosPickerItem]) {
        Task {
            await MainActor.run {
                isResizing = true
            }
            
            do {
                let loadedImages = try await withThrowingTaskGroup(of: (PhotosPickerItem, UIImage)?.self) { group in
                    for photo in newPhotos {
                        group.addTask {
                            if let data = try? await photo.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                return (photo, image)
                            }
                            return nil
                        }
                    }
                    
                    var results: [(PhotosPickerItem, UIImage)] = []
                    for try await result in group {
                        if let validResult = result {
                            results.append(validResult)
                        }
                    }
                    return results
                }
                
                let tempImages = loadedImages.map { $0.1 }
                
                let combinedImages = tempImages
                let combinedMapping = Dictionary(uniqueKeysWithValues: loadedImages)
                
                await MainActor.run {
                    selectedImages = combinedImages
                    photoItemToImageMap.merge(combinedMapping) { _, new in new }
                }
                
                let (resizedDatas, isIndividualExceeded, isTotalExceeded) = try await imageResizeManager.resizeImages(combinedImages)
                
                if isIndividualExceeded {
                    await MainActor.run {
                        isImageSizeValid = false
                        isPresentedError = true
                        invalidExceed = true
                        totalExceed = false
                        isResizing = false
                    }
                    return
                }
                
                if isTotalExceeded {
                    await MainActor.run {
                        delete = true
                        
                        selectedImages = Array(combinedImages.prefix(combinedImages.count - 1))
                        resizedImageDatas = resizedDatas
                        
                        selectedPhotos.removeLast()
                        photoItemToImageMap = photoItemToImageMap.filter { selectedPhotos.contains($0.key ) }
                        
                        isImageSizeValid = true
                        invalidExceed = false
                        totalExceed = true
                        isResizing = false
                    }
                    return
                }
                
                await MainActor.run {
                    resizedImageDatas = resizedDatas
                    isImageSizeValid = true
                    invalidExceed = false
                    totalExceed = false
                    isResizing = false
                }
            } catch {
                await MainActor.run {
                    isPresentedError = true
                    isResizing = false
                }
            }
        }
    }

    private func syncSelectedPhotos() {
        let currentImagesSet = Set(selectedImages.map { $0.pngData() })
        let newSelectedPhotos = selectedPhotos.filter { photo in
            if let image = photoItemToImageMap[photo] {
                return currentImagesSet.contains(image.pngData())
            }
            return false
        }
        
        delete = true
        selectedPhotos = newSelectedPhotos
    }
}
