//
//  VenueManagerMock.swift
//
//
//  Created by Nicolas Le Gorrec on 2/23/24.
//

import CloudKit

public struct VenueManagerMock: VenueManageable {
    private let ck: CloudKitable = LhCloudKitMock()

    public init() {}

    public func createVenue(_ venue: Venue) async throws -> Venue {
        return .mock
    }

    private func getVenueByRecordName(_ venueRecordName: String) async throws -> (Venue, CKRecord) {
        return (.mock, .init(recordType: "mock"))
    }

    public func getVenueByRecordName(_ venueRecordName: String) async throws -> Venue {
        return .mock
    }

    public func getVenueByMapKitLocationId(_ mapKitLocationId: String) async throws -> Venue? {
        return .mock
    }

    public func getNearbyVenues(from location: CLLocation, radius: CGFloat) async throws -> ([Venue], CKQueryOperation.Cursor?) {
        return ([.mock], nil)
    }
}
