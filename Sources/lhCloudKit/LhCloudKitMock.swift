//
//  File.swift
//  
//
//  Created by Nicolas Le Gorrec on 2/4/24.
//

import Foundation
import CloudKit

public struct LhCloudKitMock: CloudKitable {
    let containerId: String

    public init() {
        self.containerId = "MOCK_CONTAINER_ID"
    }

    public func query<T: CloudKitRecordable>(_ query: Query) async throws -> [T] { [T.mock] }
    public func save(record: CKRecord, db: LhDatabase) async throws -> CKRecord { .init(recordType: "nil")  }
    public func record(for recordId: CKRecord.ID, db: LhDatabase) async throws -> CKRecord { .init(recordType: "nil") }
    public func selfRecordId() async throws -> CKRecord.ID { return .init(recordName: "Test") }
}
