//
//  File.swift
//  
//
//  Created by Nicolas Le Gorrec on 2/4/24.
//

import Foundation
import CloudKit

public protocol CloudKitable {
    func save(record: CKRecord, db: LhDatabase) async throws -> CKRecord
    func record(for recordId: CKRecord.ID, db: LhDatabase) async throws -> CKRecord
    func records(for query: Query, resultsLimit: Int?, db: LhDatabase) async throws -> (matchResults: [(CKRecord.ID, Result<CKRecord, Error>)], queryCursor: CKQueryOperation.Cursor?)
    func records(startingAt: CKQueryOperation.Cursor, resultsLimit: Int?, db: LhDatabase) async throws -> (matchResults: [(CKRecord.ID, Result<CKRecord, Error>)], queryCursor: CKQueryOperation.Cursor?)
    func selfRecordId() async throws -> CKRecord.ID
}

struct CloudKitQuery {
    let recordType: String
    let sortDescriptorKey: String?
    let predicate: NSPredicate?
    let database: LhDatabase
}
