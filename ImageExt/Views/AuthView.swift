import SwiftUI

/// Main authentication view that handles navigation between login and sign up
struct AuthView: View {
    @State private var selectedTab: AuthTab = .login

    enum AuthTab {
        case login, signUp
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            LoginViewDemo()
                .tag(AuthTab.login)
                .toolbar(.hidden, for: .tabBar)

            SignUpView()
                .tag(AuthTab.signUp)
                .toolbar(.hidden, for: .tabBar)
        }
        .tint(.blue)
    }
}

// MARK: - Preview

#Preview {
    AuthView()
}
