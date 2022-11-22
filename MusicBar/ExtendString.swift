//
//  ExtendString.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 11/21/22.
//

import Foundation

extension String {
    mutating func cut(separator: [String]) {
        var joined = self
        for i in separator {
            joined = joined.components(separatedBy: i)[0]
        }
        print(joined.trimmingCharacters(in: .whitespaces))
        self = joined.trimmingCharacters(in: .whitespaces)
    }
}
