//
//  File.swift
//
//
//  Created by Nicolas Le Gorrec on 2/4/24.
//

import CloudKit

public struct LhUser {
    public let recordId: CKRecord.ID?
    public let username: String
    public let followingLhUserRecordNames: [String]

    public init(
        recordId: CKRecord.ID? = nil,
        username: String,
        followingLhUserRecordNames: [String]
    ) {
        self.recordId = recordId
        self.username = username
        self.followingLhUserRecordNames = followingLhUserRecordNames
    }
}

extension LhUser: CloudKitRecordable {
    public init?(record: CKRecord) {
        guard let username = record[LhUserRecordKeys.username.rawValue] as? String else { return nil }
        let followingLhUserRecordNames = record[LhUserRecordKeys.followingLhUserRecordNames.rawValue] as? [String] ?? []
        self.init(recordId: record.recordID, username: username, followingLhUserRecordNames: followingLhUserRecordNames)
    }

    public var record: CKRecord {
        let record = CKRecord(recordType: LhUserRecordKeys.type.rawValue)
        record[LhUserRecordKeys.username.rawValue] = username
        record[LhUserRecordKeys.followingLhUserRecordNames.rawValue] = followingLhUserRecordNames
        return record
    }

    public static var mock: LhUser = .init(username: "test", followingLhUserRecordNames: ["C701AE9D-4E83-45D5-A40C-F5B2F3DA83D3", "F443A922-3836-486B-A61A-517032996E4E"])
}

public extension LhUser {
    enum LhUserRecordKeys: String {
        case type = "LhUser"
        case username
        case followingLhUserRecordNames
    }
}

