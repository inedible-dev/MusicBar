//
//  DurationBar.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 1/6/23.
//

import SwiftUI

struct DurationBar: View {
    var value: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(.white)
                Rectangle()
                    .frame(
                        width: abs(min(CGFloat(self.value) * geometry.size.width, geometry.size.width)),
                        height: abs(geometry.size.height)
                    )
                    .foregroundColor(.white)
                    .animation(.linear(duration: 0.2))
            }.cornerRadius(45.0)
        }
    }
}
