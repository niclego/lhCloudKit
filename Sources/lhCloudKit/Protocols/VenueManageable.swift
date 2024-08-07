//
//  VenuManageable.swift
//
//
//  Created by Nicolas Le Gorrec on 7/9/24.
//

import CloudKit

public protocol VenueManageable: Sendable {
    func createVenue(_ venue: Venue) async throws -> Venue
    func getVenueByRecordName(_ venueRecordName: String) async throws -> Venue
    func getVenueByMapKitLocationId(_ mapKitLocationId: String) async throws -> Venue?
    func getNearbyVenues(from location: CLLocation) async throws -> ([Venue], CKQueryOperation.Cursor?)
}
