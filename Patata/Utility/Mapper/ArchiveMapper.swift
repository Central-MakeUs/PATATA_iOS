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
