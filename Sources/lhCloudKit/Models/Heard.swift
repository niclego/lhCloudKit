//
//  File.swift
//  
//
//  Created by Nicolas Le Gorrec on 2/4/24.
//

import CloudKit

struct Heard {
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
    init(record: CKRecord) throws {
        let authorId = record[HeardRecordKeys.authorId.rawValue] as! String
        self.init(recordId: record.recordID, authorId: authorId)
    }

    var record: CKRecord {
        let record = CKRecord(recordType: HeardRecordKeys.type.rawValue)
        record[HeardRecordKeys.authorId.rawValue] = authorId
        return record
    }

    static var mock: Heard = .init(authorId: "testId")
}

extension Heard {
    enum HeardRecordKeys: String {
        case type = "Heard"
        case authorId
    }
}
