//
//  File.swift
//  
//
//  Created by Nicolas Le Gorrec on 2/4/24.
//

import Foundation
import CloudKit

public struct LhCloudKitMock: CloudKitable {
    public init() {}

    public func records(
        startingAt: CKQueryOperation.Cursor,
        resultsLimit: Int?,
        db: LhDatabase
    ) async throws -> (matchResults: [(CKRecord.ID, Result<CKRecord, Error>)], queryCursor: CKQueryOperation.Cursor?) {
        ([], nil)
    }
    public func records(for query: Query, resultsLimit: Int?, db: LhDatabase) async throws -> (matchResults: [(CKRecord.ID, Result<CKRecord, Error>)], queryCursor: CKQueryOperation.Cursor?) { ([], nil) }
    public func save(record: CKRecord, db: LhDatabase) async throws -> CKRecord { .init(recordType: "nil")  }
    public func deleteRecord(withID recordID: CKRecord.ID, db: LhDatabase) async throws -> CKRecord.ID { .init(recordName: "test") }
    public func record(for recordId: CKRecord.ID, db: LhDatabase) async throws -> CKRecord { .init(recordType: "nil") }
    public func selfRecordId() async throws -> CKRecord.ID { return .init(recordName: "Test") }
}
