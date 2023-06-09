//
//  MediaControls.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 9/6/23.
//

import SwiftUI

enum MediaControlsButtons: String {
    case play = "play.fill"
    case pause = "pause.fill"
    case forward = "forward.fill"
    case rewind = "backward.fill"
}

@available(macOS 11.0, *)
struct MediaControls: View {
    
    @Binding var buttonsHovered: ButtonHovered
    var command: MediaControlsButtons
    
    func getToggle() -> Binding<Bool> {
        switch command {
        case .play, .pause:
            return $buttonsHovered.play
        case .forward:
            return $buttonsHovered.next
        case .rewind:
            return $buttonsHovered.prev
        }
    }
    
    func getAction() -> MediaRemote.MediaRemoteCommands {
        switch command {
        case .play, .pause:
            return .togglePlayPause
        case .forward:
            return .forward
        case .rewind:
            return .rewind
        }
    }
    
    var body: some View {
        Button(action: {
            MediaRemote().controlMedia(command: getAction())
        }) {
            HStack {
                Image(systemName: command.rawValue)
                    .font(.system(size: (command == .pause || command == .play) ? 36 : 24))
            }.actionsButton(toggled: getToggle())
        }.buttonStyle(PlainButtonStyle())
    }
}
