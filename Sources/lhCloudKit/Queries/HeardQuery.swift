//
//  File.swift
//  
//
//  Created by Nicolas Le Gorrec on 2/4/24.
//

import Foundation

public extension Query {
    enum HeardQuery {
        case queryHeard(String)

        var query: CloudKitQuery {
            switch self {
            case .queryHeard(let userRecordId):
                return queryHeard(for: userRecordId)
            }
        }

        private func queryHeard(for userRecordId: String) -> CloudKitQuery {
            let type = Heard.HeardRecordKeys.type.rawValue
            let sortDescriptorKey = "time"
            let predicate = NSPredicate(value: true)
            
            return .init(recordType: type, sortDescriptorKey: sortDescriptorKey, predicate: predicate, database: .pubDb)
        }
    }
}
