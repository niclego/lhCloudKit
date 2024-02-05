//
//  File.swift
//  
//
//  Created by Nicolas Le Gorrec on 2/4/24.
//

import Foundation

final class LhCloudKitMock: CloudKitable {
    let containerId: String

    init(containerId: String) {
        self.containerId = containerId
    }

    func query<T: CloudKitRecordable>(_ query: LhQuery) async throws -> [T] { [T.mock] }
    func save<T: CloudKitRecordable>(model: T, db: LhDatabase) async throws -> T { T.mock }
    func fetchUserRecordIdString() async throws -> String { "TESTUSERID1234" }
}
