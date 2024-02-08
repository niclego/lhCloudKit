//
//  File.swift
//
//
//  Created by Nicolas Le Gorrec on 2/4/24.
//

import CloudKit

public struct LhUser {
    public let recordId: CKRecord.ID?
//    let userRecordName: String
    public let username: String?

    public init(
        recordId: CKRecord.ID? = nil,
//        userRecordName: String,
        username: String?
    ) {
        self.recordId = recordId
//        self.userRecordName = userRecordName
        self.username = username
    }
}

extension LhUser: CloudKitRecordable {
    public init?(record: CKRecord) {
//        let userRecordName = record[LhUserRecordKeys.userRecordName.rawValue] as! String
        guard let username = record[LhUserRecordKeys.username.rawValue] as? String else { return nil }
        self.init(recordId: record.recordID, username: username)
    }

    public var record: CKRecord {
        let record = CKRecord(recordType: LhUserRecordKeys.type.rawValue)
//        record[LhUserRecordKeys.userRecordName.rawValue] = userRecordName
        return record
    }

    public static var mock: LhUser = .init(username: "test")
}

public extension LhUser {
    enum LhUserRecordKeys: String {
        case type = "LhUser"
//        case userRecordName
        case username
    }
}

