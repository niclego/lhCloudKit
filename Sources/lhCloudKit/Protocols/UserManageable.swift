//
//  UserManageable.swift
//
//
//  Created by Nicolas Le Gorrec on 7/9/24.
//

import Foundation
import CloudKit

public protocol UserManageable: Sendable {
    func getSelfLhUser() async throws -> LhUser
    func getLhUserByRecordName(_ lhUserRecordName: String) async throws -> LhUser
    func searchLhUsersByUsername(_ username: String) async throws -> [LhUser]
    func getLhUserByUsername(_ username: String) async throws -> LhUser?
    func updateSelfLhUser(with user: LhUser) async throws -> LhUser
    func addToSelfFollowing(_ followingRecordNames: [String]) async throws -> LhUser
    func changeUsername(to username: String) async throws -> LhUser
    func changeImage(to url: URL) async throws -> LhUser
    func changeAccountType(to accountType: LhUser.AccountType) async throws -> LhUser
    func isTaken(username: String) async throws -> Bool
    func removeFromSelfFollowing(_ recordNames: [String]) async throws -> LhUser
    func getFollowers(for recordName: String) async throws -> ([LhUser], CKQueryOperation.Cursor?)
    func continueUserFollowers(cursor: CKQueryOperation.Cursor) async throws -> ([LhUser], CKQueryOperation.Cursor?)
}
