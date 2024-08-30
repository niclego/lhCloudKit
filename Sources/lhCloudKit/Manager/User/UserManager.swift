//
//  UserManager.swift
//  lastheard
//
//  Created by Nicolas Le Gorrec on 2/4/24.
//

import CloudKit

public struct UserManager: UserManageable {

    public enum UserManagerError: Error {
        case selfUserNoRecordIdFound
        case noUserForUsernameFound
        case noRecordIdFoundForUser
        case multipleUsersWithUsername
        case maxUsersFollowed
    }

    private let ck: CloudKitable

    public init(ck: CloudKitable) {
        self.ck = ck
    }

    private func randomString(length: Int) -> String {
      let letters = "0123456789abcdefgABCDEFG"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }

    private func createLhUser() async throws -> (LhUser, CKRecord) {
        let (systemUser, systemUserRecord) = try await getSystemUser()
        guard systemUser.lhUserRecordName == nil else { throw CloudKitError.lhUserAlreadyExistsForSystemUser }
        let user = LhUser(username: "user-\(Date.now.timeIntervalSince1970.description)-\(randomString(length: 8))", followingLhUserRecordNames: [], image: nil)
        let lhUserRecord = try await ck.save(record: user.record, db: .pubDb)
        systemUserRecord[User.UserRecordKeys.lhUserRecordName.rawValue] = lhUserRecord.recordID.recordName
        let _ = try await ck.save(record: systemUserRecord, db: .pubDb)
        guard let lhUser = LhUser(record: lhUserRecord) else { throw CloudKitError.badRecordData }
        return (lhUser, lhUserRecord)
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

    public func searchLhUsersByUsername(_ username: String) async throws -> [LhUser] {
        let result = try await ck.records(for: .user(.searchByUsername(username)), resultsLimit: 10, db: .pubDb)
        let users = result.matchResults.compactMap { try? $0.1.get() }.compactMap { LhUser(record: $0) }
        return users
    }

    public func getLhUserByUsername(_ username: String) async throws -> LhUser? {
        let result = try await ck.records(for: .user(.getByUsername(username)), resultsLimit: nil, db: .pubDb)
        guard let record = try? result.matchResults.first?.1.get() else { return nil }
        return LhUser(record: record)
    }

    public func updateSelfLhUser(with user: LhUser) async throws -> LhUser {
        let (_, lhUserRecord) = try await getSelfLhUser()
        lhUserRecord[LhUser.LhUserRecordKeys.username.rawValue] = user.username
        lhUserRecord[LhUser.LhUserRecordKeys.followingLhUserRecordNames.rawValue] = user.followingLhUserRecordNames
        lhUserRecord[LhUser.LhUserRecordKeys.image.rawValue] = user.image
        let updatedUserRecord = try await ck.save(record: lhUserRecord, db: .pubDb)
        guard let newUser = LhUser(record: updatedUserRecord) else { throw CloudKitError.badRecordData }
        return newUser
    }

    public func addToSelfFollowing(_ followingRecordNames: [String]) async throws -> LhUser {
        let (selfLhUser, _) = try await getSelfLhUser()
        let currentFollowing = selfLhUser.followingLhUserRecordNames

        guard currentFollowing.count < 200 else { throw UserManagerError.maxUsersFollowed }

        let newFollowing = Set(currentFollowing + followingRecordNames)
        let newUser = LhUser(
            username: selfLhUser.username,
            followingLhUserRecordNames: Array(newFollowing),
            image: selfLhUser.image
        )
        return try await updateSelfLhUser(with: newUser)
    }

    public func changeUsername(to username: String) async throws -> LhUser {
        let (selfLhUser, _) = try await getSelfLhUser()
        let newUser = LhUser(
            username: username,
            followingLhUserRecordNames: selfLhUser.followingLhUserRecordNames,
            image: selfLhUser.image
        )

        return try await updateSelfLhUser(with: newUser)
    }

    public func changeImage(to url: URL) async throws -> LhUser {
        let (selfLhUser, _) = try await getSelfLhUser()
        let asset = CKAsset(fileURL: url)
        let newUser = LhUser(
            username: selfLhUser.username,
            followingLhUserRecordNames: selfLhUser.followingLhUserRecordNames,
            image: asset
        )

        return try await updateSelfLhUser(with: newUser)
    }

    public func isTaken(username: String) async throws -> Bool {
        let user = try await getLhUserByUsername(username)
        return user != nil
    }

    public func removeFromSelfFollowing(_ recordNames: [String]) async throws -> LhUser {
        let (selfLhUser, _) = try await getSelfLhUser()
        let currentFollowing = Set(selfLhUser.followingLhUserRecordNames)
        let newFollowing = currentFollowing.subtracting(Set(recordNames))
        let newUser = LhUser(
            username: selfLhUser.username,
            followingLhUserRecordNames: Array(newFollowing),
            image: selfLhUser.image
        )
        return try await updateSelfLhUser(with: newUser)
    }

    public func getFollowers(for recordName: String) async throws -> ([LhUser], CKQueryOperation.Cursor?) {
        let result = try await ck.records(for: .user(.getFollowers(recordName)), resultsLimit: 10, db: .pubDb)
        let followers = result.matchResults.compactMap { try? $0.1.get() }.compactMap { LhUser(record: $0) }
        return (followers, result.queryCursor)
    }

    public func continueUserFollowers(cursor: CKQueryOperation.Cursor) async throws -> ([LhUser], CKQueryOperation.Cursor?) {
        let result = try await ck.records(startingAt: cursor, resultsLimit: 10, db: .pubDb)
        let followers = result.matchResults.compactMap { try? $0.1.get() }.compactMap { LhUser(record: $0) }
        return (followers, result.queryCursor)
    }
}
