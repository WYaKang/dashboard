import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var rememberMe = false
    @Environment(\.dismiss) private var dismiss

    private enum Field {
        case email, password
    }

    @FocusState private var focusedField: Field?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Logo
                    Image(systemName: "photo.circle.fill")
                        .resizable()
                        .frame(width: 128, height: 128)
                        .foregroundStyle(.blue.gradient)
                        .shadow(radius: 4)

                    // Welcome Text
                    VStack(spacing: 4) {
                        Text("Welcome to ImageExt")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Sign in to continue")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    // Form Fields
                    VStack(spacing: 16) {
                        // Email Field
                        HStack(spacing: 12) {
                            Image(systemName: "envelope.fill")
                                .foregroundStyle(.secondary)
                                .frame(width: 20)

                            TextField("Email", text: $email)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .focused($focusedField, equals: .email)
                        }
                        .padding()
                        .background(.background)
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(focusedField == .email ? .blue : .secondary.opacity(0.3), lineWidth: focusedField == .email ? 2 : 1)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        // Password Field
                        HStack(spacing: 12) {
                            Image(systemName: "lock.fill")
                                .foregroundStyle(.secondary)
                                .frame(width: 20)

                            Group {
                                if isPasswordVisible {
                                    TextField("Password", text: $password)
                                        .textContentType(.password)
                                } else {
                                    SecureField("Password", text: $password)
                                        .textContentType(.password)
                                }
                            }
                            .focused($focusedField, equals: .password)

                            Button {
                                isPasswordVisible.toggle()
                            } label: {
                                Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding()
                        .background(.background)
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(focusedField == .password ? .blue : .secondary.opacity(0.3), lineWidth: focusedField == .password ? 2 : 1)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 24)

                    // Forgot Password & Remember Me
                    HStack {
                        Button {
                            rememberMe.toggle()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: rememberMe ? "checkmark.square.fill" : "square")
                                    .foregroundStyle(rememberMe ? .blue : .secondary)
                                Text("Remember me")
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                            }
                        }
                        .buttonStyle(.plain)

                        Spacer()

                        Button("Forgot Password?") {
                            // Handle forgot password
                        }
                        .font(.subheadline)
                        .foregroundStyle(.blue)
                    }
                    .padding(.horizontal, 24)

                    // Sign In Button
                    Button {
                        handleSignIn()
                    } label: {
                        Text("Sign In")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isFormValid ? .blue : .gray)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(!isFormValid)
                    .padding(.horizontal, 24)

                    // Divider
                    HStack(spacing: 16) {
                        Rectangle()
                            .fill(.secondary.opacity(0.3))
                            .frame(height: 1)

                        Text("or")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Rectangle()
                            .fill(.secondary.opacity(0.3))
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 24)

                    // Sign Up with Apple
                    Button {
                        handleSignInWithApple()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "applelogo")
                                .imageScale(.large)

                            Text("Sign in with Apple")
                                .font(.headline)
                                .foregroundStyle(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.background)
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.secondary.opacity(0.3), lineWidth: 1)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 24)

                    // Sign Up Link
                    HStack(spacing: 4) {
                        Text("Don't have an account?")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Button("Sign Up") {
                            // Navigate to sign up
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                    }
                    .padding(.top, 8)
                }
                .padding(.vertical, 32)
            }
            .scrollBounceBehavior(.basedOnSize)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .interactiveDismissDisabled()
    }

    // MARK: - Computed Properties

    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && email.isValidEmail
    }

    // MARK: - Actions

    private func handleSignIn() {
        // TODO: Implement sign in logic
        print("Sign in with email: \(email)")
    }

    private func handleSignInWithApple() {
        // TODO: Implement Sign in with Apple
        print("Sign in with Apple")
    }
}

// MARK: - String Validation Extension

extension String {
    var isValidEmail: Bool {
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
        return emailPredicate.evaluate(with: self)
    }
}

// MARK: - Preview

#Preview {
    LoginView()
}
