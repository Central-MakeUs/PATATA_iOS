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
    case fetchMySpot
}

extension MyPageRouter {
    var method: HTTPMethod {
        switch self {
        case .changeNickname:
            return .patch
        case .fetchMySpot:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .changeNickname:
            return "/member/nickname"
        case .fetchMySpot:
            return "/spot/my-spots"
        }
    }
    
    var optionalHeaders: HTTPHeaders? {
        switch self {
        case .changeNickname, .fetchMySpot:
            return HTTPHeaders([
                HTTPHeader(name: "Content-Type", value: "application/json")
            ])
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .changeNickname, .fetchMySpot:
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        case .changeNickname(let nickName):
            return requestToBody(nickName)
        case .fetchMySpot:
            return nil
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .changeNickname:
            return .json
        case .fetchMySpot:
            return .url
        }
    }
}

