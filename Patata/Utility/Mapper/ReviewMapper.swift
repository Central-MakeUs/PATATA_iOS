//
//  ReviewMapper.swift
//  Patata
//
//  Created by 김진수 on 2/14/25.
//

import Foundation
import ComposableArchitecture

struct ReviewMapper: Sendable {
    func dtoToEntity(_ dto: ReviewResultDTO) -> ReviewEntity {
        return ReviewEntity(reviewId: dto.reviewId, reviewText: dto.reviewText, reivewDate: DateManager.shared.formatToCustomDate(dto.reviewDate))
    }
}

extension ReviewMapper: DependencyKey {
    static let liveValue: ReviewMapper = ReviewMapper()
}

extension DependencyValues {
    var reviewMapper: ReviewMapper {
        get { self[ReviewMapper.self] }
        set { self[ReviewMapper.self] = newValue }
    }
}
