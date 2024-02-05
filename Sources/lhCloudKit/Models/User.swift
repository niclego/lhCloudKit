//
//  File.swift
//  
//
//  Created by Nicolas Le Gorrec on 2/4/24.
//

import CloudKit

struct User {
    let recordId: CKRecord.ID?
    let username: String

    init(
        recordId: CKRecord.ID? = nil,
        username: String
    ) {
        self.recordId = recordId
        self.username = username
    }
}

extension User: CloudKitRecordable {
    init(record: CKRecord) throws {
        let username = record[UserRecordKeys.username.rawValue] as! String
        self.init(recordId: record.recordID, username: username)
    }
    
    var record: CKRecord {
        let record = CKRecord(recordType: UserRecordKeys.type.rawValue)
        return record
    }
    
    static var mock: User = .init(username: "test_user")
}

extension User {
    enum UserRecordKeys: String {
        case type = "User"
        case username
        case userRecordId
    }
}

