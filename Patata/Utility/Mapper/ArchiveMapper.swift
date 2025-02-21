//
//  ArchiveMapper.swift
//  Patata
//
//  Created by 김진수 on 2/12/25.
//

import Foundation
import ComposableArchitecture

struct ArchiveMapper: Sendable {
    func dtoToEntity(_ dto: [ArchiveResultItemDTO]) -> ArchiveEntity {
        return ArchiveEntity(
            totalScraps: dto[0].totalScraps,
            isArchive: dto[0].message == "스크랩되었습니다" ? true : false
        )
    }
    
    func dtoToEntity(_ dtos: [ArchiveItemDTO]) async -> [ArchiveListEntity] {
        return await dtos.asyncMap { dtoToEntity($0) }
    }
    
    func dtoToEntity(_ dto: MySpotCountDTO) async -> MySpotsEntity {
        return await MySpotsEntity(spotCount: dto.totalSpots, mySpots: dto.spots.asyncMap { dtoToEntity($0) })
    }
    
    func dtoToEntity(_ dto: MyPageItemDTO) -> MyPageEntity {
        return MyPageEntity(memberId: dto.memberId, nickName: dto.nickName, email: dto.email, profileImage: URL(string: dto.profileImage ?? ""))
    }
}

extension ArchiveMapper {
    private func dtoToEntity(_ dto: ArchiveItemDTO) -> ArchiveListEntity {
        return ArchiveListEntity(spotId: dto.spotId, spotName: dto.spotName, representativeImageUrl: URL(string: dto.representativeImageUrl))
    }
}

extension ArchiveMapper: DependencyKey {
    static let liveValue: ArchiveMapper = ArchiveMapper()
}

extension DependencyValues {
    var archiveMapper: ArchiveMapper {
        get { self[ArchiveMapper.self] }
        set { self[ArchiveMapper.self] = newValue }
    }
}
