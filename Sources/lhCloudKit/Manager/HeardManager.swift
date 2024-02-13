//
//  File.swift
//  
//
//  Created by Nicolas Le Gorrec on 2/10/24.
//

import CloudKit

public struct HeardManager {

    private let ck: CloudKitable

    public init(ck: CloudKitable = LhCloudKitMock()) {
        self.ck = ck
    }

    public func createPublicHeardModel(_ heardModel: Heard) async throws -> Heard {
        let record = heardModel.record
        let savedHeardRecord = try await ck.save(record: record, db: .pubDb)

        guard let heardModel = Heard(record: savedHeardRecord) else { throw CloudKitError.badRecordData }

        return heardModel
    }

    public func getAllHeardModels() async throws -> [Heard] {
        return try await ck.query(.heard(.getAllHeardModels))
    }
}
