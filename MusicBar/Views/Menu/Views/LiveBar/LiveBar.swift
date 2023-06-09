//
//  LiveBar.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 8/6/23.
//

import SwiftUI

struct LiveBar: View {
    var body: some View {
        HStack(spacing: 2) {
            Rectangle()
                .fill(LinearGradient(gradient: Gradient(stops: colorStops), startPoint: .leading, endPoint: .trailing))
                .roundedCorners(radius: 4, corners: [.topLeft, .bottomLeft])
                .opacity(0.6)
            Text("LIVE")
                .fontWeight(.light)
            Rectangle()
                .fill(LinearGradient(gradient: Gradient(stops: colorStops), startPoint: .trailing, endPoint: .leading))
                .roundedCorners(radius: 4, corners: [.topRight, .bottomRight])
                .opacity(0.6)
        }.frame(height: 8).padding(.vertical, 12)
    }
}
