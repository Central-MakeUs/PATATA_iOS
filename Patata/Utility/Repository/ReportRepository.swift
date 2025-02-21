//
//  ReportRepository.swift
//  Patata
//
//  Created by 김진수 on 2/20/25.
//

import Foundation
import ComposableArchitecture

final class ReportRepository: @unchecked Sendable {
    @Dependency(\.networkManager) var networkManager
    
    func reportSpot(spotId: Int?, reason: String, des: String) async throws(PAError) -> Bool {
        if let spotId {
            let result = try await networkManager.requestNetworkWithRefresh(dto: ReportDTO.self, router: ReportRouter.reportSpot(spotId: spotId, ReportRequestDTO(reason: reason, description: des)))
            
            return result.isSuccess
        } else {
            return false
        }
    }
    
    func reportUser(memberId: Int?, reason: String, des: String) async throws(PAError) -> Bool {
        if let memberId {
            let result = try await networkManager.requestNetworkWithRefresh(dto: ReportDTO.self, router: ReportRouter.reportMember(memberId: memberId, ReportRequestDTO(reason: reason, description: des)))
            
            return result.isSuccess
        } else {
            return false
        }
    }
    
    func reportReview(reviewId: Int?, reason: String, des: String) async throws(PAError) -> Bool {
        if let reviewId {
            let result = try await networkManager.requestNetworkWithRefresh(dto: ReportDTO.self, router: ReportRouter.reportReview(reviewId: reviewId, ReportRequestDTO(reason: reason, description: des)))
            
            return result.isSuccess
        } else {
            return false
        }
    }
}

extension ReportRepository: DependencyKey {
    static let liveValue: ReportRepository = ReportRepository()
}

extension DependencyValues {
    var reportRepository: ReportRepository {
        get { self[ReportRepository.self] }
        set { self[ReportRepository.self] = newValue }
    }
}
