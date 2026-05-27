//
//  SupabaseClient.swift
//  Kart
//
//  Created by Yashi Gaur on 21/05/26.
//

import Foundation
import Supabase

class SupabaseManager {

    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        let supabaseURL = URL(string: "https://ncwfpdtwnbzwqlzujbcg.supabase.co")!
        let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5jd2ZwZHR3bmJ6d3FsenVqYmNnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkzMTY2NzcsImV4cCI6MjA5NDg5MjY3N30.EIxt5mOCULIgEsRLG1Xqoq8DwuuHzuBe5TnDazKaXhU"

        self.client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey,
            options: SupabaseClientOptions(
                auth: SupabaseClientOptions.AuthOptions(
                    storage: UserDefaultsLocalStorage(),
                    redirectToURL: URL(string: "yashigaur.kart://auth/callback"),
                    flowType: .pkce,
                    emitLocalSessionAsInitialSession: true
                )
            )
        )
    }
}

// UserDefaults-backed storage avoids Keychain access issues on the Simulator
// (Keychain can silently fail without entitlements, losing the PKCE code verifier)
struct UserDefaultsLocalStorage: AuthLocalStorage {
    func store(key: String, value: Data) throws {
        UserDefaults.standard.set(value, forKey: key)
    }

    func retrieve(key: String) throws -> Data? {
        UserDefaults.standard.data(forKey: key)
    }

    func remove(key: String) throws {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
