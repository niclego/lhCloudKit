//
//  AuthManager.swift
//
//
//  Created by Nicolas Le Gorrec on 8/8/24.
//

import Foundation
import Supabase

public struct AuthManager: AuthManageable {
    public init() { }

    public var authStateChanges: AsyncStream<(LhAuthChangeEvent, Bool)> {
        AsyncStream { continuation in
            // TODO: implement auth state change events
            continuation.finish()
        }
    }

    public func signInWithAppleIdToken(_ token: String) async throws {
        // TODO: implement sign in with Apple ID token
    }

    public func signOut() async throws {
        // TODO: implement sign out
    }
}
