import SwiftUI

/// Root view of the application that handles navigation flow
/// Shows splash screen on app launch, then checks authentication and navigates accordingly
struct AppRootView: View {
    @StateObject private var authStateManager = AuthStateManager.shared
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashScreenView()
                    .transition(.opacity)
            } else {
                if authStateManager.isAuthenticated {
                    // User is authenticated - show home view
                    HomeView()
                        .transition(.opacity)
                } else {
                    // User is not authenticated - show login view
                    NavigationStack {
                        LoginView()
                    }
                    .transition(.opacity)
                }
            }
        }
        .environmentObject(authStateManager)
        .onAppear {
            // Show splash screen for 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showSplash = false
                }
            }
        }
    }
}

#Preview {
    AppRootView()
}
