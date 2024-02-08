//
//  HomeViewModel.swift
//  lastheard
//
//  Created by Nicolas Le Gorrec on 2/4/24.
//

import CloudKit
import Observation

@Observable
public final class UserManager {

    private let ck: CloudKitable

    public init(ck: CloudKitable = LhCloudKitMock()) {
        self.ck = ck
    }

    public func updateUsername(username: String) async throws -> LhUser {
        let (systemUser, _) = try await getSystemUser()
        let (lHUser, lhUserRecord) = try await getLhUser(for: systemUser)

        guard username != lHUser.username else { throw CloudKitError.usernameAlreadyExistsForUser }

        // TODO: Check if name is taken

        lhUserRecord[LhUser.LhUserRecordKeys.username.rawValue] = username
        let updatedUserRecord = try await ck.save(record: lhUserRecord, db: .pubDb)

        guard let newUser = LhUser(record: updatedUserRecord) else { throw CloudKitError.badRecordData }

        return newUser
    }

    public func getSystemUser() async throws -> (User, CKRecord) {
        let recordId = try await ck.selfRecordId()
        let systemUserRecord = try await ck.record(for: recordId, db: .pubDb)

        guard let systemUser = User(record: systemUserRecord)
        else { throw CloudKitError.badRecordData }

        return (systemUser, systemUserRecord)
    }

    public func getLhUser(for systemUser: User) async throws -> (LhUser, CKRecord) {
        guard let lhUserRecordName = systemUser.lhUserRecordName
        else { throw CloudKitError.lhUserDoesNotExistForSystemUser }

        let lhUserRecordId = CKRecord.ID(recordName: lhUserRecordName)
        let lhUserRecord = try await ck.record(for: lhUserRecordId, db: .pubDb)

        guard let lhUser = LhUser(record: lhUserRecord) else { throw CloudKitError.badRecordData }

        return (lhUser, lhUserRecord)
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
}
