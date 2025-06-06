//
//  LhUser.swift
//
//
//  Created by Nicolas Le Gorrec on 2/4/24.
//

import CloudKit

public struct LhUser {
    public let recordId: CKRecord.ID?
    public let username: String
    public let followingLhUserRecordNames: [String]
    public let image: CKAsset?
    public let isVerified: Bool

    public init(
        recordId: CKRecord.ID? = nil,
        username: String,
        followingLhUserRecordNames: [String],
        image: CKAsset?,
        isVerified: Bool
    ) {
        self.recordId = recordId
        self.username = username
        self.followingLhUserRecordNames = followingLhUserRecordNames
        self.image = image
        self.isVerified = isVerified
    }
}

extension LhUser: Sendable {}

extension LhUser: CloudKitRecordable {
    public init?(record: CKRecord) {
        guard let username = record[LhUserRecordKeys.username.rawValue] as? String else { return nil }
        let followingLhUserRecordNames = record[LhUserRecordKeys.followingLhUserRecordNames.rawValue] as? [String] ?? []
        let image = record[LhUserRecordKeys.image.rawValue] as? CKAsset
        let isVerified = record[LhUserRecordKeys.isVerified.rawValue] as? Bool ?? false
        self.init(recordId: record.recordID, username: username, followingLhUserRecordNames: followingLhUserRecordNames, image: image, isVerified: isVerified)
    }

    public var record: CKRecord {
        let record = CKRecord(recordType: LhUserRecordKeys.type.rawValue)
        record[LhUserRecordKeys.username.rawValue] = username
        record[LhUserRecordKeys.followingLhUserRecordNames.rawValue] = followingLhUserRecordNames
        record[LhUserRecordKeys.image.rawValue] = image
        record[LhUserRecordKeys.isVerified.rawValue] = isVerified
        return record
    }
}

extension LhUser {
    public static let mock: LhUser = .init(
        recordId: .init(recordName: "test"),
        username: "testUsername",
        followingLhUserRecordNames: [],
        image: nil,
        isVerified: false
    )
}

public extension LhUser {
    enum LhUserRecordKeys: String {
        case type = "LhUser"
        case username
        case followingLhUserRecordNames
        case image
        case isVerified
    }
}

extension LhUser: Hashable {}

