//
//  ExtendString.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 11/21/22.
//

import Foundation

extension String {
    mutating func cutFeat(separator: [String]) {
        var joined = self
        for i in separator {
            joined = joined.components(separatedBy: i)[0]
        }
        self = joined.trimmingCharacters(in: .whitespaces)
    }
}
