//
//  File.swift
//  
//
//  Created by Nicolas Le Gorrec on 2/4/24.
//

import Foundation
import CloudKit

public protocol CloudKitable {
    func query<T: CloudKitRecordable>(_ query: Query) async throws -> [T]
    func save(record: CKRecord, db: LhDatabase) async throws -> CKRecord
    func record(for recordId: CKRecord.ID, db: LhDatabase) async throws -> CKRecord
    func selfRecordId() async throws -> CKRecord.ID
}

struct CloudKitQuery {
    let recordType: String
    let sortDescriptorKey: String?
    let predicate: NSPredicate?
    let database: LhDatabase
}
