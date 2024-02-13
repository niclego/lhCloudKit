//
//  HomeViewModel.swift
//  lastheard
//
//  Created by Nicolas Le Gorrec on 2/4/24.
//

import CloudKit

public struct UserManager {

    private let ck: CloudKitable

    public init(ck: CloudKitable = LhCloudKitMock()) {
        self.ck = ck
    }

    public func createLhUser() async throws -> LhUser {
        let (systemUser, systemUserRecord) = try await getSystemUser()

        guard systemUser.lhUserRecordName == nil else { throw CloudKitError.lhUserAlreadyExistsForSystemUser }

        let user = LhUser(username: nil)
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

    public func getSelfLhUser() async throws -> LhUser {
        let (sysUser, _) = try await getSystemUser()
        guard let recordName = sysUser.lhUserRecordName else { throw CloudKitError.lhUserDoesNotExistForSystemUser }
        let (lHUser, _) = try await getLhUser(lhUserRecordName: recordName)
        return lHUser
    }

    private func getLhUser(lhUserRecordName: String) async throws -> (LhUser, CKRecord) {
        let lhUserRecordId = CKRecord.ID(recordName: lhUserRecordName)
        let lhUserRecord = try await ck.record(for: lhUserRecordId, db: .pubDb)

        guard let lhUser = LhUser(record: lhUserRecord) else { throw CloudKitError.badRecordData }

        return (lhUser, lhUserRecord)
    }

    public func getLhUserBy(username: String) async throws -> [LhUser] {
        return try await ck.query(.user(.getByUsername(username)))
    }

    public func getAllLhUsers() async throws -> [LhUser] {
        return try await ck.query(.user(.allLhUsers))
    }

    public func updateLhUser(_ user: LhUser) async throws -> LhUser {
        let (_, lhUserRecord) = try await getLhUser(lhUserRecordName: user.record.recordID.recordName)

        // TODO: Check if name is taken

        lhUserRecord[LhUser.LhUserRecordKeys.username.rawValue] = user.username
        let updatedUserRecord = try await ck.save(record: lhUserRecord, db: .pubDb)

        guard let newUser = LhUser(record: updatedUserRecord) else { throw CloudKitError.badRecordData }

        return newUser
    }
}
