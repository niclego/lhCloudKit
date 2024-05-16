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

    public func getHeardActivityFeed(for followingRecordNames: [String]) async throws -> ([Heard], CKQueryOperation.Cursor?) {
        let result = try await ck.records(for: .heard(.getHeardActivityFeed(followingRecordNames)), resultsLimit: 25, db: .pubDb)
        let feed = result.matchResults.compactMap { try? $0.1.get() }.compactMap { Heard(record: $0) }
        return (feed, result.queryCursor)
    }

    public func getNearbyHeardActivityFeed(from location: CLLocation) async throws -> ([Heard], CKQueryOperation.Cursor?) {
        let result = try await ck.records(for: .heard(.getNearbyActivityFeed(location)), resultsLimit: 25, db: .pubDb)
        let feed = result.matchResults.compactMap { try? $0.1.get() }.compactMap { Heard(record: $0) }
        return (feed, result.queryCursor)
    }

    public func continueHeardActivityFeed(cursor: CKQueryOperation.Cursor) async throws -> ([Heard], CKQueryOperation.Cursor?) {
        let result = try await ck.records(startingAt: cursor, resultsLimit: 25, db: .pubDb)
        let feed = result.matchResults.compactMap { try? $0.1.get() }.compactMap { Heard(record: $0) }
        return (feed, result.queryCursor)
    }

    public func continueNearbyHeardActivityFeed(cursor: CKQueryOperation.Cursor) async throws -> ([Heard], CKQueryOperation.Cursor?) {
        let result = try await ck.records(startingAt: cursor, resultsLimit: 25, db: .pubDb)
        let feed = result.matchResults.compactMap { try? $0.1.get() }.compactMap { Heard(record: $0) }
        return (feed, result.queryCursor)
    }
}
