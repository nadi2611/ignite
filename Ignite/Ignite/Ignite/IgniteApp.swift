//
//  IgniteApp.swift
//  Ignite
//
//  Created by Nadi Najjar on 27/03/2026.
//

import SwiftUI
import Firebase

@main
struct IgniteApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var l = L10n.shared

    init() {
        FirebaseApp.configure()
        SeedService.seedIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if authViewModel.isLoggedIn {
                    if authViewModel.onboardingComplete {
                        HomeView()
                            .environmentObject(authViewModel)
                    } else {
                        OnboardingContainerView()
                            .environmentObject(authViewModel)
                    }
                } else {
                    WelcomeView()
                        .environmentObject(authViewModel)
                }

                if authViewModel.isInitializing {
                    SplashView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .animation(.easeOut(duration: 0.5), value: authViewModel.isInitializing)
            .environment(\.layoutDirection, l.layoutDirection)
            .environment(\.locale, l.locale)
            .environmentObject(l)
            .id(l.language)
        }
    }
}
