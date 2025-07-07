//
//  AuthManager.swift
//
//
//  Created by Nicolas Le Gorrec on 8/8/24.
//

import Foundation
import Supabase

public struct AuthManager: AuthManageable {
    private let supabase = SupabaseClient(
      supabaseURL: URL(string: "https://avsqkaapqsvhwcbmqnum.supabase.co")!,
      supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF2c3FrYWFwcXN2aHdjYm1xbnVtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTEzOTIyMzMsImV4cCI6MjA2Njk2ODIzM30.9yh_jmoLKaOweHCqlKfE0NhDZtRKDOKdacm3r3LHFdI"
    )

    public init() { }

    public var authStateChanges: AsyncStream<(LhAuthChangeEvent, Bool)> {
        AsyncStream { continuation in
            Task {
                for await change in supabase.auth.authStateChanges {
                    let event = LhAuthChangeEvent(rawValue: change.event.rawValue)
                        ?? .signedOut
                    let isSignedOut = change.session == nil
                    continuation.yield((event, isSignedOut))
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
