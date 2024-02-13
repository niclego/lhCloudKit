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
    typealias QueryResponse = (matchResults: [(CKRecord.ID, Result<CKRecord, Error>)], queryCursor: CKQueryOperation.Cursor?)

    private let container: CKContainer
    private let pubDb: CKDatabase
    private let privDb: CKDatabase

    public init(containerId: String) {
        self.container = CKContainer(identifier: containerId)
        self.pubDb = container.publicCloudDatabase
        self.privDb = container.privateCloudDatabase
    }

    public func query<T: CloudKitRecordable>(_ query: Query) async throws -> [T] {
        let query = query.query
        let ckQuery = CKQuery(recordType: query.recordType, predicate: query.predicate ?? NSPredicate(value: true))
        ckQuery.sortDescriptors = [NSSortDescriptor(key: query.sortDescriptorKey, ascending: true)]
        let result = try await records(for: ckQuery, to: query.database)
        let records = result.matchResults.compactMap { try? $0.1.get() }
        let models = records.compactMap { T(record: $0) }
        return models
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

    private func privateDbQuery(_ query: CKQuery) async throws -> QueryResponse{
        return try await privDb.records(matching: query)
    }

    private func publicDbQuery(_ query: CKQuery) async throws -> QueryResponse {
        return try await pubDb.records(matching: query)
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

    private func records(for query: CKQuery, to db: LhDatabase) async throws -> QueryResponse {
        switch db {
        case .pubDb: return try await publicDbQuery(query)
        case .privDb: return try await privateDbQuery(query)
        }
    }
}
