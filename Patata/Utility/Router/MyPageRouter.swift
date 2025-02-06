//
//  MyPageRouter.swift
//  Patata
//
//  Created by 김진수 on 2/6/25.
//

import Foundation
import Alamofire

enum MyPageRouter: Router {
    case changeNickname(NicknameRequestDTO)
}

extension MyPageRouter {
    var method: HTTPMethod {
        switch self {
        case .changeNickname:
            return .patch
        }
    }
    
    var path: String {
        switch self {
        case .changeNickname:
            return "/member/nickname"
        }
    }
    
    var optionalHeaders: HTTPHeaders? {
        switch self {
        case .changeNickname:
            return HTTPHeaders([
                HTTPHeader(name: "Content-Type", value: "application/json")
            ])
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .changeNickname:
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        case .changeNickname(let nickName):
            return requestToBody(nickName)
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .changeNickname:
            return .json
        }
    }
}

