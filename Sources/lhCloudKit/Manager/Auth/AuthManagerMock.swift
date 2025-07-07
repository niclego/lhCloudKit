//
//  AuthManagerMock.swift
//
//
//  Created by Nicolas Le Gorrec on 8/8/24.
//

import Foundation

public struct AuthManagerMock: AuthManageable {
    public init() {}

    public func signInWithAppleIdToken(_ token: String) async throws { }

    public func signOut() async throws { }
}
