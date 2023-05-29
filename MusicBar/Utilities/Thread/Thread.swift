//
//  Thread.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 23/5/23.
//

import Foundation

class ThreadRunner {
    static let customObserver = CFRunLoopObserverCreateWithHandler(nil, CFRunLoopActivity.allActivities.rawValue , true, 0) { observer, activity in
        switch (activity) {
        case .entry:
            break
        case .beforeTimers:
            break
        case .beforeSources:
            break
        case .beforeWaiting:
            break
        case .afterWaiting:
            break
        case .exit:
            break
        case .allActivities:
            break
        default:
            break
        }
    }
}
