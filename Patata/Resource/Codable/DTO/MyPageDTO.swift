//
//  MyPageDTO.swift
//  Patata
//
//  Created by 김진수 on 2/21/25.
//

import Foundation

struct MyPageDTO: DTO {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: MyPageItemDTO
}

struct MyPageItemDTO: DTO {
    let memberId: Int
    let nickName: String
    let email: String
    let profileImage: String?
}
