# Image Extension Enhancement Plan

This document outlines the plan to enhance `UIImage+Extension.swift` with advanced image processing capabilities.

## 1. New Features Overview

We will add the following functional modules to the existing `UIImage` extension:

### A. Watermarking (水印)
- **Text Watermark**: Draw text at a specific position with attributes (font, color, opacity).
- **Image Watermark**: Overlay another image at a specific position with opacity.
- **Positioning**: Support absolute coordinates or relative positioning (e.g., `.bottomRight`).

### B. Padding & Border (边框与留白)
- **Padding**: Add padding to the 4 edges (top, left, bottom, right) independently.
- **Border**: Essentially padding with a specific color.
- **Background Color**: Support transparent or solid color background for the padded area.

### C. Image Stitching (图片拼接)
- **Horizontal/Vertical**: Combine multiple images into one.
- **Alignment**: Center alignment for images of different sizes.
- **Spacing**: Add spacing between images.

### D. Masking & Cutout (抠图与遮罩)
- **Shape Cutout**: Crop image to Circle, Rounded Rect, or arbitrary Path.
- **Image Mask**: Use an alpha mask image to cutout specific areas.

### E. Filters & Effects (滤镜与特效)
- **Tinting**: Apply a solid color tint (useful for icons).
- **Blur**: Gaussian blur using CoreImage.
- **Rounded Corners**: A specialized case of Shape Cutout for performance.

### F. Compression (压缩)
- **Compress to Size**: Resize and compress image to fit within a byte limit (e.g., < 1MB).

## 2. API Design Draft

```swift
extension UIImage {
    // Watermark
    func withWatermark(text: String, point: CGPoint, attributes: [NSAttributedString.Key: Any]? = nil) -> UIImage?
    func withWatermark(image: UIImage, point: CGPoint, opacity: CGFloat = 1.0) -> UIImage?
    
    // Padding
    func withPadding(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat, color: UIColor = .clear) -> UIImage?
    
    // Stitching (Static method)
    static func stitch(images: [UIImage], axis: NSLayoutConstraint.Axis, spacing: CGFloat = 0) -> UIImage?
    
    // Masking
    func withRoundedCorners(radius: CGFloat) -> UIImage?
    func masked(with maskImage: UIImage) -> UIImage? // Alpha mask
    
    // Effects
    func tinted(color: UIColor) -> UIImage?
    func blurred(radius: CGFloat) -> UIImage?
    
    // Compression
    func compress(toMaxBytes maxBytes: Int) -> Data?
}
```

## 3. Implementation Strategy

- **CoreGraphics (`UIGraphicsImageRenderer`)**: Will be used for Padding, Watermarking, Stitching, and Masking (Rounded Corners) because it provides pixel-perfect drawing and context management on the CPU.
- **CoreImage**: Will be used for Blur filters as it leverages the GPU.
- **Thread Safety**: All methods will be synchronous but thread-safe (creating their own contexts). The consumer (ViewModel) is responsible for calling them on a background task.

## 4. Testing Plan

- **Unit Tests**: Add `testWatermark`, `testPadding`, `testStitch`, `testBlur` in `UIImageExtensionTests`.
- **Visual Verification**: Since these are visual features, the unit tests will verify output image dimensions and non-nil results.
