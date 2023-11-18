//
//  StatusBarSettingsView.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 3/10/23.
//

import SwiftUI

enum BlockType: String {
    case unApplied = "Blocks",
         applied = "Applied Blocks"
}

@available(macOS 13.0, *)
struct StatusBarSettingsView: View {
    @State var unAppliedBlocks: [String] = ["Artwork", "Song Title", "-", "Song Artist"]
    @State var appliedBlocks: [String] = []
    
    var body: some View {
        VStack(spacing: 12) {
            DropView(type: .unApplied, unAppliedBlocks: $unAppliedBlocks, appliedBlocks: $appliedBlocks, tasks: $unAppliedBlocks)
            DropView(type: .applied, unAppliedBlocks: $unAppliedBlocks, appliedBlocks: $appliedBlocks, tasks: $appliedBlocks)
        }.padding()
    }
}
