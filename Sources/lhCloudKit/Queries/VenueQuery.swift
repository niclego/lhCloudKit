//
//  File.swift
//
//
//  Created by Nicolas Le Gorrec on 2/4/24.
//

import Foundation
import CloudKit

public extension Query {
    enum VenueQuery {
        case getVenueForMapKitLocationId(String)
        case getNearbyVenues(CLLocation)

        var query: CloudKitQuery {
            switch self {
            case .getVenueForMapKitLocationId(let mapKitLocationId):
                return getVenueForMapKitLocationId(mapKitLocationId)
            case .getNearbyVenues(let location):
                return getNearbyVenues(from: location)
            }
        }

        private func getVenueForMapKitLocationId(_ id: String) -> CloudKitQuery {
            let type = Venue.VenueRecordKeys.type.rawValue
            let sortDescriptorKey = Venue.VenueRecordKeys.name.rawValue
            let predicate = NSPredicate(format: "mapKitLocationId == %@", id)
            return .init(recordType: type, sortDescriptorKey: sortDescriptorKey, predicate: predicate, database: .pubDb)
        }

        private func getNearbyVenues(from location: CLLocation) -> CloudKitQuery {
            let type = Venue.VenueRecordKeys.type.rawValue
            let sortDescriptorKey = Venue.VenueRecordKeys.name.rawValue
            let radius: CGFloat = 2000; // meters
            let predicate = NSPredicate(format: "distanceToLocation:fromLocation:(location, %@) < %f AND mapKitLocationId != '###PINNED###'", location, radius)
            return .init(recordType: type, sortDescriptorKey: sortDescriptorKey, predicate: predicate, database: .pubDb)
        }
    }
}
