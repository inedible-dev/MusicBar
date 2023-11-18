//
//  ReorderableForEach.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 18/11/23.
//

import SwiftUI
import UniformTypeIdentifiers

@available(macOS 11.0, *)
public struct ReorderableForEach<Content>: View
where Content : View {
    @Binding var data: [String]
    @Binding var draggedItem: String
    var allowReorder: Bool? = true
    private let content: (String, Bool) -> Content
    
    @State private var hasChangedLocation: Bool = false
    
    public init(_ data: Binding<[String]>,
                _ draggedItem: Binding<String>,
                _ allowReorder: Bool?,
                @ViewBuilder content: @escaping (String, Bool) -> Content) {
        _data = data
        _draggedItem = draggedItem
        self.allowReorder = allowReorder
        self.content = content
    }
    
    public var body: some View {
        ForEach(data, id: \.self) { item in
            content(item, hasChangedLocation && draggedItem == item)
                .onDrag {
                    draggedItem = item
                    return NSItemProvider(object: item as NSString)
                }
                .onDrop(of: [UTType.plainText], delegate: ReorderDropDelegate(
                    item: item,
                    data: $data,
                    draggedItem: $draggedItem,
                    hasChangedLocation: $hasChangedLocation,
                    allowReorder: allowReorder))
        }
    }
    
    struct ReorderDropDelegate: DropDelegate {
        let item: String
        @Binding var data: [String]
        @Binding var draggedItem: String
        @Binding var hasChangedLocation: Bool
        
        var allowReorder: Bool?
        
        func dropEntered(info: DropInfo) {
            if allowReorder == true  {
                guard item != draggedItem,
                      let from = data.firstIndex(of: draggedItem),
                      let to = data.firstIndex(of: item)
                else {
                    return
                }
                hasChangedLocation = true
                if data[to] != draggedItem {
                    withAnimation {
                        data.move(fromOffsets: IndexSet(integer: from),
                                  toOffset: (to > from) ? to + 1 : to)
                    }
                }
            }
        }
        
        func dropUpdated(info: DropInfo) -> DropProposal? {
                DropProposal(operation: .move)
        }
        
        func performDrop(info: DropInfo) -> Bool {
            hasChangedLocation = false
            draggedItem = ""
            return true
        }
    }
}
