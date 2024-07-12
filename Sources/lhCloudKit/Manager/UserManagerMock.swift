//
//  UserManagerMock.swift
//  
//
//  Created by Nicolas Le Gorrec on 7/9/24.
//

import Foundation

public struct UserManagerMock: UserManageable {
    private let ck: CloudKitable = LhCloudKitMock()

    public init() {}

    public func createLhUser() async throws -> LhUser {
        return await .mock
    }
    
    public func getSelfLhUser() async throws -> LhUser {
        return await .mock
    }
    
    public func getLhUserByRecordName(_ lhUserRecordName: String) async throws -> LhUser {
        return await .mock
    }
    
    public func searchLhUsersByUsername(_ username: String) async throws -> [LhUser] {
        return await [.mock]
    }
    
    public func getLhUserByUsername(_ username: String) async throws -> LhUser? {
        return await .mock
    }
    
    public func getAllLhUsers() async throws -> [LhUser] {
        return await [.mock]
    }
    
    public func updateSelfLhUser(with user: LhUser) async throws -> LhUser {
        return await .mock
    }
    
    public func addToSelfFollowing(_ followingRecordNames: [String]) async throws -> LhUser {
        return await .mock
    }
    
    public func changeUsername(to username: String) async throws -> LhUser {
        return await .mock
    }
    
    public func changeImage(to url: URL) async throws -> LhUser {
        return await .mock
    }

    public func isTaken(username: String) async throws -> Bool {
        return false
    }
    
    public func removeFromSelfFollowing(_ recordNames: [String]) async throws -> LhUser {
        return await .mock
    }

    public func getFollowers(for recordName: String) async throws -> [LhUser] {
        return await [.mock]
    }
}
