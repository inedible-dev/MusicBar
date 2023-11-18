//
//  DropView.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 18/11/23.
//

import SwiftUI

@available(macOS 13.0, *)
struct DropView: View {
    
    let type: BlockType
    
    @State var isHovered = false
    @State var selectedTask = ""
    
    @Binding var unAppliedBlocks: [String]
    @Binding var appliedBlocks: [String]
    @Binding var tasks: [String]
    
    var body: some View {
        VStack(alignment: .leading) {
                HStack(spacing: 12) {
                    ReorderableForEach($tasks, $selectedTask, type == .applied) { task, isDragged in
                        Text(task)
                            .padding(4)
                            .background(isDragged ? Color.blue : Color.init(white: 0.6))
                            .cornerRadius(4)
                            .shadow(radius: 1, x: 1, y: 1)
                    }
                    Spacer()
                }.frame(minWidth: 200, minHeight: 30)
                .padding(6)
                .background(type == .applied ? isHovered && !tasks.contains(selectedTask) ? Color.blue : Color.init(white: 0.3) : nil)
                .roundedCorners(radius: 10, corners: .allCorners)
                .dropDestination(for: String.self) {
                    droppedBlocks, location in
                    
                    for blocks in droppedBlocks {
                        if type == .applied {
                            unAppliedBlocks.removeAll { $0 == blocks }
                        } else {
                            appliedBlocks.removeAll { $0 == blocks }
                        }
                    }
                    
                    if type == .applied {
                        let sumBlocks = appliedBlocks + droppedBlocks
                        appliedBlocks = sumBlocks.unique()
                    } else {
                        let sumBlocks = unAppliedBlocks + droppedBlocks
                        unAppliedBlocks = sumBlocks.unique()
                    }
                    
                    print(unAppliedBlocks, appliedBlocks)
                    
                    return true
                } isTargeted: { hovered in
                    isHovered = hovered
                }
        }
    }
}
