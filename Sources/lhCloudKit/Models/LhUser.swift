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
    public let accountType: AccountType?
    public let isPublicAccount: Bool?

    public enum AccountType: String {
        case verifiedUser
        case verifiedArtist
    }

    public init(
        recordId: CKRecord.ID? = nil,
        username: String,
        followingLhUserRecordNames: [String],
        image: CKAsset?,
        accountType: AccountType?,
        isPublicAccount: Bool?
    ) {
        self.recordId = recordId
        self.username = username
        self.followingLhUserRecordNames = followingLhUserRecordNames
        self.image = image
        self.accountType = accountType
        self.isPublicAccount = isPublicAccount
    }
}

extension LhUser: Sendable {}

extension LhUser: CloudKitRecordable {
    public init?(record: CKRecord) {
        guard let username = record[LhUserRecordKeys.username.rawValue] as? String else { return nil }
        let followingLhUserRecordNames = record[LhUserRecordKeys.followingLhUserRecordNames.rawValue] as? [String] ?? []
        let image = record[LhUserRecordKeys.image.rawValue] as? CKAsset
        let accountTypeRaw = record[LhUserRecordKeys.accountType.rawValue] as? String
        let accountType = accountTypeRaw.flatMap { AccountType(rawValue: $0) }
        let isPublicAccount = record[LhUserRecordKeys.isPublicAccount.rawValue] as? Bool
        self.init(
            recordId: record.recordID,
            username: username,
            followingLhUserRecordNames: followingLhUserRecordNames,
            image: image,
            accountType: accountType,
            isPublicAccount: isPublicAccount
        )
    }

    public var record: CKRecord {
        let record = CKRecord(recordType: LhUserRecordKeys.type.rawValue)
        record[LhUserRecordKeys.username.rawValue] = username
        record[LhUserRecordKeys.followingLhUserRecordNames.rawValue] = followingLhUserRecordNames
        record[LhUserRecordKeys.image.rawValue] = image
        record[LhUserRecordKeys.accountType.rawValue] = accountType?.rawValue
        record[LhUserRecordKeys.isPublicAccount.rawValue] = isPublicAccount
        return record
    }
}

extension LhUser {
    public static let mock: LhUser = .init(
        recordId: .init(recordName: "test"),
        username: "testUsername",
        followingLhUserRecordNames: [],
        image: nil,
        accountType: nil,
        isPublicAccount: nil
    )
}

public extension LhUser {
    enum LhUserRecordKeys: String {
        case type = "LhUser"
        case username
        case followingLhUserRecordNames
        case image
        case accountType
        case isPublicAccount
    }
}

extension LhUser: Identifiable {
    public var id: String { username }
}

extension LhUser: Hashable {}

