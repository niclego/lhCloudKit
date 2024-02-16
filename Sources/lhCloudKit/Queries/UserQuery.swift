//
//  File.swift
//  
//
//  Created by Nicolas Le Gorrec on 2/4/24.
//

import Foundation

public extension Query {
    enum UserQuery {
        case allLhUsers
        case getByUsername(String)
        case searchByUsername(String)
        case getFollowers(String)

        var query: CloudKitQuery {
            switch self {
            case .allLhUsers:
                return queryAllLhUsers()
            case .getByUsername(let username):
                return getBy(username: username)
            case .searchByUsername(let username):
                return searchBy(username: username)
            case .getFollowers(let lhUserRecordName):
                return getFollowers(for: lhUserRecordName)
            }
        }

        private func queryAllLhUsers() -> CloudKitQuery {
            return .init(
                recordType: LhUser.LhUserRecordKeys.type.rawValue,
                sortDescriptorKey: LhUser.LhUserRecordKeys.username.rawValue,
                predicate: nil,
                database: .pubDb
            )
        }

        private func getBy(username: String) -> CloudKitQuery {
            return .init(
                recordType: LhUser.LhUserRecordKeys.type.rawValue,
                sortDescriptorKey: LhUser.LhUserRecordKeys.username.rawValue,
                predicate: NSPredicate(format: "username == %@", username),
                database: .pubDb
            )
        }

        private func searchBy(username: String) -> CloudKitQuery {
            return .init(
                recordType: LhUser.LhUserRecordKeys.type.rawValue,
                sortDescriptorKey: LhUser.LhUserRecordKeys.username.rawValue,
                predicate: NSPredicate(format: "username BEGINSWITH %@", username),
                database: .pubDb
            )
        }

        private func getFollowers(for recordName: String) -> CloudKitQuery {
            return .init(
                recordType: LhUser.LhUserRecordKeys.type.rawValue,
                sortDescriptorKey: LhUser.LhUserRecordKeys.username.rawValue,
                predicate: NSPredicate(format: "ANY followingLhUserRecordNames = %@", recordName),
                database: .pubDb
            )
        }
    }
}
