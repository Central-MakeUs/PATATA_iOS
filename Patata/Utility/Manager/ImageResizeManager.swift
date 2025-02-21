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
    
    func resizeImages(_ images: [UIImage]) async throws -> (datas: [Data], isIndividualExceeded: Bool, isTotalExceeded: Bool) {
        guard !images.isEmpty else { throw PAError.imageResizeError(.invalidImage) }
        
        var resizedImages: [Data] = []
        var currentTotalSize: Int64 = 0
        var isIndividualExceeded = false
        var isTotalExceeded = false
        
        print("📸 Starting image processing...")
        print("🎯 Max total size: \(formatSize(maxTotalSize))")
        
        for (index, image) in images.enumerated() {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                throw PAError.imageResizeError(.invalidImage)
            }
            
            print("\n🖼 Processing image #\(index + 1)")
            print("📊 Original size: \(formatSize(Int64(imageData.count)))")
            
            var compression: CGFloat = 0.8
            var compressedData = imageData
            
            // Try compression first
            while Int64(compressedData.count) > maxImageSize && compression > 0.1 {
                compression -= 0.1
                guard let newData = image.jpegData(compressionQuality: compression) else {
                    throw PAError.imageResizeError(.invalidImage)
                }
                compressedData = newData
                print("🔄 Compressed to: \(formatSize(Int64(compressedData.count))) (quality: \(String(format: "%.1f", compression)))")
            }
            
            // If still too large, try resizing
            if Int64(compressedData.count) > maxImageSize {
                let scale = sqrt(Double(maxImageSize) / Double(compressedData.count))
                let newSize = CGSize(
                    width: Double(image.size.width) * scale,
                    height: Double(image.size.height) * scale
                )
                
                print("📏 Resizing to: \(Int(newSize.width))x\(Int(newSize.height))")
                
                guard let resizedImage = await resizeImage(image, to: newSize),
                      let resizedData = resizedImage.jpegData(compressionQuality: compression) else {
                    throw PAError.imageResizeError(.invalidImage)
                }
                compressedData = resizedData
                print("📉 Resized size: \(formatSize(Int64(compressedData.count)))")
                
                if Int64(compressedData.count) > maxImageSize {
                    print("⚠️ Individual image exceeds max size!")
                    isIndividualExceeded = true
                    return (resizedImages, isIndividualExceeded, isTotalExceeded)
                }
            }
            
            let newTotalSize = currentTotalSize + Int64(compressedData.count)
            print("📊 Current total size: \(formatSize(newTotalSize))")
            
            if newTotalSize > maxTotalSize {
                print("⚠️ Total size would exceed limit!")
                isTotalExceeded = true
                break
            }
            
            currentTotalSize = newTotalSize
            resizedImages.append(compressedData)
            print("✅ Image #\(index + 1) processed successfully")
        }
        
        print("\n📑 Final Summary:")
        print("Total images processed: \(resizedImages.count)")
        print("Final total size: \(formatSize(currentTotalSize))")
        print("Individual exceeded: \(isIndividualExceeded)")
        print("Total exceeded: \(isTotalExceeded)")
        
        return (resizedImages, isIndividualExceeded, isTotalExceeded)
    }
    
    private func formatSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useBytes, .useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
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
}
