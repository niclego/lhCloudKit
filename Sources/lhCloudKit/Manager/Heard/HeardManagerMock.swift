//
//  HeardManagerMock.swift
//
//
//  Created by Nicolas Le Gorrec on 7/9/24.
//

import CloudKit

public struct HeardManagerMock: HeardManageable {
    public init() {}

    public func createPublicHeardModel(_ heardModel: Heard) async throws -> Heard {
        return .mock
    }

    public func deletePublicHeardModel(with id: CKRecord.ID) async throws { }

    public func getHeardActivityFeed(for followingRecordNames: [String]) async throws -> ([Heard], CKQueryOperation.Cursor?) {
        return ([], nil)
    }
    
    public func getNearbyHeardActivityFeed(from location: CLLocation, radius: CGFloat) async throws -> ([Heard], CKQueryOperation.Cursor?) {
        return ([], nil)
    }
    
    public func continueHeardActivityFeed(cursor: CKQueryOperation.Cursor) async throws -> ([Heard], CKQueryOperation.Cursor?) {
        return ([.mock], nil)
    }
    
    public func continueNearbyHeardActivityFeed(cursor: CKQueryOperation.Cursor) async throws -> ([Heard], CKQueryOperation.Cursor?) {
        return ([.mock], nil)
    }
}
