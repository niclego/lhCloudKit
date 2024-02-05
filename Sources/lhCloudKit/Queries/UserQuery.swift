//
//  File.swift
//  
//
//  Created by Nicolas Le Gorrec on 2/4/24.
//

import Foundation

extension LhQuery {
    enum UserQuery {
        case queryUsers(String)

        var query: CloudKitQuery {
            switch self {
            case .queryUsers(let username):
                return queryUsers(username: username)
            }
        }

        private func queryUsers(username: String) -> CloudKitQuery {
            let type = User.UserRecordKeys.type.rawValue
            let sortDescriptorKey = "username"
            let predicate = NSPredicate(value: true)

            return .init(recordType: type, sortDescriptorKey: sortDescriptorKey, predicate: predicate, database: .pubDb)
        }
    }
}
