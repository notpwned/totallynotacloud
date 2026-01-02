import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authService: AuthService
    @State private var isLogin = true
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(spacing: 12) {
                    Image(systemName: "cloud.fill")
                        .font(.system(size: 56))
                        .foregroundColor(AppColors.accentBlue)
                    
                    Text("totallynotacloud")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Cloud storage for everyone")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.top, 40)
                .padding(.bottom, 50)
                
                if isLogin {
                    LoginFormView()
                } else {
                    RegisterFormView()
                }
                
                Spacer()
                
                HStack(spacing: 0) {
                    Text(isLogin ? "No account? " : "Have an account? ")
                        .foregroundColor(AppColors.textSecondary)
                    
                    Button(isLogin ? "Sign Up" : "Sign In") {
                        withAnimation {
                            isLogin.toggle()
                        }
                    }
                    .foregroundColor(AppColors.accentBlue)
                    .font(.system(size: 13, weight: .semibold))
                }
                .padding(.bottom, 30)
            }
            .padding(.horizontal, 30)
        }
    }
}

struct LoginFormView: View {
    @EnvironmentObject var authService: AuthService
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
                
                TextField("name@example.com", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 12))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
                
                SecureField("••••••••", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 12))
            }
            
            Button(action: {
                Task {
                    await authService.login(email: email, password: password)
                }
            }) {
                if authService.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(0.8)
                } else {
                    Text("Sign In")
                        .font(.system(size: 12, weight: .semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(AppColors.accentBlue)
            .foregroundColor(.white)
            .cornerRadius(6)
            .disabled(authService.isLoading || email.isEmpty || password.isEmpty)
        }
    }
}

struct RegisterFormView: View {
    @EnvironmentObject var authService: AuthService
    @State private var email = ""
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    var isFormValid: Bool {
        !email.isEmpty && !username.isEmpty && !password.isEmpty && password == confirmPassword && password.count >= 6
    }
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
                
                TextField("name@example.com", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 12))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Username")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
                
                TextField("username", text: $username)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 12))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
                
                SecureField("••••••••", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 12))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Confirm Password")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
                
                SecureField("••••••••", text: $confirmPassword)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 12))
            }
            
            Button(action: {
                Task {
                    await authService.register(email: email, username: username, password: password)
                }
            }) {
                if authService.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(0.8)
                } else {
                    Text("Create Account")
                        .font(.system(size: 12, weight: .semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(AppColors.accentBlue)
            .foregroundColor(.white)
            .cornerRadius(6)
            .disabled(!isFormValid || authService.isLoading)
            .opacity(isFormValid ? 1.0 : 0.5)
        }
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthService())
}
