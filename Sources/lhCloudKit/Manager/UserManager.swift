//
//  HomeViewModel.swift
//  lastheard
//
//  Created by Nicolas Le Gorrec on 2/4/24.
//

import CloudKit

public struct UserManager {

    enum UserManagerError: Error {
        case selfUserNoRecordIdFound
        case noUserForUsernameFound
        case noRecordIdFoundForUser
        case multipleUsersWithUsername
    }

    private let ck: CloudKitable

    public init(ck: CloudKitable = LhCloudKitMock()) {
        self.ck = ck
    }

    public func createLhUser() async throws -> LhUser {
        let (systemUser, systemUserRecord) = try await getSystemUser()
        guard systemUser.lhUserRecordName == nil else { throw CloudKitError.lhUserAlreadyExistsForSystemUser }
        let user = LhUser(username: nil, followingLhUserRecordNames: [])
        let lhUser = try await ck.save(record: user.record, db: .pubDb)
        systemUserRecord[User.UserRecordKeys.lhUserRecordName.rawValue] = lhUser.recordID.recordName
        let record = try await ck.save(record: systemUserRecord, db: .pubDb)
        guard let lhUser = LhUser(record: record) else { throw CloudKitError.badRecordData }
        return lhUser
    }

    private func getSystemUser() async throws -> (User, CKRecord) {
        let recordId = try await ck.selfRecordId()
        let systemUserRecord = try await ck.record(for: recordId, db: .pubDb)
        guard let systemUser = User(record: systemUserRecord)
        else { throw CloudKitError.badRecordData }
        return (systemUser, systemUserRecord)
    }

    public func getSelfLhUser() async throws -> (LhUser, CKRecord) {
        let (sysUser, _) = try await getSystemUser()
        guard let recordName = sysUser.lhUserRecordName else { throw CloudKitError.lhUserDoesNotExistForSystemUser }
        let (lHUser, lhUserRecord) = try await getLhUserByRecordName(recordName)
        return (lHUser, lhUserRecord)
    }

    public func getLhUserByRecordName(_ lhUserRecordName: String) async throws -> (LhUser, CKRecord) {
        let lhUserRecordId = CKRecord.ID(recordName: lhUserRecordName)
        let lhUserRecord = try await ck.record(for: lhUserRecordId, db: .pubDb)
        guard let lhUser = LhUser(record: lhUserRecord) else { throw CloudKitError.badRecordData }
        return (lhUser, lhUserRecord)
    }

    private func getLhUsersByRecordNames(_ lhUserRecordNames: [String]) async throws -> [LhUser] {
        return try await withThrowingTaskGroup(of: LhUser.self, returning: [LhUser].self) { taskGroup in
            for recordName in lhUserRecordNames {
                taskGroup.addTask { try await getLhUserByRecordName(recordName).0 }
            }

            return try await taskGroup.reduce(into: [LhUser]()) { partialResult, name in
                partialResult.append(name)
            }
        }
    }

    public func getSelfFollowers() async throws -> [LhUser] {
        let selfUser = try await getSelfLhUser().0
        guard let selfUserRecordName = selfUser.recordId?.recordName else { throw UserManagerError.selfUserNoRecordIdFound }
        return try await ck.query(.user(.getFollowers(selfUserRecordName)))
    }

    public func getFollowers(for username: String) async throws -> [LhUser] {
        let user = try await getLhUserByUsername(username)
        guard let userRecordName = user.recordId?.recordName else { throw UserManagerError.noRecordIdFoundForUser }
        return try await ck.query(.user(.getFollowers(userRecordName)))
    }

    public func getLhUserByUsername(_ username: String) async throws -> LhUser {
        let users: [LhUser] = try await ck.query(.user(.getByUsername(username)))
        guard users.count == 1 else { throw UserManagerError.multipleUsersWithUsername }
        guard let user = users.first else { throw UserManagerError.noUserForUsernameFound }
        return user
    }

    public func searchLhUsersByUsername(_ username: String) async throws -> [LhUser] {
        return try await ck.query(.user(.searchByUsername(username)))
    }

    public func getAllLhUsers() async throws -> [LhUser] {
        return try await ck.query(.user(.allLhUsers))
    }

    public func updateSelfLhUser(with user: LhUser) async throws -> LhUser {
        let (_, lhUserRecord) = try await getSelfLhUser()
        // TODO: Check if name is taken
        lhUserRecord[LhUser.LhUserRecordKeys.username.rawValue] = user.username
        lhUserRecord[LhUser.LhUserRecordKeys.followingLhUserRecordNames.rawValue] = user.followingLhUserRecordNames
        let updatedUserRecord = try await ck.save(record: lhUserRecord, db: .pubDb)
        guard let newUser = LhUser(record: updatedUserRecord) else { throw CloudKitError.badRecordData }
        return newUser
    }

    public func addToSelfFollowing(_ followingRecordNames: [String]) async throws -> LhUser {
        let (selfLhUser, _) = try await getSelfLhUser()
        let currentFollowing = selfLhUser.followingLhUserRecordNames
        let newFollowing = currentFollowing + followingRecordNames
        let newUser = LhUser(username: selfLhUser.username, followingLhUserRecordNames: newFollowing)
        return try await updateSelfLhUser(with: newUser)
    }

    public func getSelfFollowingUsers() async throws -> [LhUser] {
        let (selfLhUser, _) = try await getSelfLhUser()
        let followingLhUserRecordNames = selfLhUser.followingLhUserRecordNames
        return try await getLhUsersByRecordNames(followingLhUserRecordNames)
    }

    public func getFollowingUsers(for username: String) async throws -> [LhUser] {
        let user = try await getLhUserByUsername(username)
        let followingLhUserRecordNames = user.followingLhUserRecordNames
        return try await getLhUsersByRecordNames(followingLhUserRecordNames)
    }
}
