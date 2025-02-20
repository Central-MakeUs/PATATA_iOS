//
//  ReportRouter.swift
//  Patata
//
//  Created by 김진수 on 2/20/25.
//

import Foundation
import Alamofire

enum ReportRouter: Router {
    case reportSpot(spotId: Int, ReportRequestDTO)
    case reportReview(reviewId: Int, ReportRequestDTO)
    case reportMember(memberId: Int, ReportRequestDTO)
}

extension ReportRouter {
    var method: HTTPMethod {
        switch self {
        case .reportSpot, .reportReview, .reportMember:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case let .reportSpot(spotId, _):
            return "/report/spot/\(spotId)"
        case let .reportReview(reviewId, _):
            return "/report/review/\(reviewId)"
        case let .reportMember(memberId, _):
            return "/report/member/\(memberId)"
        }
    }
    
    var optionalHeaders: HTTPHeaders? {
        switch self {
        case .reportSpot, .reportReview, .reportMember:
            return HTTPHeaders([
                HTTPHeader(name: "Content-Type", value: "application/json")
            ])
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .reportSpot, .reportReview, .reportMember:
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        case let .reportSpot(_, reportDTO), let .reportReview(_, reportDTO), let .reportMember(_, reportDTO):
            return requestToBody(reportDTO)
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .reportSpot, .reportReview, .reportMember:
            return .json
        }
    }
}
