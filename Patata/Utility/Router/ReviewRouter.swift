//
//  ReviewRouter.swift
//  Patata
//
//  Created by 김진수 on 2/14/25.
//

import Foundation
import Alamofire

enum ReviewRouter: Router {
    case createReview(ReviewRequestDTO)
    case deleteReview(reviewId: Int)
}

extension ReviewRouter {
    var method: HTTPMethod {
        switch self {
        case .createReview:
            return .post
        case .deleteReview:
            return .delete
        }
    }
    
    var path: String {
        switch self {
        case .createReview:
            return "/review/create"
        case let .deleteReview(reviewId):
            return "/review/delete/\(reviewId)"
        }
    }
    
    var optionalHeaders: HTTPHeaders? {
        switch self {
        case .createReview, .deleteReview:
            return HTTPHeaders([
                HTTPHeader(name: "Content-Type", value: "application/json")
            ])
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .createReview, .deleteReview:
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        case let .createReview(requestDTO):
            return requestToBody(requestDTO)
        case .deleteReview:
            return nil
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .createReview:
            return .json
        case .deleteReview:
            return .url
        }
    }
}
