//
//  File.swift
//  
//
//  Created by Nicolas Le Gorrec on 2/4/24.
//

import Foundation
import CloudKit
import CoreLocation

public extension Query {
    enum HeardQuery {
        case getHeardActivityFeed([String])
        case getVenueHeardFeed(String)
        case getNearbyActivityFeed(CLLocation, CGFloat)

        var query: CloudKitQuery {
            switch self {
            case .getHeardActivityFeed(let followingRecordNames):
                return getAllHeardModels(for: followingRecordNames)
            case .getNearbyActivityFeed(let location, let radius):
                return getNearbyActivityFeed(from: location, radius: radius)
            case .getVenueHeardFeed(let venueRecordName):
                return getVenueHeardModels(for: venueRecordName)
            }
        }

        private func getAllHeardModels(for followingRecordNames: [String]) -> CloudKitQuery {
            let type = Heard.HeardRecordKeys.type.rawValue
            let sortDescriptorKey = Heard.HeardRecordKeys.created.rawValue
            let predicate = NSPredicate(format: "authorRecordName IN %@", followingRecordNames)
            return .init(recordType: type, sortDescriptorKey: sortDescriptorKey, predicate: predicate, database: .pubDb)
        }

        private func getNearbyActivityFeed(from location: CLLocation, radius: CGFloat) -> CloudKitQuery {
            let type = Heard.HeardRecordKeys.type.rawValue
            let sortDescriptorKey = Heard.HeardRecordKeys.created.rawValue
            let predicate = NSPredicate(format: "distanceToLocation:fromLocation:(location, %@) < %f", location, radius)
            return .init(recordType: type, sortDescriptorKey: sortDescriptorKey, predicate: predicate, database: .pubDb)
        }

        private func getVenueHeardModels(for recordName: String) -> CloudKitQuery {
            let type = Heard.HeardRecordKeys.type.rawValue
            let sortDescriptorKey = Heard.HeardRecordKeys.created.rawValue
            let predicate = NSPredicate(format: "venueRecordName == %@", recordName)
            return .init(recordType: type, sortDescriptorKey: sortDescriptorKey, predicate: predicate, database: .pubDb)
        }
    }
}
