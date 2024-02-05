//
//  File.swift
//  
//
//  Created by Nicolas Le Gorrec on 2/4/24.
//

import CloudKit

enum LhDatabase {
    case pubDb
    case privDb
}

class LhCloudKit: CloudKitable {
    typealias QueryResponse = (matchResults: [(CKRecord.ID, Result<CKRecord, Error>)], queryCursor: CKQueryOperation.Cursor?)
    private let container: CKContainer
    private let pubDb: CKDatabase
    private let privDb: CKDatabase

    required init(containerId: String) {
        self.container = CKContainer(identifier: containerId)
        self.pubDb = container.publicCloudDatabase
        self.privDb = container.privateCloudDatabase
    }

    func query<T: CloudKitRecordable>(_ query: LhQuery) async throws -> [T] {
        let query = query.query
        let ckQuery = CKQuery(recordType: query.recordType, predicate: query.predicate ?? NSPredicate(value: true))
        ckQuery.sortDescriptors = [NSSortDescriptor(key: query.sortDescriptorKey, ascending: true)]
        let result = try await records(for: ckQuery, to: query.database)
        let records = result.matchResults.compactMap { try? $0.1.get() }
        let models = records.compactMap { try? T(record: $0) }
        return models
    }

    func save<T: CloudKitRecordable>(model: T, db: LhDatabase) async throws -> T {
        let record = try await pubDb.save(model.record)
        return try T(record: record)
    }

    func fetchUserRecordIdString() async throws -> String {
        return try await container.userRecordID().debugDescription
    }

    private func privateDbQuery(_ query: CKQuery) async throws -> QueryResponse{
        return try await privDb.records(matching: query)
    }

    private func publicDbQuery(_ query: CKQuery) async throws -> QueryResponse {
        return try await pubDb.records(matching: query)
    }

    private func records(for query: CKQuery, to db: LhDatabase) async throws -> QueryResponse {
        switch db {
        case .pubDb: return try await publicDbQuery(query)
        case .privDb: return try await privateDbQuery(query)
        }
    }
}
