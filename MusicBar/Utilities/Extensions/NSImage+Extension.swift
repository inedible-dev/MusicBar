//
//  NSImage+Extension.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 1/6/23.
//

extension NSImage {
    func getAspectRatio() -> Double {
        return self.size.width / self.size.height
    }
}
