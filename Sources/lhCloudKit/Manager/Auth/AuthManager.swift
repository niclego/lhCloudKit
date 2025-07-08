//
//  AuthManager.swift
//
//
//  Created by Nicolas Le Gorrec on 8/8/24.
//

import Foundation
import Supabase

public struct AuthManager: AuthManageable {
    private let supabase: SupabaseClient

    public init(supabase: SupabaseClient) {
        self.supabase = supabase
    }

    public var authStateChanges: AsyncStream<(event: LhAuthChangeEvent, isSignedIn: Bool)> {
        AsyncStream { continuation in
            Task {
                for await change in supabase.auth.authStateChanges {
                    let event = LhAuthChangeEvent(rawValue: change.event.rawValue)
                        ?? .signedOut
                    let isSignedIn = change.session != nil
                    continuation.yield((event, isSignedIn))
                }
            }
        }
    }

    public func signInWithAppleIdToken(_ token: String) async throws {
        try await supabase.auth.signInWithIdToken(
                      credentials: .init(
                        provider: .apple,
                        idToken: token
                      )
                    )
    }

    public func signOut() async throws {
        try await supabase.auth.signOut()
    }
}
