//
//  LhUserFollowerRequest.swift
//
//  Created by Codex on 2024-08-05.
//

import CloudKit

public struct LhUserFollowerRequest {
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

extension LhUserFollowerRequest: Sendable {}

extension LhUserFollowerRequest: CloudKitRecordable {
    public init?(record: CKRecord) {
        guard
            let follower = record[LhUserFollowerRequestRecordKeys.follower.rawValue] as? String,
            let followee = record[LhUserFollowerRequestRecordKeys.followee.rawValue] as? String,
            let created = record[LhUserFollowerRequestRecordKeys.created.rawValue] as? Int
        else { return nil }

        self.init(recordId: record.recordID, follower: follower, followee: followee, created: created)
    }

    public var record: CKRecord {
        let record = CKRecord(recordType: LhUserFollowerRequestRecordKeys.type.rawValue)
        record[LhUserFollowerRequestRecordKeys.follower.rawValue] = follower
        record[LhUserFollowerRequestRecordKeys.followee.rawValue] = followee
        record[LhUserFollowerRequestRecordKeys.created.rawValue] = created
        return record
    }
}

extension LhUserFollowerRequest {
    public static let mock: LhUserFollowerRequest = .init(follower: "follower", followee: "followee", created: 0)
}

public extension LhUserFollowerRequest {
    enum LhUserFollowerRequestRecordKeys: String {
        case type = "LhUserFollowerRequest"
        case follower
        case followee
        case created
    }
}

extension LhUserFollowerRequest: Identifiable {
    public var id: String { follower + followee + String(created) }
}

extension LhUserFollowerRequest: Equatable {
    public static func == (
        lhs: LhUserFollowerRequest,
        rhs: LhUserFollowerRequest
    ) -> Bool {
        lhs.id == rhs.id
    }
}
