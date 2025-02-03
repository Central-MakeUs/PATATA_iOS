//
//  UserDefaultManager.swift
//  Patata
//
//  Created by 김진수 on 2/4/25.
//

import Foundation

final actor UserDefaultsManager {
    
    enum Key: String {
        case isFirst
        
        var value: String {
            return self.rawValue
        }
    }
    
    @UserDefaultsWrapper(key: Key.isFirst.value, placeValue: true)
    static var isFirst: Bool
}
