//
//  FollowingDTO.swift
//  
//
//  Created by Nicolas Le Gorrec on 8/1/24.
//

import CloudKit

public struct FollowingDTO {
    let recordId: CKRecord.ID?
    let lhUserRecordName: String
    let followingLhUserRecordName: String

    public init(recordId: CKRecord.ID? = nil, lhUserRecordName: String, followingLhUserRecordName: String) {
        self.recordId = recordId
        self.lhUserRecordName = lhUserRecordName
        self.followingLhUserRecordName = followingLhUserRecordName
    }
}

extension FollowingDTO: CloudKitRecordable {
    public init?(record: CKRecord) {
        guard
            let lhUserRecordName = record[FollowingDTORecordKeys.lhUserRecordName.rawValue] as? String,
            let followingLhUserRecordName = record[FollowingDTORecordKeys.followingLhUserRecordName.rawValue] as? String
        else { return nil }

        self.init(
            recordId: record.recordID,
            lhUserRecordName: lhUserRecordName,
            followingLhUserRecordName: followingLhUserRecordName
        )
    }

    public var record: CKRecord {
        let record = CKRecord(recordType: FollowingDTORecordKeys.type.rawValue)
        record[FollowingDTORecordKeys.lhUserRecordName.rawValue] = lhUserRecordName
        record[FollowingDTORecordKeys.followingLhUserRecordName.rawValue] = followingLhUserRecordName
        return record
    }
}


extension FollowingDTO: Sendable {}

extension FollowingDTO {
    enum FollowingDTORecordKeys: String {
        case type = "FollowingDTO"
        case lhUserRecordName
        case followingLhUserRecordName
    }
}

extension FollowingDTO {
    public static let mock: FollowingDTO = .init(lhUserRecordName: "test-record-name", followingLhUserRecordName: "test-record-name-follower")
}

