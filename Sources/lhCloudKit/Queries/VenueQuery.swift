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
        case getNearbyVenues(CLLocation, CGFloat)

        var query: CloudKitQuery {
            switch self {
            case .getVenueForMapKitLocationId(let mapKitLocationId):
                return getVenueForMapKitLocationId(mapKitLocationId)
            case .getNearbyVenues(let location, let radius):
                return getNearbyVenues(from: location, radius: radius)
            }
        }

        private func getVenueForMapKitLocationId(_ id: String) -> CloudKitQuery {
            let type = Venue.VenueRecordKeys.type.rawValue
            let sortDescriptorKey = Venue.VenueRecordKeys.name.rawValue
            let predicate = NSPredicate(format: "mapKitLocationId == %@", id)
            return .init(recordType: type, sortDescriptorKey: sortDescriptorKey, predicate: predicate, database: .pubDb)
        }

        private func getNearbyVenues(from location: CLLocation, radius: CGFloat) -> CloudKitQuery {
            let type = Venue.VenueRecordKeys.type.rawValue
            let sortDescriptorKey = Venue.VenueRecordKeys.name.rawValue
            let predicate = NSPredicate(format: "distanceToLocation:fromLocation:(location, %@) < %f AND mapKitLocationId != '###PINNED###'", location, radius)
            return .init(recordType: type, sortDescriptorKey: sortDescriptorKey, predicate: predicate, database: .pubDb)
        }
    }
}
