//
//  FollowingDTOManagerMock.swift
//
//
//  Created by Nicolas Le Gorrec on 8/1/24.
//

import CloudKit

public struct FollowingDTOManagerMock: FollowingDTOManageable {

    public init() {}

    func getUserFollowing(for recordName: String) async throws -> ([FollowingDTO], CKQueryOperation.Cursor?) {([.mock], nil)}
    func continueUserFollowing(cursor: CKQueryOperation.Cursor) async throws -> ([FollowingDTO], CKQueryOperation.Cursor?) {([.mock], nil)}
    func getUserFollowers(for recordName: String) async throws -> ([FollowingDTO], CKQueryOperation.Cursor?) {([.mock], nil)}
    func continueUserFollowers(cursor: CKQueryOperation.Cursor) async throws -> ([FollowingDTO], CKQueryOperation.Cursor?) {([.mock], nil)}
    func followUser(recordName: String) async throws { return }
    func unfollowUser(recordName: String) async throws { return }
}
