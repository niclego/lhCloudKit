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

        var query: CloudKitQuery {
            switch self {
            case .getVenueForMapKitLocationId(let mapKitLocationId):
                return getVenueForMapKitLocationId(mapKitLocationId)
            }
        }

        private func getVenueForMapKitLocationId(_ id: String) -> CloudKitQuery {
            let type = Venue.VenueRecordKeys.type.rawValue
            let sortDescriptorKey = Venue.VenueRecordKeys.name.rawValue
            let predicate = NSPredicate(format: "mapKitLocationId == %@", id)
            return .init(recordType: type, sortDescriptorKey: sortDescriptorKey, predicate: predicate, database: .pubDb)
        }
    }
}
