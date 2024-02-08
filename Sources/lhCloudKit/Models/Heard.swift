//
//  File.swift
//  
//
//  Created by Nicolas Le Gorrec on 2/4/24.
//

import CloudKit

public struct Heard {
    let recordId: CKRecord.ID?
    let authorId: String

    init(
        recordId: CKRecord.ID? = nil,
        authorId: String
    ) {
        self.recordId = recordId
        self.authorId = authorId
    }
}

extension Heard: CloudKitRecordable {
    public init?(record: CKRecord) {
        guard let authorId = record[HeardRecordKeys.authorId.rawValue] as? String else { return nil }
        self.init(recordId: record.recordID, authorId: authorId)
    }

    public var record: CKRecord {
        let record = CKRecord(recordType: HeardRecordKeys.type.rawValue)
        record[HeardRecordKeys.authorId.rawValue] = authorId
        return record
    }

    public static var mock: Heard = .init(authorId: "testId")
}

extension Heard {
    enum HeardRecordKeys: String {
        case type = "Heard"
        case authorId
    }
}
