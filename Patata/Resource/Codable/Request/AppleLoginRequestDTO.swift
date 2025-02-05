//
//  AppleLoginRequestDTO.swift
//  Patata
//
//  Created by 김진수 on 2/5/25.
//

import Foundation

struct AppleLoginRequestDTO: DTO, Encodable {
    let identityToken: String
}
