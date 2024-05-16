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

    private func randomString(length: Int) -> String {
      let letters = "0123456789abcdefgABCDEFG"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }

    private func createLhUser() async throws -> (LhUser, CKRecord) {
        let (systemUser, systemUserRecord) = try await getSystemUser()
        guard systemUser.lhUserRecordName == nil else { throw CloudKitError.lhUserAlreadyExistsForSystemUser }
        let user = LhUser(username: "user-\(randomString(length: 8))", followingLhUserRecordNames: [])
        let lhUserRecord = try await ck.save(record: user.record, db: .pubDb)
        systemUserRecord[User.UserRecordKeys.lhUserRecordName.rawValue] = lhUserRecord.recordID.recordName
        let _ = try await ck.save(record: systemUserRecord, db: .pubDb)
        guard let lhUser = LhUser(record: lhUserRecord) else { throw CloudKitError.badRecordData }
        return (lhUser, lhUserRecord)
    }

    public func createLhUser() async throws -> LhUser {
        return try await createLhUser().0
    }

    private func getSystemUser() async throws -> (User, CKRecord) {
        let recordId = try await ck.selfRecordId()
        let systemUserRecord = try await ck.record(for: recordId, db: .pubDb)
        guard let systemUser = User(record: systemUserRecord)
        else { throw CloudKitError.badRecordData }
        return (systemUser, systemUserRecord)
    }

    private func getSelfLhUser() async throws -> (LhUser, CKRecord) {
        let (sysUser, _) = try await getSystemUser()

        guard let recordName = sysUser.lhUserRecordName else {
            return try await createLhUser()
        }

        let (lHUser, lhUserRecord) = try await getLhUserByRecordName(recordName)
        return (lHUser, lhUserRecord)
    }

    public func getSelfLhUser() async throws -> LhUser {
        return try await getSelfLhUser().0
    }

    private func getLhUserByRecordName(_ lhUserRecordName: String) async throws -> (LhUser, CKRecord) {
        let lhUserRecordId = CKRecord.ID(recordName: lhUserRecordName)
        let lhUserRecord = try await ck.record(for: lhUserRecordId, db: .pubDb)
        guard let lhUser = LhUser(record: lhUserRecord) else { throw CloudKitError.badRecordData }
        return (lhUser, lhUserRecord)
    }

    public func getLhUserByRecordName(_ lhUserRecordName: String) async throws -> LhUser {
        return try await getLhUserByRecordName(lhUserRecordName).0
    }

    private func getLhUsersByRecordNames(_ lhUserRecordNames: [String]) async throws -> [LhUser] {
        return try await withThrowingTaskGroup(of: LhUser.self, returning: [LhUser].self) { taskGroup in
            for recordName in lhUserRecordNames {
                if !recordName.isEmpty {
                    taskGroup.addTask { try await getLhUserByRecordName(recordName).0 }
                }
            }

            return try await taskGroup.reduce(into: [LhUser]()) { partialResult, name in
                partialResult.append(name)
            }
        }
    }

    public func getSelfFollowers() async throws -> [LhUser] {
        let selfUser = try await getSelfLhUser().0
        guard let selfUserRecordName = selfUser.recordId?.recordName else { throw UserManagerError.selfUserNoRecordIdFound }
        let result = try await ck.records(for: .user(.getFollowers(selfUserRecordName)), resultsLimit: nil, db: .pubDb)
        let followers = result.matchResults.compactMap { try? $0.1.get() }.compactMap { LhUser(record: $0) }
        return followers
    }

    public func getFollowers(for username: String) async throws -> [LhUser] {
        let user = try await getLhUserByUsername(username)
        guard let userRecordName = user.recordId?.recordName else { throw UserManagerError.noRecordIdFoundForUser }
        let result = try await ck.records(for: .user(.getFollowers(userRecordName)), resultsLimit: nil, db: .pubDb)
        let followers = result.matchResults.compactMap { try? $0.1.get() }.compactMap { LhUser(record: $0) }
        return followers
    }

    public func getLhUserByUsername(_ username: String) async throws -> LhUser {
        let result = try await ck.records(for: .user(.getByUsername(username)), resultsLimit: nil, db: .pubDb)
        let users = result.matchResults.compactMap { try? $0.1.get() }.compactMap { LhUser(record: $0) }
        guard users.count == 1 else { throw UserManagerError.multipleUsersWithUsername }
        guard let user = users.first else { throw UserManagerError.noUserForUsernameFound }
        return user
    }

    public func searchLhUsersByUsername(_ username: String) async throws -> [LhUser] {
        let result = try await ck.records(for: .user(.searchByUsername(username)), resultsLimit: nil, db: .pubDb)
        let users = result.matchResults.compactMap { try? $0.1.get() }.compactMap { LhUser(record: $0) }
        return users
    }

    public func getAllLhUsers() async throws -> [LhUser] {
        let result =  try await ck.records(for: .user(.allLhUsers), resultsLimit: nil, db: .pubDb)
        let users = result.matchResults.compactMap { try? $0.1.get() }.compactMap { LhUser(record: $0) }
        return users
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

    public func changeUsername(to username: String) async throws -> LhUser {
        let (selfLhUser, _) = try await getSelfLhUser()
        let newUser = LhUser(
            username: username,
            followingLhUserRecordNames: selfLhUser.followingLhUserRecordNames
        )

        return try await updateSelfLhUser(with: newUser)
    }

    public func isTaken(username: String) async throws -> Bool {
        let users = try await searchLhUsersByUsername(username)
        return !users.isEmpty
    }

    public func removeFromSelfFollowing(_ recordNames: [String]) async throws -> LhUser {
        let (selfLhUser, _) = try await getSelfLhUser()
        let currentFollowing = Set(selfLhUser.followingLhUserRecordNames)
        let newFollowing = currentFollowing.subtracting(Set(recordNames))
        let newUser = LhUser(username: selfLhUser.username, followingLhUserRecordNames: Array(newFollowing))
        return try await updateSelfLhUser(with: newUser)
    }

    public func getSelfFollowingUsers() async throws -> [LhUser] {
        let (selfLhUser, _) = try await getSelfLhUser()
        let followingLhUserRecordNames = selfLhUser.followingLhUserRecordNames
        guard !followingLhUserRecordNames.isEmpty else { return [] }
        return try await getLhUsersByRecordNames(followingLhUserRecordNames)
    }

    public func getFollowingUsers(for username: String) async throws -> [LhUser] {
        let user = try await getLhUserByUsername(username)
        let followingLhUserRecordNames = user.followingLhUserRecordNames
        return try await getLhUsersByRecordNames(followingLhUserRecordNames)
    }
}
