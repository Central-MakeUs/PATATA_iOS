//
//  ReviewRepository.swift
//  Patata
//
//  Created by 김진수 on 2/14/25.
//

import Foundation
import ComposableArchitecture

final class ReviewRepository: @unchecked Sendable {
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.reviewMapper) var mapper
    
    func createReview(spotId: Int, text: String) async throws(PAError) -> ReviewEntity {
        let dto = try await networkManager.requestNetworkWithRefresh(dto: ReviewDTO.self, router: ReviewRouter.createReview(ReviewRequestDTO(spotId: spotId, reviewText: text))).result
        
        return mapper.dtoToEntity(dto)
    }
    
    func deleteReview(reviewId: Int) async throws(PAError) {
        let msg = try await networkManager.requestNetworkWithRefresh(dto: DeleteReviewDTO.self, router: ReviewRouter.deleteReview(reviewId: reviewId)).message
        
        print("success", msg)
    }
}

extension ReviewRepository: DependencyKey {
    static let liveValue: ReviewRepository = ReviewRepository()
}

extension DependencyValues {
    var reviewRepository: ReviewRepository {
        get { self[ReviewRepository.self] }
        set { self[ReviewRepository.self] = newValue }
    }
}
