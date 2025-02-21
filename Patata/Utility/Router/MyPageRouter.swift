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
    case fetchMyPage
    case changeImage(Data)
}

extension MyPageRouter {
    var method: HTTPMethod {
        switch self {
        case .changeNickname, .changeImage:
            return .patch
        case .fetchMySpot, .fetchMyPage:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .changeNickname:
            return "/member/nickname"
        case .fetchMySpot:
            return "/spot/my-spots"
        case .fetchMyPage:
            return "/member/profile"
        case .changeImage:
            return "/member/profileImage"
        }
    }
    
    var optionalHeaders: HTTPHeaders? {
        switch self {
        case .changeNickname, .fetchMySpot, .fetchMyPage:
            return HTTPHeaders([
                HTTPHeader(name: "Content-Type", value: "application/json")
            ])
        case .changeImage:
            return HTTPHeaders([
                HTTPHeader(name: "Content-Type", value: "multipart/form-data")
            ])
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .changeNickname, .fetchMySpot, .fetchMyPage, .changeImage:
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        case .changeNickname(let nickName):
            return requestToBody(nickName)
        case .fetchMySpot, .fetchMyPage, .changeImage:
            return nil
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .changeNickname:
            return .json
        case .fetchMySpot, .fetchMyPage:
            return .url
        case let .changeImage(image):
            let formData = MultipartFormData()
            
            formData.append(
                image,
                withName: "profileImage",
                fileName: "profile.jpeg",  // 파일 이름 추가
                mimeType: "image/jpeg"    // MIME 타입 추가
            )
            
            return .multiPart(formData)
        }
    }
}

