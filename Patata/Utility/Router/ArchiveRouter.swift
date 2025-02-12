//
//  ArchiveRouter.swift
//  Patata
//
//  Created by 김진수 on 2/12/25.
//

import Foundation
import Alamofire

enum ArchiveRouter: Router {
    case toggleArchive(String)
}

extension ArchiveRouter {
    var method: HTTPMethod {
        switch self {
        case .toggleArchive:
            return .patch
        }
    }
    
    var path: String {
        switch self {
        case let .toggleArchive(spotId):
            return "/scrap/\(spotId)"
        }
    }
    
    var optionalHeaders: HTTPHeaders? {
        switch self {
        case .toggleArchive:
            return HTTPHeaders([
                HTTPHeader(name: "Content-Type", value: "application/json")
            ])
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .toggleArchive:
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        case .toggleArchive:
            return nil
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .toggleArchive:
            return .json
        }
    }
}

