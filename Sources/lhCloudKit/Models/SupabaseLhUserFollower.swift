//
//  SupabaseLhUserFollower.swift
//  lhCloudKit
//
//  Created by Codex on 2025-08-05.
//

import CloudKit

struct SupabaseLhUserFollower: Decodable {
    let id: UUID
    let follower: UUID
    let followee: UUID
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case follower
        case followee
        case createdAt = "created_at"
    }
}
