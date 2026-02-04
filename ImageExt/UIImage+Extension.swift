//
//  UIImage+Extension.swift
//  ImageExt
//
//  Created for Image Extension Task.
//

import UIKit
import CoreGraphics
import CoreImage
import ImageIO

// Shared CIContext for performance (Thread-safe)
private let sharedCIContext = CIContext(options: [.useSoftwareRenderer: false])

// MARK: - Image Processing Error
public enum ImageProcessError: Error {
    case invalidSourceImage
    case contextCreationFailed
    case filterApplicationFailed
    case croppingFailed
}

// MARK: - UIImage Extension
extension UIImage {
    
    // MARK: - 1. Rotation
    
    /// Rotates the image by the specified degrees.
    /// - Parameter degrees: The angle in degrees to rotate (0-360).
    /// - Returns: A new rotated UIImage, or nil if the operation fails.
    public func rotate(degrees: CGFloat) -> UIImage? {
        let radians = degrees * .pi / 180
        return rotate(radians: radians)
    }
    
    /// Rotates the image by the specified radians.
    /// - Parameter radians: The angle in radians to rotate.
    /// - Returns: A new rotated UIImage, or nil if the operation fails.
    public func rotate(radians: CGFloat) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        
        let newSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: radians))
            .size
        
        // Trim off the extremely small float value to prevent white seam
        let width = floor(newSize.width)
        let height = floor(newSize.height)
        
        let rendererFormat = UIGraphicsImageRendererFormat()
        rendererFormat.scale = self.scale
        rendererFormat.opaque = false
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: rendererFormat)
        
        return renderer.image { context in
            let ctx = context.cgContext
            
            // Move origin to middle
            ctx.translateBy(x: width / 2, y: height / 2)
            // Rotate around middle
            ctx.rotate(by: radians)
            // Draw the image at its center
            self.draw(in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height))
        }
    }
    
    // MARK: - 2. Orientation Correction
    
    /// Fixes the image orientation to be .up
    /// - Returns: A new UIImage with corrected orientation, or nil if fails.
    public func fixOrientation() -> UIImage? {
        if self.imageOrientation == .up {
            return self
        }
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = self.scale
        // Determine opacity based on alpha info, but safe default is false (transparent)
        // If we want to strictly preserve opaque, we'd need to check cgImage alpha info.
        format.opaque = false
        
        let renderer = UIGraphicsImageRenderer(size: self.size, format: format)
        
        return renderer.image { _ in
            self.draw(at: .zero)
        }
    }
    
    // MARK: - 3. Cropping
    
    /// Crops the image to the specified rectangle.
    /// - Parameter rect: The rectangle area to crop (in points, based on image size).
    /// - Returns: Cropped UIImage, or nil if fails.
    public func crop(to rect: CGRect) -> UIImage? {
        // Handle scale factor (retina display)
        let scale = self.scale
        let scaledRect = CGRect(x: rect.origin.x * scale,
                                y: rect.origin.y * scale,
                                width: rect.width * scale,
                                height: rect.height * scale)
        
        guard let cgImage = self.cgImage,
              let croppedCGImage = cgImage.cropping(to: scaledRect) else {
            return nil
        }
        
        return UIImage(cgImage: croppedCGImage, scale: scale, orientation: self.imageOrientation)
    }
    
    /// Crops the image using a custom path.
    /// - Parameter path: The UIBezierPath to crop along.
    /// - Returns: Cropped UIImage with transparent background outside the path.
    public func crop(path: UIBezierPath) -> UIImage? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = self.scale
        format.opaque = false
        
        let renderer = UIGraphicsImageRenderer(size: self.size, format: format)
        return renderer.image { context in
            // Set the clipping path
            path.addClip()
            // Draw the image
            self.draw(at: .zero)
        }
    }
    
    // MARK: - 4. Scaling & Resizing
    
    /// Scales the image to a new size.
    /// - Parameter newSize: The target size.
    /// - Returns: Scaled UIImage.
    public func scale(to newSize: CGSize) -> UIImage? {
        return resize(to: newSize, contentMode: .scaleToFill)
    }
    
    /// Resizes the image to a target size with a specific content mode.
    /// - Parameters:
    ///   - size: The target size.
    ///   - contentMode: The content mode (.scaleToFill, .scaleAspectFit, .scaleAspectFill).
    /// - Returns: Resized UIImage.
    public func resize(to targetSize: CGSize, contentMode: UIView.ContentMode = .scaleToFill) -> UIImage? {
        let newRect: CGRect
        let size = self.size
        
        switch contentMode {
        case .scaleAspectFit:
            let aspectWidth = targetSize.width / size.width
            let aspectHeight = targetSize.height / size.height
            let aspectRatio = min(aspectWidth, aspectHeight)
            
            newRect = CGRect(x: (targetSize.width - size.width * aspectRatio) / 2,
                             y: (targetSize.height - size.height * aspectRatio) / 2,
                             width: size.width * aspectRatio,
                             height: size.height * aspectRatio)
            
        case .scaleAspectFill:
            let aspectWidth = targetSize.width / size.width
            let aspectHeight = targetSize.height / size.height
            let aspectRatio = max(aspectWidth, aspectHeight)
            
            newRect = CGRect(x: (targetSize.width - size.width * aspectRatio) / 2,
                             y: (targetSize.height - size.height * aspectRatio) / 2,
                             width: size.width * aspectRatio,
                             height: size.height * aspectRatio)
            
        default: // .scaleToFill
            newRect = CGRect(origin: .zero, size: targetSize)
        }
        
        // For aspect fit/fill, we might want to return an image of exactly 'targetSize' (with transparent padding for fit)
        // or just the resized image. Standard behavior for "resize" usually means the output image has the new dimensions.
        // If AspectFill, we need to clip. If AspectFit, we might leave transparent gaps.
        // Let's implement consistent canvas size equal to targetSize.
        
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: imageRendererFormat)
        return renderer.image { _ in
            self.draw(in: newRect)
        }
    }
    
    /// Scales the image by a ratio.
    /// - Parameter ratio: The scaling ratio (e.g., 0.5 for half size).
    /// - Returns: Scaled UIImage.
    public func scale(ratio: CGFloat) -> UIImage? {
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        return scale(to: newSize)
    }
    
    // MARK: - 5. Mirroring
    
    /// Flips the image horizontally.
    public func flipHorizontal() -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        // Use standard UIImage method if possible, or context draw
        // UIImage(cgImage: cgImage, scale: scale, orientation: .upMirrored) 
        // Note: Changing orientation metadata is faster but drawing is "hard" processing. 
        // Requirement implies processing pixel data usually, but metadata is valid too.
        // Let's do a hard flip to ensure "processing" behavior consistent with rotation.
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = self.scale
        format.opaque = false
        
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { context in
            let ctx = context.cgContext
            ctx.translateBy(x: size.width, y: 0)
            ctx.scaleBy(x: -1, y: 1)
            self.draw(at: .zero)
        }
    }
    
    /// Flips the image vertically.
    public func flipVertical() -> UIImage? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = self.scale
        format.opaque = false
        
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { context in
            let ctx = context.cgContext
            ctx.translateBy(x: 0, y: size.height)
            ctx.scaleBy(x: 1, y: -1)
            self.draw(at: .zero)
        }
    }
    
    // MARK: - 6. Color Adjustment
    
    /// Adjusts brightness, contrast, and saturation.
    /// - Parameters:
    ///   - brightness: The brightness value (default 0.0).
    ///   - contrast: The contrast value (default 1.0).
    ///   - saturation: The saturation value (default 1.0).
    /// - Returns: Adjusted UIImage.
    public func adjust(brightness: Float = 0.0, contrast: Float = 1.0, saturation: Float = 1.0) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        
        guard let filter = CIFilter(name: "CIColorControls") else { return nil }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(brightness, forKey: kCIInputBrightnessKey)
        filter.setValue(contrast, forKey: kCIInputContrastKey)
        filter.setValue(saturation, forKey: kCIInputSaturationKey)
        
        guard let outputImage = filter.outputImage else { return nil }
        
        // Use a shared context if possible, or create new one.
        // For thread safety and simplicity in extension, we create one.
        // Note: Creating CIContext is expensive. For high performance, consider passing it or using a singleton.
        // Given "Performance requirements", let's use a static context if safe, or just create one (it's okay for occasional use).
        // A static context is thread-safe.
        
        guard let resultCGImage = sharedCIContext.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: resultCGImage, scale: self.scale, orientation: self.imageOrientation)
    }
    
    // MARK: - 7. Watermark
    
    /// Adds a text watermark to the image.
    /// - Parameters:
    ///   - text: The text to draw.
    ///   - point: The origin point to draw text.
    ///   - attributes: Text attributes (font, color, etc.).
    /// - Returns: New UIImage with watermark.
    public func withWatermark(text: String, point: CGPoint, attributes: [NSAttributedString.Key: Any]? = nil) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: self.size, format: imageRendererFormat)
        return renderer.image { _ in
            self.draw(at: .zero)
            let attrString = NSAttributedString(string: text, attributes: attributes)
            attrString.draw(at: point)
        }
    }
    
    /// Adds an image watermark.
    /// - Parameters:
    ///   - image: The watermark image.
    ///   - rect: The rectangle area to draw the watermark.
    ///   - alpha: Opacity of the watermark (0.0 - 1.0).
    /// - Returns: New UIImage with watermark.
    public func withWatermark(image: UIImage, rect: CGRect, alpha: CGFloat = 1.0) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: self.size, format: imageRendererFormat)
        return renderer.image { _ in
            self.draw(at: .zero)
            image.draw(in: rect, blendMode: .normal, alpha: alpha)
        }
    }
    
    // MARK: - 8. Padding & Border
    
    /// Adds padding (or border) around the image.
    /// - Parameters:
    ///   - top: Top padding width.
    ///   - left: Left padding width.
    ///   - bottom: Bottom padding width.
    ///   - right: Right padding width.
    ///   - color: The background color of the padding area.
    /// - Returns: New UIImage with padding.
    public func withPadding(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat, color: UIColor = .clear) -> UIImage? {
        let newSize = CGSize(width: size.width + left + right, height: size.height + top + bottom)
        let renderer = UIGraphicsImageRenderer(size: newSize, format: imageRendererFormat)
        
        return renderer.image { context in
            // Fill background
            color.setFill()
            context.fill(CGRect(origin: .zero, size: newSize))
            // Draw original image
            self.draw(at: CGPoint(x: left, y: top))
        }
    }
    
    // MARK: - 9. Stitching
    
    /// Stitches multiple images together.
    /// - Parameters:
    ///   - images: Array of images to stitch.
    ///   - axis: Axis to stitch (.horizontal or .vertical).
    ///   - spacing: Spacing between images.
    ///   - backgroundColor: Background color of the spacing/empty area.
    /// - Returns: New stitched UIImage.
    public static func stitch(images: [UIImage], axis: NSLayoutConstraint.Axis, spacing: CGFloat = 0, backgroundColor: UIColor = .clear) -> UIImage? {
        guard !images.isEmpty else { return nil }
        
        let totalSize: CGSize
        if axis == .horizontal {
            let width = images.reduce(0) { $0 + $1.size.width } + CGFloat(images.count - 1) * spacing
            let height = images.map { $0.size.height }.max() ?? 0
            totalSize = CGSize(width: width, height: height)
        } else {
            let width = images.map { $0.size.width }.max() ?? 0
            let height = images.reduce(0) { $0 + $1.size.height } + CGFloat(images.count - 1) * spacing
            totalSize = CGSize(width: width, height: height)
        }
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = images.first?.scale ?? 1.0
        format.opaque = false
        
        let renderer = UIGraphicsImageRenderer(size: totalSize, format: format)
        
        return renderer.image { context in
            backgroundColor.setFill()
            context.fill(CGRect(origin: .zero, size: totalSize))
            
            var offset: CGFloat = 0
            for image in images {
                let rect: CGRect
                if axis == .horizontal {
                    // Center vertically
                    let yPos = (totalSize.height - image.size.height) / 2
                    rect = CGRect(x: offset, y: yPos, width: image.size.width, height: image.size.height)
                    offset += image.size.width + spacing
                } else {
                    // Center horizontally
                    let xPos = (totalSize.width - image.size.width) / 2
                    rect = CGRect(x: xPos, y: offset, width: image.size.width, height: image.size.height)
                    offset += image.size.height + spacing
                }
                image.draw(in: rect)
            }
        }
    }
    
    // MARK: - 10. Effects (Blur, Tint, Round Corner)
    
    /// Applies Gaussian Blur to the image.
    /// - Parameter radius: Blur radius.
    /// - Returns: Blurred UIImage.
    public func blurred(radius: CGFloat) -> UIImage? {
        guard let ciImage = CIImage(image: self) else { return nil }
        
        guard let filter = CIFilter(name: "CIGaussianBlur") else { return nil }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(radius, forKey: kCIInputRadiusKey)
        
        guard let outputImage = filter.outputImage else { return nil }
        
        // Crop out the blurred edges to keep original size
        let rect = CGRect(origin: .zero, size: size)
        
        // Note: CIContext creation is expensive, consider sharing context if performance is critical.
        guard let cgImage = sharedCIContext.createCGImage(outputImage, from: ciImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage, scale: self.scale, orientation: self.imageOrientation)
            .crop(to: rect) // Optional: crop to original frame if needed, but blur expands extent
    }
    
    /// Tints the image with a solid color (keeping alpha channel).
    /// - Parameter color: Tint color.
    /// - Returns: Tinted UIImage.
    public func tinted(color: UIColor) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size, format: imageRendererFormat)
        return renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Draw image with destinationIn blend mode to keep alpha of image but use color fill
            self.draw(at: .zero, blendMode: .destinationIn, alpha: 1.0)
        }
    }
    
    /// Rounds the corners of the image.
    /// - Parameters:
    ///   - radius: Corner radius.
    ///   - corners: Specific corners to round (default is all).
    /// - Returns: UIImage with rounded corners.
    public func withRoundedCorners(radius: CGFloat, corners: UIRectCorner = .allCorners) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size, format: imageRendererFormat)
        return renderer.image { _ in
            let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: size),
                                    byRoundingCorners: corners,
                                    cornerRadii: CGSize(width: radius, height: radius))
            path.addClip()
            self.draw(at: .zero)
        }
    }
    
    // MARK: - 11. Compression & Downsampling
    
    /// Downsamples an image from Data to a specific size using ImageIO.
    /// This is highly memory efficient as it decodes only the necessary pixels.
    /// - Parameters:
    ///   - imageData: The image data.
    ///   - pointSize: The target size in points.
    ///   - scale: The screen scale (default is main screen scale).
    /// - Returns: Downsampled UIImage.
    public static func downsample(imageData: Data, to pointSize: CGSize, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, imageSourceOptions) else {
            return nil
        }
        
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as CFDictionary
        
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            return nil
        }
        
        return UIImage(cgImage: downsampledImage)
    }
    
    /// Compresses the image to a target byte size using binary search.
    /// - Parameter maxBytes: Maximum size in bytes.
    /// - Returns: Compressed Data, or nil if fails.
    public func compress(toMaxBytes maxBytes: Int) -> Data? {
        // Fast check: compression 1.0
        var compression: CGFloat = 1.0
        guard var data = self.jpegData(compressionQuality: compression) else { return nil }
        
        if data.count <= maxBytes {
            return data
        }
        
        // Binary search
        var max: CGFloat = 1.0
        var min: CGFloat = 0.0
        
        // Iterate for a limited times to approximate
        for _ in 0..<6 {
            compression = (max + min) / 2
            if let temp = self.jpegData(compressionQuality: compression) {
                if temp.count > maxBytes {
                    // Still too big, need more compression (lower quality)
                    max = compression
                } else {
                    // Fits, but maybe we can improve quality
                    min = compression
                    data = temp // Save the valid data
                }
            } else {
                // Should not happen for valid image
                return nil
            }
        }
        
        // Final check if data is valid (it might be that even 0.0 is too big, but we return the best effort or check again)
        // If data is still larger than maxBytes, we might need resize (not implemented here as requested logic is compression)
        // However, we return the best result we found that fits.
        
        return data.count <= maxBytes ? data : self.jpegData(compressionQuality: min)
    }
    
    // MARK: - 12. More Effects (Grayscale, Sepia, Circle)
    
    /// Applies Grayscale filter.
    public func grayscale() -> UIImage? {
        guard let ciImage = CIImage(image: self) else { return nil }
        guard let filter = CIFilter(name: "CIPhotoEffectMono") else { return nil }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        
        guard let output = filter.outputImage,
              let cgImage = sharedCIContext.createCGImage(output, from: output.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
    }
    
    /// Applies Sepia filter.
    public func sepia(intensity: Float = 1.0) -> UIImage? {
        guard let ciImage = CIImage(image: self) else { return nil }
        guard let filter = CIFilter(name: "CISepiaTone") else { return nil }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(intensity, forKey: kCIInputIntensityKey)
        
        guard let output = filter.outputImage,
              let cgImage = sharedCIContext.createCGImage(output, from: output.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
    }
    
    /// Crops the image to a circle.
    public func croppedToCircle() -> UIImage? {
        let minSide = min(size.width, size.height)
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = false
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: minSide, height: minSide), format: format)
        return renderer.image { _ in
            let rect = CGRect(origin: .zero, size: CGSize(width: minSide, height: minSide))
            UIBezierPath(ovalIn: rect).addClip()
            
            // Draw image centered
            let drawRect = CGRect(x: (minSide - size.width) / 2,
                                  y: (minSide - size.height) / 2,
                                  width: size.width,
                                  height: size.height)
            self.draw(in: drawRect)
        }
    }
    
    // MARK: - 13. Utilities & Generators
    
    /// Initializes an image with a solid color.
    /// - Parameters:
    ///   - color: The fill color.
    ///   - size: The size of the image.
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            color.setFill()
            context.fill(rect)
        }
        
        guard let cgImage = image.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
    /// Returns Base64 string of the image (JPEG).
    public var base64String: String? {
        return self.jpegData(compressionQuality: 1.0)?.base64EncodedString()
    }
    
    /// Calculates the average color of the image.
    public var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x,
                                    y: inputImage.extent.origin.y,
                                    z: inputImage.extent.size.width,
                                    w: inputImage.extent.size.height)
        
        guard let filter = CIFilter(name: "CIAreaAverage",
                                    parameters: [kCIInputImageKey: inputImage,
                                                 kCIInputExtentKey: extentVector]) else { return nil }
        
        guard let outputImage = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        // 1x1 pixel context
        sharedCIContext.render(outputImage,
                               toBitmap: &bitmap,
                               rowBytes: 4,
                               bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                               format: .RGBA8,
                               colorSpace: nil)
        
        return UIColor(red: CGFloat(bitmap[0]) / 255,
                       green: CGFloat(bitmap[1]) / 255,
                       blue: CGFloat(bitmap[2]) / 255,
                       alpha: CGFloat(bitmap[3]) / 255)
    }
}
