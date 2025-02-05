//
//  LoginEntity.swift
//  Patata
//
//  Created by 김진수 on 2/6/25.
//

import Foundation

struct LoginEntity: Entity {
    let nickName: String?
    let email: String
    
    init(nickName: String? = nil, email: String = "") {
        self.nickName = nickName
        self.email = email
    }
}
