//
//  NSImage+Extension.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 1/6/23.
//

import SwiftUI

extension NSImage {
    func scaledCopy(sizeOfLargerSide: CGFloat) -> NSImage {
        var newW: CGFloat
        var newH: CGFloat
        var scaleFactor: CGFloat
        
        if self.size.width > self.size.height {
            scaleFactor = self.size.width / sizeOfLargerSide
            newW = sizeOfLargerSide
            newH = self.size.height / scaleFactor
        }
        else {
            scaleFactor = self.size.height / sizeOfLargerSide
            newH = sizeOfLargerSide
            newW = self.size.width / scaleFactor
        }
        
        return resizedCopy(w: newW, h: newH)
    }
    
    
    func resizedCopy(w: CGFloat, h: CGFloat) -> NSImage {
        let destSize = NSMakeSize(w, h)
        let newImage = NSImage(size: destSize)
        
        newImage.lockFocus()
        
        self.draw(in: NSRect(origin: .zero, size: destSize),
                  from: NSRect(origin: .zero, size: self.size),
                  operation: .copy,
                  fraction: CGFloat(1))
        
        newImage.unlockFocus()
        
        guard let data = newImage.tiffRepresentation,
              let result = NSImage(data: data)
        else { return NSImage() }
        
        return result
    }
    
    public func writePNG(toURL url: URL) {
        guard let data = tiffRepresentation,
              let rep = NSBitmapImageRep(data: data),
              let imgData = rep.representation(using: .png, properties: [.compressionFactor : NSNumber(floatLiteral: 1.0)])
        else {
            Swift.print("\(self) Error Function '\(#function)' Line: \(#line) No tiff rep found for image writing to \(url)")
            return
        }
        
        do { try imgData.write(to: url) }
        catch let error {
            Swift.print("\(self) Error Function '\(#function)' Line: \(#line) \(error.localizedDescription)")
        }
    }
    
    func getAspectRatio() -> Double {
        return self.size.width / self.size.height
    }
    
    func asCIImage() -> CIImage? {
        if let cgImage = self.asCGImage() {
            return CIImage(cgImage: cgImage)
        }
        return nil
    }
    
    /// Create a CGImage using the best representation of the image available in the NSImage for the image size
    ///
    /// - Returns: Converted image, or nil
    func asCGImage() -> CGImage? {
        var rect = NSRect(origin: CGPoint(x: 0, y: 0), size: self.size)
        return self.cgImage(forProposedRect: &rect, context: NSGraphicsContext.current, hints: nil)
    }
    
    var averageColor: Color? {
        guard let inputImage = self.asCIImage() else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)
        
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return Color(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255)
    }
}
