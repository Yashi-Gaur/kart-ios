//
//  SignInView.swift
//  Kart
//
//  Created by Yashi Gaur on 21/05/26.
//

import SwiftUI

struct SignInView: View {

    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 32) {

            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "cart.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)

                Text("Kart")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("AI-powered shopping assistant")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(spacing: 16) {
                if authViewModel.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Waiting for sign in...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Button {
                        Task { await authViewModel.signInWithGoogle() }
                    } label: {
                        HStack {
                            Image(systemName: "globe")
                                .font(.title3)
                            Text("Continue with Google")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
            }
            .padding(.horizontal, 32)

            Spacer()

            Text("By continuing, you agree to our Terms and Privacy Policy")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 32)
        }
        .alert("Error", isPresented: $authViewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(authViewModel.errorMessage ?? "Unknown error")
        }
    }
}

#Preview {
    SignInView()
        .environmentObject(AuthViewModel())
}
