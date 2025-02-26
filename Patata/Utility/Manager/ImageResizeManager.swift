//
//  ImageResizeManager.swift
//  Patata
//
//  Created by 김진수 on 2/14/25.
//

import Foundation
import UIKit

final actor ImageResizeManager {
    private let maxTotalSize: Int64 = 10 * 1024 * 1024
    private let maxImageSize: Int64 = 5 * 1024 * 1024
    private let targetResolution = CGSize(width: 3000, height: 2000)
    
    func resizeImages(_ images: [UIImage]) async throws -> (datas: [Data], isIndividualExceeded: Bool, isTotalExceeded: Bool) {
        guard !images.isEmpty else { throw PAError.imageResizeError(.invalidImage) }
        
        var resizedImages: [Data] = []
        var currentTotalSize: Int64 = 0
        var isIndividualExceeded = false
        var isTotalExceeded = false
        
        print("📸 Starting image processing...")
        print("🎯 Max total size: \(formatSize(maxTotalSize))")

        for (index, image) in images.enumerated() {
            print("\n🖼 Processing image #\(index + 1)")
            
            guard let originalData = image.jpegData(compressionQuality: 1.0) else {
                throw PAError.imageResizeError(.invalidImage)
            }
            
            let originalDataSize = Int64(originalData.count)
            print("📏 Original image size: \(formatSize(originalDataSize))")
            
            if originalDataSize <= maxImageSize && image.size.width <= targetResolution.width && image.size.height <= targetResolution.height {
                print("✓ Image already smaller than size limit, skipping compression")
                
                let newTotalSize = currentTotalSize + originalDataSize
                print("📊 Current total size: \(formatSize(newTotalSize))")
                
                if newTotalSize > maxTotalSize {
                    print("⚠️ Total size would exceed limit!")
                    isTotalExceeded = true
                    break
                }
                
                currentTotalSize = newTotalSize
                resizedImages.append(originalData)
                print("✅ Image #\(index + 1) processed successfully (original used)")
                continue
            }
            
            let imageToProcess: UIImage
            let originalSize = image.size
            let originalPixelCount = originalSize.width * originalSize.height
            let targetPixelCount = targetResolution.width * targetResolution.height
            
            if originalPixelCount > targetPixelCount {
                print("🔄 Resizing image from \(Int(originalSize.width))x\(Int(originalSize.height)) to \(Int(targetResolution.width))x\(Int(targetResolution.height))")
                imageToProcess = await resizeImage(image, to: targetResolution)
            } else {
                print("✓ Image resolution is good, keeping original size")
                imageToProcess = image
            }
            
            guard let checkData = imageToProcess.jpegData(compressionQuality: 1.0) else {
                throw PAError.imageResizeError(.invalidImage)
            }
            
            let checkDataSize = Int64(checkData.count)
            
            if checkDataSize > maxImageSize {
                guard let compressedData = await binarySearchCompression(for: imageToProcess) else {
                    throw PAError.imageResizeError(.invalidImage)
                }
                
                let newTotalSize = currentTotalSize + Int64(compressedData.count)
                print("📊 Current total size: \(formatSize(newTotalSize))")
                
                if newTotalSize > maxTotalSize {
                    print("⚠️ Total size would exceed limit!")
                    isTotalExceeded = true
                    break
                }
                
                if Int64(compressedData.count) > maxImageSize {
                    print("⚠️ Individual image exceeds max size!")
                    isIndividualExceeded = true
                    return (resizedImages, isIndividualExceeded, isTotalExceeded)
                }

                currentTotalSize = newTotalSize
                resizedImages.append(compressedData)
                print("✅ Image #\(index + 1) processed successfully")
            } else {
                let newTotalSize = currentTotalSize + Int64(checkDataSize)
                print("📊 Current total size: \(formatSize(newTotalSize))")
                
                if newTotalSize > maxTotalSize {
                    print("⚠️ Total size would exceed limit!")
                    isTotalExceeded = true
                    break
                }
                
                if checkDataSize > maxImageSize {
                    print("⚠️ Individual image exceeds max size!")
                    isIndividualExceeded = true
                    return (resizedImages, isIndividualExceeded, isTotalExceeded)
                }

                currentTotalSize = newTotalSize
                resizedImages.append(checkData)
            }
           
        }
        
        print("\n📑 Final Summary:")
        print("Total images processed: \(resizedImages.count)")
        print("Final total size: \(formatSize(currentTotalSize))")
        print("Individual exceeded: \(isIndividualExceeded)")
        print("Total exceeded: \(isTotalExceeded)")
        
        return (resizedImages, isIndividualExceeded, isTotalExceeded)
    }
    
    private func binarySearchCompression(for image: UIImage) async -> Data? {
        var low: CGFloat = 0.1
        var high: CGFloat = 1.0
        var bestData: Data? = nil
        
        while high - low > 0.05 {
            let mid = (low + high) / 2
            guard let compressedData = image.jpegData(compressionQuality: mid) else { return nil }
            
            print("🔍 Testing compression: \(String(format: "%.2f", mid)) -> \(formatSize(Int64(compressedData.count)))")
            
            if Int64(compressedData.count) > maxImageSize {
                high = mid
            } else {
                low = mid
                bestData = compressedData
            }
        }
        
        return bestData
    }
    
    private func formatSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useBytes, .useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    private func resizeImage(_ image: UIImage, to targetSize: CGSize) async -> UIImage {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let scale = min(targetSize.width / image.size.width, targetSize.height / image.size.height)
                let newSize = CGSize(
                    width: image.size.width * scale,
                    height: image.size.height * scale
                )
                
                let renderer = UIGraphicsImageRenderer(size: newSize)
                let resizedImage = renderer.image { context in
                    image.draw(in: CGRect(origin: .zero, size: newSize))
                }
                continuation.resume(returning: resizedImage)
            }
        }
    }
}
