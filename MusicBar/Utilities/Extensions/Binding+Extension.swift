//
//  Binding+Extension.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 11/12/23.
//

import SwiftUI

extension Binding where Value == Int {
    func max(_ limit: Int) -> Self {
        if self.wrappedValue > limit {
            DispatchQueue.main.async {
                self.wrappedValue = Int(self.wrappedValue/10)
            }
        }
        return self
    }
}
