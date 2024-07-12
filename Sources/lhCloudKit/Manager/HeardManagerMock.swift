//
//  HeardManagerMock.swift
//
//
//  Created by Nicolas Le Gorrec on 7/9/24.
//

import CloudKit

public struct HeardManagerMock: HeardManageable {
    private let ck: CloudKitable = LhCloudKitMock()

    public init() {}

    public func createPublicHeardModel(_ heardModel: Heard) async throws -> Heard {
        return .mock
    }
    
    public func getHeardActivityFeed(for followingRecordNames: [String]) async throws -> ([Heard], CKQueryOperation.Cursor?) {
        return ([.mock], nil)
    }
    
    public func getNearbyHeardActivityFeed(from location: CLLocation) async throws -> ([Heard], CKQueryOperation.Cursor?) {
        return ([.mock], nil)
    }
    
    public func continueHeardActivityFeed(cursor: CKQueryOperation.Cursor) async throws -> ([Heard], CKQueryOperation.Cursor?) {
        return ([.mock], nil)
    }
    
    public func continueNearbyHeardActivityFeed(cursor: CKQueryOperation.Cursor) async throws -> ([Heard], CKQueryOperation.Cursor?) {
        return ([.mock], nil)
    }
}
