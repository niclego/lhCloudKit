//
//  UserFollowerRequestQuery.swift
//
//  Created by Codex on 2025-08-08.
//

import Foundation

public extension Query {
    enum UserFollowerRequestQuery {
        case isPending(String, String)

        var query: CloudKitQuery {
            switch self {
            case .isPending(let follower, let followee):
                return isPending(follower: follower, followee: followee)
            }
        }

        private func isPending(follower: String, followee: String) -> CloudKitQuery {
            return .init(
                recordType: LhUserFollowerRequest.LhUserFollowerRequestRecordKeys.type.rawValue,
                sortDescriptorKey: LhUserFollowerRequest.LhUserFollowerRequestRecordKeys.created.rawValue,
                predicate: NSPredicate(format: "follower == %@ AND followee == %@", follower, followee),
                database: .pubDb
            )
        }
    }
}
