//
//  FollowingDTOManageable.swift
//
//
//  Created by Nicolas Le Gorrec on 8/1/24.
//

import CloudKit

protocol FollowingDTOManageable {
    func getUserFollowing(for recordName: String) async throws -> ([FollowingDTO], CKQueryOperation.Cursor?)
    func continueUserFollowing(cursor: CKQueryOperation.Cursor) async throws -> ([FollowingDTO], CKQueryOperation.Cursor?)
    func getUserFollowers(for recordName: String) async throws -> ([FollowingDTO], CKQueryOperation.Cursor?)
    func continueUserFollowers(cursor: CKQueryOperation.Cursor) async throws -> ([FollowingDTO], CKQueryOperation.Cursor?)
    func followUser(recordName: String) async throws
    func unfollowUser(recordName: String) async throws
}
