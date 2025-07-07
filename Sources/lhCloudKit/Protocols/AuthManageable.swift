//
//  AuthManageable.swift
//
//
//  Created by Nicolas Le Gorrec on 8/8/24.
//

import Foundation

public protocol AuthManageable: Sendable {
    func signInWithAppleIdToken(_ token: String) async throws
    func signOut() async throws
    var authStateChanges: AsyncStream<(event: LhAuthChangeEvent, isSignedIn: Bool)> { get }
}
