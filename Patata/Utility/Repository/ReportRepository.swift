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
    
    func reportSpot(spotId: Int, reason: String, des: String) async throws(PAError) -> Bool {
        let result = try await networkManager.requestNetworkWithRefresh(dto: ReportDTO.self, router: ReportRouter.reportSpot(spotId: spotId, ReportRequestDTO(reason: reason, description: des)))
        
        return result.isSuccess
    }
    
    func reportUser(memberId: Int, reason: String, des: String) async throws(PAError) -> Bool {
        let result = try await networkManager.requestNetworkWithRefresh(dto: ReportDTO.self, router: ReportRouter.reportMember(memberId: memberId, ReportRequestDTO(reason: reason, description: des)))
        
        return result.isSuccess
    }
    
    func reportReview(reviewId: Int, reason: String, des: String) async throws(PAError) -> Bool {
        let result = try await networkManager.requestNetworkWithRefresh(dto: ReportDTO.self, router: ReportRouter.reportReview(reviewId: reviewId, ReportRequestDTO(reason: reason, description: des)))
        
        return result.isSuccess
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
