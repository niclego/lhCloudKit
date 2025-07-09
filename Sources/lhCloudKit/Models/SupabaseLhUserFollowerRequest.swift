//
//  SupabaseLhUserFollowerRequest.swift
//  lhCloudKit
//
//  Created by Codex on 2025-08-05.
//

import CloudKit

struct SupabaseLhUserFollowerRequest: Decodable {
    let id: String
    let follower: String
    let followee: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case follower
        case followee
        case createdAt = "created_at"
    }
}

extension SupabaseLhUserFollowerRequest {
    var model: LhUserFollowerRequest {
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: createdAt) ?? .now
        return LhUserFollowerRequest(
            follower: follower,
            followee: followee,
            created: Int(date.timeIntervalSince1970)
        )
    }
}
