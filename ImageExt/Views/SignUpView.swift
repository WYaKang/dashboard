import SwiftUI

struct SignUpView: View {
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var agreedToTerms = false
    @Environment(\.dismiss) private var dismiss

    private enum Field {
        case fullName, email, password, confirmPassword
    }

    @FocusState private var focusedField: Field?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Logo
                    Image(systemName: "person.badge.plus")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundStyle(.blue.gradient)
                        .shadow(radius: 4)

                    // Welcome Text
                    VStack(spacing: 4) {
                        Text("Create Account")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Start your journey with ImageExt")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    // Form Fields
                    VStack(spacing: 16) {
                        // Full Name Field
                        HStack(spacing: 12) {
                            Image(systemName: "person.fill")
                                .foregroundStyle(.secondary)
                                .frame(width: 20)

                            TextField("Full Name", text: $fullName)
                                .textContentType(.name)
                                .focused($focusedField, equals: .fullName)
                        }
                        .padding()
                        .background(.background)
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(focusedField == .fullName ? .blue : .secondary.opacity(0.3), lineWidth: focusedField == .fullName ? 2 : 1)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))

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

                            SecureField("Password", text: $password)
                                .textContentType(.newPassword)
                                .focused($focusedField, equals: .password)

                            if !password.isEmpty {
                                Image(systemName: passwordStrength.icon)
                                    .foregroundStyle(passwordStrength.color)
                                    .font(.caption)
                            }
                        }
                        .padding()
                        .background(.background)
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(focusedField == .password ? .blue : .secondary.opacity(0.3), lineWidth: focusedField == .password ? 2 : 1)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        // Password strength indicator
                        if !password.isEmpty {
                            HStack(spacing: 4) {
                                ForEach(0..<4) { index in
                                    Rectangle()
                                        .fill(index < passwordStrength.score ? passwordStrength.color : .secondary.opacity(0.3))
                                        .frame(height: 4)
                                        .clipShape(RoundedRectangle(cornerRadius: 2))
                                }
                            }
                            .padding(.horizontal, 24)
                        }

                        // Confirm Password Field
                        HStack(spacing: 12) {
                            Image(systemName: "lock.shield.fill")
                                .foregroundStyle(.secondary)
                                .frame(width: 20)

                            SecureField("Confirm Password", text: $confirmPassword)
                                .textContentType(.newPassword)
                                .focused($focusedField, equals: .confirmPassword)

                            if !confirmPassword.isEmpty {
                                Image(systemName: passwordsMatch ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundStyle(passwordsMatch ? .green : .red)
                            }
                        }
                        .padding()
                        .background(.background)
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(focusedField == .confirmPassword ? .blue : .secondary.opacity(0.3), lineWidth: focusedField == .confirmPassword ? 2 : 1)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 24)

                    // Terms & Conditions
                    HStack(alignment: .top, spacing: 12) {
                        Button {
                            agreedToTerms.toggle()
                        } label: {
                            Image(systemName: agreedToTerms ? "checkmark.square.fill" : "square")
                                .foregroundStyle(agreedToTerms ? .blue : .secondary)
                        }
                        .buttonStyle(.plain)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("I agree to the ")
                                .font(.subheadline)
                                .foregroundStyle(.primary) +
                            Text("Terms of Service")
                                .font(.subheadline)
                                .foregroundStyle(.blue) +
                            Text(" and ")
                                .font(.subheadline)
                                .foregroundStyle(.primary) +
                            Text("Privacy Policy")
                                .font(.subheadline)
                                .foregroundStyle(.blue)

                            if showTermsError {
                                Text("You must agree to continue")
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                    .padding(.horizontal, 24)

                    // Sign Up Button
                    Button {
                        handleSignUp()
                    } label: {
                        Text("Create Account")
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

                            Text("Sign up with Apple")
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

                    // Sign In Link
                    HStack(spacing: 4) {
                        Text("Already have an account?")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Button("Sign In") {
                            dismiss()
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
        !fullName.isEmpty &&
        !email.isEmpty &&
        email.isValidEmail &&
        !password.isEmpty &&
        !confirmPassword.isEmpty &&
        passwordsMatch &&
        agreedToTerms
    }

    private var passwordsMatch: Bool {
        !confirmPassword.isEmpty && password == confirmPassword
    }

    private var passwordStrength: PasswordStrength {
        if password.isEmpty { return .none }
        let score = calculatePasswordStrength(password)
        return score == 0 ? .weak : score == 1 ? .fair : score == 2 ? .good : .strong
    }

    private var showTermsError: Bool {
        !agreedToTerms && (!fullName.isEmpty || !email.isEmpty || !password.isEmpty)
    }

    // MARK: - Actions

    private func handleSignUp() {
        // TODO: Implement sign up logic
        print("Sign up - Name: \(fullName), Email: \(email)")
    }

    private func handleSignInWithApple() {
        // TODO: Implement Sign in with Apple
        print("Sign up with Apple")
    }

    private func calculatePasswordStrength(_ password: String) -> Int {
        var score = 0
        if password.count >= 8 { score += 1 }
        if password.count >= 12 { score += 1 }
        if password.range(of: "[A-Z]", options: .regularExpression) != nil { score += 1 }
        if password.range(of: "[0-9]", options: .regularExpression) != nil { score += 1 }
        if password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil { score += 1 }
        return min(score, 3)
    }
}

// MARK: - Password Strength

enum PasswordStrength {
    case none, weak, fair, good, strong

    var score: Int {
        switch self {
        case .none: return 0
        case .weak: return 1
        case .fair: return 2
        case .good: return 3
        case .strong: return 4
        }
    }

    var color: Color {
        switch self {
        case .none: return .secondary
        case .weak: return .red
        case .fair: return .orange
        case .good: return .yellow
        case .strong: return .green
        }
    }

    var icon: String {
        switch self {
        case .none: return "lock"
        case .weak: return "lock.open"
        case .fair: return "lock"
        case .good: return "lock.fill"
        case .strong: return "lock.shield.fill"
        }
    }
}

// MARK: - Preview

#Preview {
    SignUpView()
}
