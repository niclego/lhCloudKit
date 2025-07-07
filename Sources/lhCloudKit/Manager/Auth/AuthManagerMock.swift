//
//  AuthManagerMock.swift
//
//
//  Created by Nicolas Le Gorrec on 8/8/24.
//

import Foundation

public struct AuthManagerMock: AuthManageable {
    public init() {}

    public var authStateChanges: AsyncStream<(LhAuthChangeEvent, Bool)> {
        AsyncStream { continuation in
            continuation.finish()
        }
    }

    public func signInWithAppleIdToken(_ token: String) async throws { }

    public func signOut() async throws { }
}
