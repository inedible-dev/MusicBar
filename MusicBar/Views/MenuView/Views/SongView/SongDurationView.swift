//
//  SongDurationView.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 8/6/23.
//

import SwiftUI

func timeString(time: Double) -> String {
    if let converted = Int(exactly: time.rounded()) {
        let hour =  Int(converted / 3600)
        let minute = Int(converted / 60 % 60)
        let second = Int(converted % 60)
        
        if hour > 0 {
            return String(format: "%02i:%02i:%02i", hour, minute, second)
        } else {
            return String(format: "%02i:%02i", minute, second)
        }
    }
    return String(format: "%02i:%02i", "--", "--")
}

struct SongDurationView: View {
    
    var elapsedTime: Double
    var elapsedTimeState: ElapsedTimeState?
    var duration: Double
    
    func showElapsedTime() -> String {
        if !elapsedTime.isNaN || elapsedTime > 0 {
            return timeString(time: elapsedTime)
        } else {
            return "--:--"
        }
    }
    
    func showRemainingTime() -> String {
        if (!duration.isNaN && !elapsedTime.isNaN) || (duration > 0 && elapsedTime > 0) {
            return "-\(timeString(time: duration - elapsedTime))"
        } else {
            return "--:--"
        }
    }
    
    var body: some View {
        HStack {
            Text(showElapsedTime())
            Spacer()
            Text(showRemainingTime())
        }.opacity(0.5)
            .font(.system(size: 11))
    }
}
