//
//  MyPageEntity.swift
//  Patata
//
//  Created by 김진수 on 2/21/25.
//

import Foundation

struct MyPageEntity: Entity {
    let memberId: Int
    let nickName: String
    let email: String
    let profileImage: URL?
    
    init(memberId: Int = 0, nickName: String = "", email: String = "", profileImage: URL? = nil) {
        self.memberId = memberId
        self.nickName = nickName
        self.email = email
        self.profileImage = profileImage
    }
}
