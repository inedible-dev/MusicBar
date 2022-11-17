//
//  ExtendNSImage.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 11/16/22.
//

import Foundation
import AppKit

extension NSImage {
    func scaledCopy( sizeOfLargerSide: CGFloat) ->  NSImage {
        var newW: CGFloat
        var newH: CGFloat
        var scaleFactor: CGFloat
        
        if ( self.size.width > self.size.height) {
            scaleFactor = self.size.width / sizeOfLargerSide
            newW = sizeOfLargerSide
            newH = self.size.height / scaleFactor
        }
        else{
            scaleFactor = self.size.height / sizeOfLargerSide
            newH = sizeOfLargerSide
            newW = self.size.width / scaleFactor
        }
        
        return resizedCopy(w: newW, h: newH)
    }
    
    
    func resizedCopy( w: CGFloat, h: CGFloat) -> NSImage {
        let destSize = NSMakeSize(w, h)
        let newImage = NSImage(size: destSize)
        
        newImage.lockFocus()
        
        self.draw(in: NSRect(origin: .zero, size: destSize),
                  from: NSRect(origin: .zero, size: self.size),
                  operation: .copy,
                  fraction: CGFloat(1)
        )
        
        newImage.unlockFocus()
        
        guard let data = newImage.tiffRepresentation,
              let result = NSImage(data: data)
        else { return NSImage() }
        
        return result
    }
    
    public func writePNG(toURL url: URL) {
        guard let data = tiffRepresentation,
              let rep = NSBitmapImageRep(data: data),
              let imgData = rep.representation(using: .png, properties: [.compressionFactor : NSNumber(floatLiteral: 1.0)]) else {

            Swift.print("\(self) Error Function '\(#function)' Line: \(#line) No tiff rep found for image writing to \(url)")
            return
        }

        do {
            try imgData.write(to: url)
        }catch let error {
            Swift.print("\(self) Error Function '\(#function)' Line: \(#line) \(error.localizedDescription)")
        }
    }
}
