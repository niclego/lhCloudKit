//
//  User.swift
//  
//
//  Created by Nicolas Le Gorrec on 2/4/24.
//

import CloudKit

public struct User {
    let recordId: CKRecord.ID?
    public let lhUserRecordName: String?

    public init(
        recordId: CKRecord.ID? = nil,
        lhUserRecordName: String?
    ) {
        self.recordId = recordId
        self.lhUserRecordName = lhUserRecordName
    }
}

extension User: CloudKitRecordable {
    public init?(record: CKRecord) {
        let lhUserRecordName = record[UserRecordKeys.lhUserRecordName.rawValue] as? String
        self.init(recordId: record.recordID, lhUserRecordName: lhUserRecordName)
    }

    public var record: CKRecord {
        let record = CKRecord(recordType: UserRecordKeys.type.rawValue)
        record[UserRecordKeys.lhUserRecordName.rawValue] = lhUserRecordName
        return record
    }

    public static var mock: User = .init(lhUserRecordName: "lhUserRecordName_mock")
}

public extension User {
    enum UserRecordKeys: String {
        case type = "Users"
        case lhUserRecordName
    }
}

