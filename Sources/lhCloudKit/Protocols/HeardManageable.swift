//
//  HeardManageable.swift
//
//
//  Created by Nicolas Le Gorrec on 7/9/24.
//

import CloudKit

public protocol HeardManageable: Sendable {
    func createPublicHeardModel(_ heardModel: Heard) async throws -> Heard
    func deletePublicHeardModel(with id: CKRecord.ID) async throws
    func getHeardActivityFeed(for followingRecordNames: [String]) async throws -> ([Heard], CKQueryOperation.Cursor?)
    func getNearbyHeardActivityFeed(from location: CLLocation, radius: CGFloat) async throws -> ([Heard], CKQueryOperation.Cursor?)
    func getVenueActivityFeed(for venueRecordName: String) async throws -> ([Heard], CKQueryOperation.Cursor?)
    func continueHeardActivityFeed(cursor: CKQueryOperation.Cursor) async throws -> ([Heard], CKQueryOperation.Cursor?)
    func continueNearbyHeardActivityFeed(cursor: CKQueryOperation.Cursor) async throws -> ([Heard], CKQueryOperation.Cursor?)
    func continueVenueHeardActivityFeed(cursor: CKQueryOperation.Cursor) async throws -> ([Heard], CKQueryOperation.Cursor?)
}
