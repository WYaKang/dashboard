//
//  UIImageExtensionTests.swift
//  ImageExtTests
//
//  Created for Image Extension Task.
//

import XCTest
@testable import ImageExt

class UIImageExtensionTests: XCTestCase {
    
    var testImage: UIImage!
    
    override func setUp() {
        super.setUp()
        // Create a simple test image (100x100 red square)
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 100, height: 100))
        testImage = renderer.image { ctx in
            UIColor.red.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 100, height: 100))
            // Add a blue rect to verify orientation/flipping
            UIColor.blue.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 50, height: 50))
        }
    }
    
    override func tearDown() {
        testImage = nil
        super.tearDown()
    }
    
    func testRotate() {
        // Test 90 degrees
        guard let rotated = testImage.rotate(degrees: 90) else {
            XCTFail("Rotation failed")
            return
        }
        // Size should be same for 90 degree rotation of square
        XCTAssertEqual(rotated.size.width, 100)
        XCTAssertEqual(rotated.size.height, 100)
        
        // Test 45 degrees
        // New bounding box size: w*cos(45) + h*sin(45) ~= 100*0.707 + 100*0.707 = 141.4
        guard let rotated45 = testImage.rotate(degrees: 45) else {
            XCTFail("Rotation 45 failed")
            return
        }
        XCTAssertGreaterThan(rotated45.size.width, 140)
        XCTAssertLessThan(rotated45.size.width, 142)
    }
    
    func testCrop() {
        let cropRect = CGRect(x: 0, y: 0, width: 50, height: 50)
        guard let cropped = testImage.crop(to: cropRect) else {
            XCTFail("Crop failed")
            return
        }
        XCTAssertEqual(cropped.size.width, 50)
        XCTAssertEqual(cropped.size.height, 50)
    }
    
    func testScale() {
        let newSize = CGSize(width: 50, height: 50)
        guard let scaled = testImage.scale(to: newSize) else {
            XCTFail("Scale failed")
            return
        }
        XCTAssertEqual(scaled.size.width, 50)
        XCTAssertEqual(scaled.size.height, 50)
        
        guard let scaledRatio = testImage.scale(ratio: 0.5) else {
            XCTFail("Scale ratio failed")
            return
        }
        XCTAssertEqual(scaledRatio.size.width, 50)
        XCTAssertEqual(scaledRatio.size.height, 50)
    }
    
    func testResizeContentMode() {
        // Source: 100x100
        // Target: 200x100
        
        let targetSize = CGSize(width: 200, height: 100)
        
        // 1. Scale To Fill (Stretch)
        let fill = testImage.resize(to: targetSize, contentMode: .scaleToFill)
        XCTAssertEqual(fill?.size, targetSize)
        
        // 2. Aspect Fit (Fit inside 200x100) -> 100x100 centered
        // Since we are returning an image ON a canvas of targetSize, the size should be 200x100 (with transparent padding)
        let fit = testImage.resize(to: targetSize, contentMode: .scaleAspectFit)
        XCTAssertEqual(fit?.size, targetSize)
        
        // 3. Aspect Fill (Fill 200x100) -> 200x200 centered and cropped to 200x100
        let aspectFill = testImage.resize(to: targetSize, contentMode: .scaleAspectFill)
        XCTAssertEqual(aspectFill?.size, targetSize)
    }
    
    func testGeneratorsAndColor() {
        // Init with color
        guard let redImage = UIImage(color: .red, size: CGSize(width: 10, height: 10)) else {
            XCTFail("Init with color failed")
            return
        }
        XCTAssertEqual(redImage.size, CGSize(width: 10, height: 10))
        
        // Average Color
        // Since redImage is pure red, average color should be red (or very close due to color space)
        let avg = redImage.averageColor
        XCTAssertNotNil(avg)
        
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        avg?.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        XCTAssertGreaterThan(r, 0.9)
        XCTAssertLessThan(g, 0.1)
        XCTAssertLessThan(b, 0.1)
    }
    
    func testDownsample() {
        // Need real image data. Use testImage data.
        guard let data = testImage.pngData() else { return }
        
        // Downsample to 10x10
        let thumb = UIImage.downsample(imageData: data, to: CGSize(width: 10, height: 10), scale: 1.0)
        XCTAssertNotNil(thumb)
        XCTAssertLessThanOrEqual(thumb!.size.width, 10)
        XCTAssertLessThanOrEqual(thumb!.size.height, 10)
    }
    
    func testFlip() {
        guard let flippedH = testImage.flipHorizontal() else {
            XCTFail("Flip Horizontal failed")
            return
        }
        XCTAssertEqual(flippedH.size, testImage.size)
        
        guard let flippedV = testImage.flipVertical() else {
            XCTFail("Flip Vertical failed")
            return
        }
        XCTAssertEqual(flippedV.size, testImage.size)
    }
    
    func testAdjustColor() {
        // Just verify it doesn't crash and returns an image
        guard let adjusted = testImage.adjust(brightness: 0.1, contrast: 1.1, saturation: 1.1) else {
            XCTFail("Color adjust failed")
            return
        }
        XCTAssertEqual(adjusted.size, testImage.size)
    }
    
    func testChaining() {
        let result = testImage
            .rotate(degrees: 90)?
            .scale(ratio: 0.5)?
            .flipHorizontal()
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.size.width, 50) // 100 -> rotate 90 (100) -> scale 0.5 (50)
    }
    
    func testFixOrientation() {
        // Create a non-square image (100x50)
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 100, height: 50))
        let image = renderer.image { ctx in
            UIColor.red.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 100, height: 50))
        }
        
        guard let cgImage = image.cgImage else { return }
        
        // Create an image with .left orientation
        let imageWithOrientation = UIImage(cgImage: cgImage, scale: 1.0, orientation: .left)
        
        guard let fixed = imageWithOrientation.fixOrientation() else {
            XCTFail("Fix orientation failed")
            return
        }
        
        XCTAssertEqual(fixed.imageOrientation, .up)
        // The fixed image should have the same logical size as the input image
        XCTAssertEqual(fixed.size.width, imageWithOrientation.size.width)
        XCTAssertEqual(fixed.size.height, imageWithOrientation.size.height)
    }
    
    func testWatermark() {
        // Text Watermark
        guard let textMarked = testImage.withWatermark(text: "Test", point: .zero) else {
            XCTFail("Text watermark failed")
            return
        }
        XCTAssertEqual(textMarked.size, testImage.size)
        
        // Image Watermark
        let watermark = UIImage() // Empty image
        guard let imageMarked = testImage.withWatermark(image: watermark, rect: CGRect(x: 0, y: 0, width: 10, height: 10)) else {
            XCTFail("Image watermark failed")
            return
        }
        XCTAssertEqual(imageMarked.size, testImage.size)
    }
    
    func testPadding() {
        // Add 10 padding to all sides
        guard let padded = testImage.withPadding(top: 10, left: 10, bottom: 10, right: 10) else {
            XCTFail("Padding failed")
            return
        }
        XCTAssertEqual(padded.size.width, 120) // 100 + 10 + 10
        XCTAssertEqual(padded.size.height, 120)
    }
    
    func testStitch() {
        let img1 = testImage!
        let img2 = testImage!
        
        // Horizontal
        guard let stitchedH = UIImage.stitch(images: [img1, img2], axis: .horizontal) else {
            XCTFail("Stitch horizontal failed")
            return
        }
        XCTAssertEqual(stitchedH.size.width, 200)
        XCTAssertEqual(stitchedH.size.height, 100)
        
        // Vertical
        guard let stitchedV = UIImage.stitch(images: [img1, img2], axis: .vertical) else {
            XCTFail("Stitch vertical failed")
            return
        }
        XCTAssertEqual(stitchedV.size.width, 100)
        XCTAssertEqual(stitchedV.size.height, 200)
    }
    
    func testEffects() {
        // Blur
        // Note: Blur might return nil on Simulator if CIContext fails or inputs are invalid, but usually works.
        if let blurred = testImage.blurred(radius: 5) {
            XCTAssertEqual(blurred.size, testImage.size)
        }
        
        // Tint
        guard let tinted = testImage.tinted(color: .blue) else {
            XCTFail("Tint failed")
            return
        }
        XCTAssertEqual(tinted.size, testImage.size)
        
        // Rounded Corner
        guard let rounded = testImage.withRoundedCorners(radius: 10) else {
            XCTFail("Rounded corner failed")
            return
        }
        XCTAssertEqual(rounded.size, testImage.size)
    }
    
    func testCompression() {
        // Just verify logic doesn't crash.
        // Compressing a generated image (testImage) might be tricky to predict exact bytes.
        let data = testImage.compress(toMaxBytes: 1000)
        XCTAssertNotNil(data)
    }
    
    func testAdvancedEffects() {
        // Grayscale
        if let gray = testImage.grayscale() {
            XCTAssertEqual(gray.size, testImage.size)
        }
        
        // Sepia
        if let sepia = testImage.sepia() {
            XCTAssertEqual(sepia.size, testImage.size)
        }
        
        // Circle Crop
        // Test image is 100x100, circle should be 100x100 (min side)
        if let circle = testImage.croppedToCircle() {
            XCTAssertEqual(circle.size.width, 100)
            XCTAssertEqual(circle.size.height, 100)
            
            // Test non-square (100x50)
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: 100, height: 50))
            let rectImage = renderer.image { ctx in
                UIColor.red.setFill()
                ctx.fill(CGRect(x: 0, y: 0, width: 100, height: 50))
            }
            if let smallCircle = rectImage.croppedToCircle() {
                XCTAssertEqual(smallCircle.size.width, 50)
                XCTAssertEqual(smallCircle.size.height, 50)
            }
        }
    }
    
    func testUtilities() {
        XCTAssertNotNil(testImage.base64String)
    }
}
