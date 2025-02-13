//
//  ImageResizeManager.swift
//  Patata
//
//  Created by 김진수 on 2/14/25.
//

import Foundation
import UIKit

final actor ImageResizeManager {
    private let maxTotalSize: Int64 = 10 * 1024 * 1024  // 10MB
    private let maxImageSize: Int64 = 5 * 1024 * 1024   // 5MB
    
    private init() {}
    
    func resizeImages(_ images: [UIImage]) async throws(PAError) -> [Data] {
        guard !images.isEmpty else { throw PAError.imageResizeError(.invalidImage) }
        
        var resizedImages: [Data] = []
        var currentTotalSize: Int64 = 0
        
        for image in images {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                throw PAError.imageResizeError(.invalidImage)
            }
            
            var compression: CGFloat = 0.8
            var compressedData = imageData
            
            while Int64(compressedData.count) > maxImageSize && compression > 0.1 {
                compression -= 0.1
                guard let newData = image.jpegData(compressionQuality: compression) else {
                    throw PAError.imageResizeError(.invalidImage)
                }
                compressedData = newData
            }
            
            if Int64(compressedData.count) > maxImageSize {
                let scale = sqrt(Double(maxImageSize) / Double(compressedData.count))
                let newSize = CGSize(
                    width: Double(image.size.width) * scale,
                    height: Double(image.size.height) * scale
                )
                
                guard let resizedImage = await resizeImage(image, to: newSize),
                      let resizedData = resizedImage.jpegData(compressionQuality: compression) else {
                    throw PAError.imageResizeError(.invalidImage)
                }
                compressedData = resizedData
            }
            
            let newTotalSize = currentTotalSize + Int64(compressedData.count)
            if newTotalSize > maxTotalSize {
                throw PAError.imageResizeError(.totalSizeExceeded)
            }
            
            currentTotalSize = newTotalSize
            resizedImages.append(compressedData)
        }
        
        return resizedImages
    }
    
    private func resizeImage(_ image: UIImage, to targetSize: CGSize) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let renderer = UIGraphicsImageRenderer(size: targetSize)
                let resizedImage = renderer.image { context in
                    image.draw(in: CGRect(origin: .zero, size: targetSize))
                }
                continuation.resume(returning: resizedImage)
            }
        }
    }
    
    func calculateImageSize(_ imageData: Data) -> String {
        let bytes = Double(imageData.count)
        let megabytes = bytes / 1024 / 1024
        return String(format: "%.2f MB", megabytes)
    }
}
