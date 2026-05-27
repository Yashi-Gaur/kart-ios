//
//  AuthViewModel.swift
//  Kart
//
//  Created by Yashi Gaur on 21/05/26.
//

import Foundation
import Combine
import Supabase
import AuthenticationServices
import UIKit

@MainActor
class AuthViewModel: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {

    @Published var isAuthenticated: Bool = false
    @Published var isCheckingAuth: Bool = true
    @Published var currentUser: User?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false

    private let supabase = SupabaseManager.shared.client
    private var useEphemeralSession = false

    // Subscribe to auth state changes for the lifetime of the app.
    // Checking isExpired on .initialSession prevents an auto-refreshed stale
    // session from skipping the sign-in screen.
    func listenToAuthChanges() async {
        for await (event, session) in await supabase.auth.authStateChanges {
            switch event {
            case .initialSession:
                if let session, !session.isExpired {
                    currentUser = session.user
                    isAuthenticated = true
                } else {
                    isAuthenticated = false
                }
                isCheckingAuth = false

            case .signedIn:
                if let session {
                    currentUser = session.user
                    do {
                        try await syncUserToBackend(user: session.user)
                        isAuthenticated = true
                    } catch {
                        try? await supabase.auth.signOut()
                        errorMessage = "Could not connect to server. Please try again."
                        showError = true
                    }
                }

            case .tokenRefreshed:
                currentUser = session?.user
                isAuthenticated = session != nil

            case .signedOut:
                currentUser = nil
                isAuthenticated = false

            default:
                break
            }
        }
    }

    func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil

        do {
            let ephemeral = useEphemeralSession
            try await supabase.auth.signInWithOAuth(
                provider: .google
            ) { [weak self] session in
                guard let self else { return }
                session.presentationContextProvider = self
                session.prefersEphemeralWebBrowserSession = ephemeral
            }
            useEphemeralSession = false
        } catch let error as ASWebAuthenticationSessionError where error.code == .canceledLogin {
            // User dismissed the browser — not an error
        } catch {
            errorMessage = "Sign in failed: \(error.localizedDescription)"
            showError = true
        }

        isLoading = false
    }

    func signOut() async {
        do {
            try await supabase.auth.signOut()
            useEphemeralSession = true
        } catch {
            errorMessage = "Sign out failed: \(error.localizedDescription)"
            showError = true
        }
    }

    // MARK: - ASWebAuthenticationPresentationContextProviding

    nonisolated func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        MainActor.assumeIsolated {
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .compactMap { $0.keyWindow }
                .first ?? UIWindow()
        }
    }

    // MARK: - Private

    private func syncUserToBackend(user: User) async throws {
        guard let url = URL(string: "http://localhost:8000/api/auth/sync") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "user_id": user.id.uuidString,
            "email": user.email ?? "",
            "auth_provider": "google",
            "profile_name": user.userMetadata["full_name"]?.stringValue
                ?? user.email?.split(separator: "@").first.map(String.init) ?? ""
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            print("⚠️ Backend sync returned non-2xx")
            return
        }
    }
}
