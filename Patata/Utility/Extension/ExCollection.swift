//
//  ExCollection.swift
//  Patata
//
//  Created by 김진수 on 2/17/25.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
