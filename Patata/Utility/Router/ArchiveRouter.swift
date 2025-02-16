//
//  ArchiveRouter.swift
//  Patata
//
//  Created by 김진수 on 2/12/25.
//

import Foundation
import Alamofire

enum ArchiveRouter: Router {
    case toggleArchive([Int])
    case fetchArchiveList
}

extension ArchiveRouter {
    var method: HTTPMethod {
        switch self {
        case .toggleArchive:
            return .patch
        case .fetchArchiveList:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case let .toggleArchive(spotId):
            return "/scrap/toggle"
        case .fetchArchiveList:
            return "/scrap"
        }
    }
    
    var optionalHeaders: HTTPHeaders? {
        switch self {
        case .toggleArchive, .fetchArchiveList:
            return HTTPHeaders([
                HTTPHeader(name: "Content-Type", value: "application/json")
            ])
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .toggleArchive, .fetchArchiveList:
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        case let .toggleArchive(spotIds):
            return requestToBody(spotIds)
            
        case .fetchArchiveList:
            return nil
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .toggleArchive:
            return .json
        case .fetchArchiveList:
            return .url
        }
    }
}

