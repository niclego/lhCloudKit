//
//  UserManagerMock.swift
//  
//
//  Created by Nicolas Le Gorrec on 7/9/24.
//

import Foundation
import CloudKit

public struct UserManagerMock: UserManageable {
    private let ck: CloudKitable = LhCloudKitMock()

    public init() {}

    public func getSelfLhUser() async throws -> LhUser {
        return .mock
    }

    public func getLhUserByRecordName(_ lhUserRecordName: String) async throws -> LhUser {
        return .mock
    }

    public func searchLhUsersByUsername(_ username: String) async throws -> [LhUser] {
        return [.mock]
    }

    public func getLhUserByUsername(_ username: String) async throws -> LhUser? {
        return .mock
    }

    public func updateSelfLhUser(with user: LhUser) async throws -> LhUser {
        return .mock
    }

    public func addToSelfFollowing(_ followingRecordNames: [String]) async throws -> LhUser {
        return .mock
    }

    public func changeUsername(to username: String) async throws -> LhUser {
        return .mock
    }

    public func changeImage(to url: URL) async throws -> LhUser {
        return .mock
    }

    public func changeAccountType(to accountType: LhUser.AccountType) async throws -> LhUser {
        return .mock
    }

    public func isTaken(username: String) async throws -> Bool {
        return false
    }

    public func removeFromSelfFollowing(_ recordNames: [String]) async throws -> LhUser {
        return .mock
    }

    public func getFollowers(for recordName: String) async throws -> ([LhUser], CKQueryOperation.Cursor?) {
        return ([], nil)
    }

    public func continueUserFollowers(cursor: CKQueryOperation.Cursor) async throws -> ([LhUser], CKQueryOperation.Cursor?) {
        return ([.mock], nil)
    }
}
