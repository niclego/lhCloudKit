//
//  UserFollowerQuery.swift
//
//  Created by Codex on 2024-08-05.
//

import Foundation

public extension Query {
    enum UserFollowerQuery {
        case isFollowing(String, String)
        case getFollowersForFollowee(String)

        var query: CloudKitQuery {
            switch self {
            case .isFollowing(let follower, let followee):
                return isFollowing(follower: follower, followee: followee)
            case .getFollowersForFollowee(let followee):
                return getFollowers(for: followee)
            }
        }

        private func isFollowing(follower: String, followee: String) -> CloudKitQuery {
            return .init(
                recordType: LhUserFollower.LhUserFollowerRecordKeys.type.rawValue,
                sortDescriptorKey: LhUserFollower.LhUserFollowerRecordKeys.created.rawValue,
                predicate: NSPredicate(format: "follower == %@ AND followee == %@", follower, followee),
                database: .pubDb
            )
        }

        private func getFollowers(for followee: String) -> CloudKitQuery {
            return .init(
                recordType: LhUserFollower.LhUserFollowerRecordKeys.type.rawValue,
                sortDescriptorKey: LhUserFollower.LhUserFollowerRecordKeys.created.rawValue,
                predicate: NSPredicate(format: "followee == %@", followee),
                database: .pubDb
            )
        }
    }
}
