//
//  AuthManager.swift
//
//
//  Created by Nicolas Le Gorrec on 8/8/24.
//

import Foundation

public struct AuthManager: AuthManageable {
    public init() { }

    public func signInWithAppleIdToken(_ token: String) async throws {
        // TODO: implement sign in with Apple ID token
    }

    public func signOut() async throws {
        // TODO: implement sign out
    }
}
