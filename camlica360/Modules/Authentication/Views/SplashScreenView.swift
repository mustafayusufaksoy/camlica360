import SwiftUI

/// Splash screen view displayed on app launch
/// Shows the Camlica360 logo on a dark purple background
struct SplashScreenView: View {
    var body: some View {
        ZStack {
            // Background
            AppColors.primary950
                .ignoresSafeArea()

            // Logo - centered
            VStack(spacing: 0) {
                Image("CamlicaLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 225, height: 48)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .zIndex(1)
        }
    }
}

#Preview {
    SplashScreenView()
}
