//
//  MediaControls.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 9/6/23.
//

import SwiftUI

enum MediaControlsButtons: String {
    case playPause = "play.fill"
    case forward = "forward.fill"
    case rewind = "backward.fill"
}

@available(macOS 11.0, *)
struct MediaControls: View {
    
    @Binding var buttonsHovered: ButtonHovered
    var command: MediaControlsButtons
    var isPlaying: Bool?
    
    func getToggle() -> Binding<Bool> {
        switch command {
        case .playPause:
            return $buttonsHovered.play
        case .forward:
            return $buttonsHovered.next
        case .rewind:
            return $buttonsHovered.prev
        }
    }
    
    func getAction() -> MediaRemote.MediaRemoteCommands {
        switch command {
        case .playPause:
            return .togglePlayPause
        case .forward:
            return .forward
        case .rewind:
            return .rewind
        }
    }
    
    func getImage() -> String {
        switch command {
        case .playPause:
            if isPlaying == true {
                return "pause.fill"
            } else {
                return command.rawValue
            }
        case .forward, .rewind:
            return command.rawValue
        }
    }
    
    var body: some View {
        Button(action: {
            MediaRemote().controlMedia(command: getAction())
        }) {
            HStack {
                Image(systemName: getImage())
                    .font(.system(size: (command == .playPause) ? 36 : 24))
            }.actionsButton(toggled: getToggle())
        }.buttonStyle(PlainButtonStyle())
    }
}
