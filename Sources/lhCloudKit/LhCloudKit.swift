//
//  File.swift
//  
//
//  Created by Nicolas Le Gorrec on 2/4/24.
//

import CloudKit

public enum LhDatabase {
    case pubDb
    case privDb
}

public enum CloudKitError: Error {
    case lhUserAlreadyExistsForSystemUser
    case lhUserDoesNotExistForSystemUser
    case usernameAlreadyTaken
    case badRecordData
}

public struct LhCloudKit: CloudKitable {
    
    public typealias RecordsAndCursorResponse = (matchResults: [(CKRecord.ID, Result<CKRecord, Error>)], queryCursor: CKQueryOperation.Cursor?)

    private let container: CKContainer
    private let pubDb: CKDatabase
    private let privDb: CKDatabase

    public init(containerId: String) {
        self.container = CKContainer(identifier: containerId)
        self.pubDb = container.publicCloudDatabase
        self.privDb = container.privateCloudDatabase
    }

    public func save(record: CKRecord, db: LhDatabase) async throws -> CKRecord {
        let record = try await pubDb.save(record)
        return record
    }

    public func record(for recordId: CKRecord.ID, db: LhDatabase) async throws -> CKRecord {
        return try await get(recordId, db: db)
    }

    public func selfRecordId() async throws -> CKRecord.ID {
        return try await container.userRecordID()
    }

    private func get(_ recordId: CKRecord.ID, db: LhDatabase) async throws -> CKRecord {
        switch db {
        case .pubDb:
            return try await publicDbGet(recordId)
        case .privDb:
            return try await privateDbGet(recordId)
        }
    }

    private func privateDbGet(_ recordId: CKRecord.ID) async throws -> CKRecord {
        return try await privDb.record(for: recordId)
    }

    private func publicDbGet(_ recordId: CKRecord.ID) async throws -> CKRecord {
        return try await pubDb.record(for: recordId)
    }

    private func db(_ db: LhDatabase) async throws -> CKDatabase {
        switch db {
        case .pubDb: return pubDb
        case .privDb: return privDb
        }
    }

    public func records(for query: Query, resultsLimit: Int? = CKQueryOperation.maximumResults, db: LhDatabase) async throws -> RecordsAndCursorResponse {
        let query = query.query
        let ckQuery = CKQuery(recordType: query.recordType, predicate: query.predicate ?? NSPredicate(value: true))
        ckQuery.sortDescriptors = [NSSortDescriptor(key: query.sortDescriptorKey, ascending: false)]
        return try await self.db(db).records(matching: ckQuery, resultsLimit: resultsLimit ?? CKQueryOperation.maximumResults)
    }

    public func records(startingAt cursor: CKQueryOperation.Cursor, resultsLimit: Int? = CKQueryOperation.maximumResults, db: LhDatabase) async throws -> (matchResults: [(CKRecord.ID, Result<CKRecord, Error>)], queryCursor: CKQueryOperation.Cursor?) {
        return try await self.db(db).records(continuingMatchFrom: cursor, resultsLimit: resultsLimit ??  CKQueryOperation.maximumResults)
    }
}
