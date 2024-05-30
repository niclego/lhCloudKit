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
        case getNearbyActivityFeed(CLLocation)

        var query: CloudKitQuery {
            switch self {
            case .getHeardActivityFeed(let followingRecordNames):
                return getAllHeardModels(for: followingRecordNames)
            case .getNearbyActivityFeed(let location):
                return getNearbyActivityFeed(from: location)
            }
        }

        private func getAllHeardModels(for followingRecordNames: [String]) -> CloudKitQuery {
            let type = Heard.HeardRecordKeys.type.rawValue
            let sortDescriptorKey = Heard.HeardRecordKeys.created.rawValue
            let predicate = NSPredicate(format: "authorRecordName IN %@", followingRecordNames)
            return .init(recordType: type, sortDescriptorKey: sortDescriptorKey, predicate: predicate, database: .pubDb)
        }

        private func getNearbyActivityFeed(from location: CLLocation) -> CloudKitQuery {
            let type = Heard.HeardRecordKeys.type.rawValue
            let sortDescriptorKey = Heard.HeardRecordKeys.created.rawValue
            let radius: CGFloat = 2000; // meters
            let predicate = NSPredicate(format: "distanceToLocation:fromLocation:(location, %@) < %f", location, radius)
            return .init(recordType: type, sortDescriptorKey: sortDescriptorKey, predicate: predicate, database: .pubDb)
        }
    }
}
