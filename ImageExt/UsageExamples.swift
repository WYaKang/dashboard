//
//  UsageExamples.swift
//  ImageExt
//
//  Created for Image Extension Task.
//

import UIKit

class UsageExamples {
    
    func example() {
        // Assume we have an image
        let image = UIImage()
        
        // 1. Chaining operations
        // Rotate 90 degrees, then flip horizontally, then crop
        if let processed = image
            .rotate(degrees: 90)?
            .flipHorizontal()?
            .crop(to: CGRect(x: 0, y: 0, width: 100, height: 100)) {
            print("Successfully processed image: \(processed.size)")
        }
        
        // 2. Orientation fix
        // Useful before uploading to server or processing pixel data
        if let fixed = image.fixOrientation() {
            print("Image is now upright: \(fixed.imageOrientation == .up)")
        }
        
        // 3. Color adjustments
        // Increase contrast and saturation
        if let adjusted = image.adjust(brightness: 0.0, contrast: 1.2, saturation: 1.2) {
            // Use adjusted image
            _ = adjusted
        }
        
        // 4. Scaling
        // Scale to specific size or ratio
        if let scaled = image.scale(ratio: 0.5) {
            print("Image scaled to 50%")
        }
        
        // 5. Background processing (Example usage with Swift Concurrency)
        Task {
            let result = await processImageInBackground(image)
            // Update UI on main thread
            await MainActor.run {
                print("Background processing finished: \(String(describing: result))")
            }
        }
    }
    
    // Example of background processing helper
    func processImageInBackground(_ image: UIImage) async -> UIImage? {
        return await Task.detached {
            return image
                .rotate(degrees: 180)?
                .adjust(contrast: 1.1)
        }.value
    }
    
    func advancedExample() {
        let image = UIImage()
        
        // 0. Pro-level Downsampling (Memory Efficient)
        if let data = image.pngData(),
           let thumb = UIImage.downsample(imageData: data, to: CGSize(width: 50, height: 50)) {
            print("Thumbnail created efficiently: \(thumb.size)")
        }
        
        // 1. Watermark & Padding
        let watermarked = image
            .withWatermark(text: "CONFIDENTIAL", point: CGPoint(x: 20, y: 20))?
            .withPadding(top: 20, left: 20, bottom: 20, right: 20, color: .white)
            
        // 2. Stitching
        if let img1 = UIImage(named: "1"), let img2 = UIImage(named: "2") {
            let stitched = UIImage.stitch(images: [img1, img2], axis: .horizontal, spacing: 10)
            print(stitched?.size ?? .zero)
        }
        
        // 3. Effects & Styling
        let _ = image.blurred(radius: 10)?
            .withRoundedCorners(radius: 15, corners: [.topLeft, .bottomRight]) // Custom corners
            .resize(to: CGSize(width: 300, height: 200), contentMode: .scaleAspectFill) // Smart resize
            
        // 4. Compress for upload (Binary Search)
        if let data = image.compress(toMaxBytes: 1024 * 500) { // 500KB
            print("Compressed size: \(data.count)")
            // Get Base64
            print("Base64 length: \(image.base64String?.count ?? 0)")
        }
        
        // 5. Advanced Filters & Analysis
        let _ = image.grayscale()?
            .sepia(intensity: 0.8)?
            .croppedToCircle()
            
        // 6. Color Analysis
        if let avgColor = image.averageColor {
            print("Average color: \(avgColor)")
        }
        
        // 7. Generation
        let _ = UIImage(color: .blue, size: CGSize(width: 100, height: 1)) // Divider
    }
}
