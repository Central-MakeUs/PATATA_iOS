//
//  ArchiveRepostiory.swift
//  Patata
//
//  Created by 김진수 on 2/12/25.
//

import Foundation
import ComposableArchitecture

final class ArchiveRepostiory: @unchecked Sendable {
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.archiveMapper) var mapper
    
    func toggleArchive(spotId: String) async throws(PAError) -> ArchiveEntity {
        let dto = try await networkManager.requestNetworkWithRefresh(dto: ArchiveResultDTO.self, router: ArchiveRouter.toggleArchive(spotId)).result
        
        return mapper.dtoToEntity(dto)
    }
}

extension ArchiveRepostiory: DependencyKey {
    static let liveValue: ArchiveRepostiory = ArchiveRepostiory()
}

extension DependencyValues {
    var archiveRepostiory: ArchiveRepostiory {
        get { self[ArchiveRepostiory.self] }
        set { self[ArchiveRepostiory.self] = newValue }
    }
}
