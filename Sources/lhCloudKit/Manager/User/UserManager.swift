//
//  UserManager.swift
//  lastheard
//
//  Created by Nicolas Le Gorrec on 2/4/24.
//

import CloudKit
import Supabase

public struct UserManager: UserManageable {

    public enum UserManagerError: Error {
        case selfUserNoRecordIdFound
        case noUserForUsernameFound
        case noRecordIdFoundForUser
        case multipleUsersWithUsername
        case maxUsersFollowed
    }

    private let ck: CloudKitable
    private let supabase: SupabaseClient

    public init(ck: CloudKitable, supabase: SupabaseClient) {
        self.ck = ck
        self.supabase = supabase
    }

    // MARK: - Private

    private func randomString(length: Int) -> String {
      let letters = "0123456789abcdefgABCDEFG"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }

    private func createLhUser() async throws -> (LhUser, CKRecord) {
        let (systemUser, systemUserRecord) = try await getSystemUser()
        guard systemUser.lhUserRecordName == nil else { throw CloudKitError.lhUserAlreadyExistsForSystemUser }
        let user = LhUser(
            username: "user-\(Date.now.timeIntervalSince1970.description)-\(randomString(length: 8))",
            followingLhUserRecordNames: [],
            image: nil,
            accountType: nil,
            isPublicAccount: false
        )
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

    private func getLhUserByRecordName(_ lhUserRecordName: String) async throws -> (LhUser, CKRecord) {
        let lhUserRecordId = CKRecord.ID(recordName: lhUserRecordName)
        let lhUserRecord = try await ck.record(for: lhUserRecordId, db: .pubDb)
        guard let lhUser = LhUser(record: lhUserRecord) else { throw CloudKitError.badRecordData }
        return (lhUser, lhUserRecord)
    }

    // MARK: - Public

    public func getSelfLhUser() async throws -> LhUser {
        return try await getSelfLhUser().0
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
        lhUserRecord[LhUser.LhUserRecordKeys.accountType.rawValue] = user.accountType?.rawValue
        lhUserRecord[LhUser.LhUserRecordKeys.isPublicAccount.rawValue] = user.isPublicAccount
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
            image: selfLhUser.image,
            accountType: selfLhUser.accountType,
            isPublicAccount: selfLhUser.isPublicAccount
        )
        return try await updateSelfLhUser(with: newUser)
    }

    public func changeUsername(to username: String) async throws -> LhUser {
        let (selfLhUser, _) = try await getSelfLhUser()
        let newUser = LhUser(
            username: username,
            followingLhUserRecordNames: selfLhUser.followingLhUserRecordNames,
            image: selfLhUser.image,
            accountType: selfLhUser.accountType,
            isPublicAccount: selfLhUser.isPublicAccount
        )

        return try await updateSelfLhUser(with: newUser)
    }

    public func changeImage(to url: URL) async throws -> LhUser {
        let (selfLhUser, _) = try await getSelfLhUser()
        let asset = CKAsset(fileURL: url)
        let newUser = LhUser(
            username: selfLhUser.username,
            followingLhUserRecordNames: selfLhUser.followingLhUserRecordNames,
            image: asset,
            accountType: selfLhUser.accountType,
            isPublicAccount: selfLhUser.isPublicAccount
        )

        return try await updateSelfLhUser(with: newUser)
    }

    public func changeAccountType(to accountType: LhUser.AccountType) async throws -> LhUser {
        let (selfLhUser, _) = try await getSelfLhUser()
        let newUser = LhUser(
            username: selfLhUser.username,
            followingLhUserRecordNames: selfLhUser.followingLhUserRecordNames,
            image: selfLhUser.image,
            accountType: accountType,
            isPublicAccount: selfLhUser.isPublicAccount
        )

        return try await updateSelfLhUser(with: newUser)
    }

    public func changeAccountVisibility(to isPublicAccount: Bool) async throws -> LhUser {
        let (selfLhUser, _) = try await getSelfLhUser()
        let newUser = LhUser(
            username: selfLhUser.username,
            followingLhUserRecordNames: selfLhUser.followingLhUserRecordNames,
            image: selfLhUser.image,
            accountType: selfLhUser.accountType,
            isPublicAccount: isPublicAccount
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
            image: selfLhUser.image,
            accountType: selfLhUser.accountType,
            isPublicAccount: selfLhUser.isPublicAccount
        )
        return try await updateSelfLhUser(with: newUser)
    }

    public func getFollowers(for recordName: String) async throws -> ([LhUser], CKQueryOperation.Cursor?) {
        let result = try await ck.records(for: .userFollower(.getFollowersForFollowee(recordName)), resultsLimit: 10, db: .pubDb)
        let followerLinks = result.matchResults.compactMap { try? $0.1.get() }.compactMap { LhUserFollower(record: $0) }

        let users = try await withThrowingTaskGroup(of: LhUser.self) { group -> [LhUser] in
            for link in followerLinks {
                group.addTask {
                    try await getLhUserByRecordName(link.follower)
                }
            }

            var collected: [LhUser] = []
            for try await user in group {
                collected.append(user)
            }
            return collected
        }

        return (users, result.queryCursor)
    }

    public func continueUserFollowers(cursor: CKQueryOperation.Cursor) async throws -> ([LhUser], CKQueryOperation.Cursor?) {
        let result = try await ck.records(startingAt: cursor, resultsLimit: 10, db: .pubDb)
        let followerLinks = result.matchResults.compactMap { try? $0.1.get() }.compactMap { LhUserFollower(record: $0) }

        let users = try await withThrowingTaskGroup(of: LhUser.self) { group -> [LhUser] in
            for link in followerLinks {
                group.addTask {
                    try await getLhUserByRecordName(link.follower)
                }
            }

            var collected: [LhUser] = []
            for try await user in group {
                collected.append(user)
            }
            return collected
        }

        return (users, result.queryCursor)
    }

    public func getFollowees(for recordName: String) async throws -> ([LhUser], CKQueryOperation.Cursor?) {
        let result = try await ck.records(for: .userFollower(.getFollowingForFollower(recordName)), resultsLimit: 10, db: .pubDb)
        let followerLinks = result.matchResults.compactMap { try? $0.1.get() }.compactMap { LhUserFollower(record: $0) }

        let users = try await withThrowingTaskGroup(of: LhUser.self) { group -> [LhUser] in
            for link in followerLinks {
                group.addTask {
                    try await getLhUserByRecordName(link.followee)
                }
            }

            var collected: [LhUser] = []
            for try await user in group {
                collected.append(user)
            }
            return collected
        }

        return (users, result.queryCursor)
    }

    public func continueUserFollowees(cursor: CKQueryOperation.Cursor) async throws -> ([LhUser], CKQueryOperation.Cursor?) {
        let result = try await ck.records(startingAt: cursor, resultsLimit: 10, db: .pubDb)
        let followerLinks = result.matchResults.compactMap { try? $0.1.get() }.compactMap { LhUserFollower(record: $0) }

        let users = try await withThrowingTaskGroup(of: LhUser.self) { group -> [LhUser] in
            for link in followerLinks {
                group.addTask {
                    try await getLhUserByRecordName(link.followee)
                }
            }

            var collected: [LhUser] = []
            for try await user in group {
                collected.append(user)
            }
            return collected
        }

        return (users, result.queryCursor)
    }

    public func createUserFollower(_ userFollower: LhUserFollower) async throws -> LhUserFollower {
        let record = userFollower.record
        let savedRecord = try await ck.save(record: record, db: .pubDb)
        guard let model = LhUserFollower(record: savedRecord) else { throw CloudKitError.badRecordData }
        return model
    }

    public func deleteUserFollower(with id: CKRecord.ID) async throws {
        let _ = try await ck.deleteRecord(withID: id, db: .pubDb)
    }

    public func getFollowerLink(for followerRecordName: String, followeeRecordName: String) async throws -> LhUserFollower? {
        let result = try await ck.records(for: .userFollower(.isFollowing(followerRecordName, followeeRecordName)), resultsLimit: 1, db: .pubDb)
        guard let record = try? result.matchResults.first?.1.get() else { return nil }
        return LhUserFollower(record: record)
    }

    public func isFollowRequestPending(for followeeRecordName: String) async throws -> LhUserFollowerRequest? {
        let (selfUser, _) = try await getSelfLhUser()
        guard let followerRecordName = selfUser.recordId?.recordName else { throw UserManagerError.selfUserNoRecordIdFound }
        let result = try await ck.records(for: .userFollowerRequest(.isPending(followerRecordName, followeeRecordName)), resultsLimit: 1, db: .pubDb)
        guard let record = try? result.matchResults.first?.1.get() else { return nil }
        return LhUserFollowerRequest(record: record)
    }

    public func getAllFollowerRequests() async throws -> ([LhUserFollowerRequest], CKQueryOperation.Cursor?) {
        let (selfUser, _) = try await getSelfLhUser()
        guard let followeeRecordName = selfUser.recordId?.recordName else { throw UserManagerError.selfUserNoRecordIdFound }
        let result = try await ck.records(for: .userFollowerRequest(.getRequestsForFollowee(followeeRecordName)), resultsLimit: 20, db: .pubDb)
        let requests = result.matchResults.compactMap { try? $0.1.get() }.compactMap { LhUserFollowerRequest(record: $0) }
        return (requests, result.queryCursor)
    }

    public func continueUserFollowerRequests(cursor: CKQueryOperation.Cursor) async throws -> ([LhUserFollowerRequest], CKQueryOperation.Cursor?) {
        let result = try await ck.records(startingAt: cursor, resultsLimit: 20, db: .pubDb)
        let requests = result.matchResults.compactMap { try? $0.1.get() }.compactMap { LhUserFollowerRequest(record: $0) }
        return (requests, result.queryCursor)
    }

    public func createUserFollowerRequest(_ request: LhUserFollowerRequest) async throws -> LhUserFollowerRequest {
        let record = request.record
        let savedRecord = try await ck.save(record: record, db: .pubDb)
        guard let model = LhUserFollowerRequest(record: savedRecord) else { throw CloudKitError.badRecordData }
        return model
    }

    public func deleteUserFollowerRequest(with id: CKRecord.ID) async throws {
        let _ = try await ck.deleteRecord(withID: id, db: .pubDb)
    }

    public func acceptUserFollowerRequest(_ request: LhUserFollowerRequest) async throws -> LhUserFollower {
        guard let requestId = request.recordId else { throw UserManagerError.noRecordIdFoundForUser }
        try await deleteUserFollowerRequest(with: requestId)
        let follower = LhUserFollower(follower: request.follower, followee: request.followee, created: request.created)
        return try await createUserFollower(follower)
    }
}
