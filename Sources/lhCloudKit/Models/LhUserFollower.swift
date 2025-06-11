//
//  LhUserFollower.swift
//
//  Created by Codex on 2024-08-05.
//

import CloudKit

public struct LhUserFollower {
    public let recordId: CKRecord.ID?
    public let follower: String
    public let followee: String
    public let created: Int

    public init(
        recordId: CKRecord.ID? = nil,
        follower: String,
        followee: String,
        created: Int
    ) {
        self.recordId = recordId
        self.follower = follower
        self.followee = followee
        self.created = created
    }
}

extension LhUserFollower: Sendable {}

extension LhUserFollower: CloudKitRecordable {
    public init?(record: CKRecord) {
        guard
            let follower = record[LhUserFollowerRecordKeys.follower.rawValue] as? String,
            let followee = record[LhUserFollowerRecordKeys.followee.rawValue] as? String,
            let created = record[LhUserFollowerRecordKeys.created.rawValue] as? Int
        else { return nil }

        self.init(recordId: record.recordID, follower: follower, followee: followee, created: created)
    }

    public var record: CKRecord {
        let record = CKRecord(recordType: LhUserFollowerRecordKeys.type.rawValue)
        record[LhUserFollowerRecordKeys.follower.rawValue] = follower
        record[LhUserFollowerRecordKeys.followee.rawValue] = followee
        record[LhUserFollowerRecordKeys.created.rawValue] = created
        return record
    }
}

extension LhUserFollower {
    public static let mock: LhUserFollower = .init(follower: "follower", followee: "followee", created: 0)
}

public extension LhUserFollower {
    enum LhUserFollowerRecordKeys: String {
        case type = "LhUserFollower"
        case follower
        case followee
        case created
    }
}

extension LhUserFollower: Identifiable {
    public var id: String { follower + followee + String(created) }
}
