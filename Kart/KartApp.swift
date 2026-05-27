//
//  KartApp.swift
//  Kart
//
//  Created by Yashi Gaur on 27/03/26.
//

import SwiftUI

@main
struct KartApp: App {

    @StateObject private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isCheckingAuth {
                    ProgressView()
                } else if authViewModel.isAuthenticated {
                    ListInputView()
                } else {
                    SignInView()
                }
            }
            .environmentObject(authViewModel)
            .task {
                await authViewModel.listenToAuthChanges()
            }
        }
    }
}
