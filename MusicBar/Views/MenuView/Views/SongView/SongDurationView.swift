//
//  SongDurationView.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 8/6/23.
//

import SwiftUI

func timeString(time: Double) -> String {
    let hour =  Int(time) / 3600
    let minute = Int(time) / 60 % 60
    let second = Int(time) % 60
    
    if hour > 0 {
        return String(format: "%02i:%02i:%02i", hour, minute, second)
    } else {
        return String(format: "%02i:%02i", minute, second)
    }
}

struct SongDurationView: View {
    
    var elapsedTime: Double
    var duration: Double
    
    var body: some View {
        HStack {
            Text(Double(elapsedTime).isNaN ? "--:--" : timeString(time: elapsedTime))
            Spacer()
            Text((Double(elapsedTime).isNaN) || (Double(duration).isNaN) ? "--:--" : "-\(timeString(time: duration - elapsedTime))")
        }.opacity(0.5)
            .font(.system(size: 11))
    }
}
