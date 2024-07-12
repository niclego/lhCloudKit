//
//  HeardManageable.swift
//
//
//  Created by Nicolas Le Gorrec on 7/9/24.
//

import CloudKit

public protocol HeardManageable: Sendable {
    func createPublicHeardModel(_ heardModel: Heard) async throws -> Heard
    func getHeardActivityFeed(for followingRecordNames: [String]) async throws -> ([Heard], CKQueryOperation.Cursor?)
    func getNearbyHeardActivityFeed(from location: CLLocation) async throws -> ([Heard], CKQueryOperation.Cursor?)
    func continueHeardActivityFeed(cursor: CKQueryOperation.Cursor) async throws -> ([Heard], CKQueryOperation.Cursor?)
    func continueNearbyHeardActivityFeed(cursor: CKQueryOperation.Cursor) async throws -> ([Heard], CKQueryOperation.Cursor?)
}
