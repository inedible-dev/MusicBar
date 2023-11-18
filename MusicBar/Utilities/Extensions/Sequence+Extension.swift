//
//  Sequence+Extension.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 18/11/23.
//

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: [Iterator.Element: Bool] = [:]
        return self.filter { seen.updateValue(true, forKey: $0) == nil }
    }
}
