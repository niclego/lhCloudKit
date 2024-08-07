//
//  VenueManager.swift
//  
//
//  Created by Nicolas Le Gorrec on 2/23/24.
//

import CloudKit

public struct VenueManager: VenueManageable {
    private let ck: CloudKitable

    public init(ck: CloudKitable) {
        self.ck = ck
    }

    public func createVenue(_ venue: Venue) async throws -> Venue {
        let record = venue.record
        let savedRecord = try await ck.save(record: record, db: .pubDb)
        guard let venue = Venue(record: savedRecord) else { throw CloudKitError.badRecordData }
        return venue
    }

    private func getVenueByRecordName(_ venueRecordName: String) async throws -> (Venue, CKRecord) {
        let venueRecordId = CKRecord.ID(recordName: venueRecordName)
        let venueRecord = try await ck.record(for: venueRecordId, db: .pubDb)
        guard let venue = Venue(record: venueRecord) else { throw CloudKitError.badRecordData }
        return (venue, venueRecord)
    }

    public func getVenueByRecordName(_ venueRecordName: String) async throws -> Venue {
        return try await getVenueByRecordName(venueRecordName).0
    }

    public func getVenueByMapKitLocationId(_ mapKitLocationId: String) async throws -> Venue? {
        let result = try await ck.records(for: .venue(.getVenueForMapKitLocationId(mapKitLocationId)), resultsLimit: nil, db: .pubDb)
        guard let venueRecord = try result.matchResults.first?.1.get(),
              let venue = Venue(record: venueRecord)
        else { return nil }

        return venue
    }

    public func getNearbyVenues(from location: CLLocation) async throws -> ([Venue], CKQueryOperation.Cursor?) {
        let result = try await ck.records(for: .venue(.getNearbyVenues(location)), resultsLimit: 25, db: .pubDb)
        let nearbyVenues = result.matchResults.compactMap { try? $0.1.get() }.compactMap { Venue(record: $0) }
        return (nearbyVenues, result.queryCursor)
    }
}
