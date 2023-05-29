//
//  View+Extension.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 23/5/23.
//

import Foundation

import SwiftUI
import Combine

extension View {
    /// A backwards compatible wrapper for iOS 14 `onChange`
    @ViewBuilder func onValueChanged<T: Equatable>(of value: T, perform onChange: @escaping (T) -> Void) -> some View {
        self.onReceive(Just(value)) { (value) in
            onChange(value)
        }
    }
}
