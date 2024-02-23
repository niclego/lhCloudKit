//
//  File.swift
//  
//
//  Created by Nicolas Le Gorrec on 2/4/24.
//

public enum Query {
    case heard(HeardQuery)
    case user(UserQuery)
    case venue(VenueQuery)

    var query: CloudKitQuery {
        switch self {
        case .heard(let heardQuery):
            heardQuery.query
        case .user(let userQuery):
            userQuery.query
        case .venue(let venueQuery):
            venueQuery.query
        }
    }
}
