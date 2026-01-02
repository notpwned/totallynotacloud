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
                        .font(.system(size: 48))
                        .foregroundColor(AppColors.accentBlue)
                    
                    Text("totallynotacloud")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Облачное хранилище нового поколения")
                        .font(.system(size: 14, weight: .regular))
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
                    Text(isLogin ? "Нет аккаунта? " : "Уже есть аккаунт? ")
                        .foregroundColor(AppColors.textSecondary)
                    
                    Button(isLogin ? "Зарегистрироваться" : "Войти") {
                        withAnimation {
                            isLogin.toggle()
                        }
                    }
                    .foregroundColor(AppColors.accentBlue)
                    .font(.system(size: 14, weight: .semibold))
                }
                .padding(.bottom, 30)
            }
            .padding(.horizontal, 20)
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
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
                
                TextField("name@example.com", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(AppColors.surface)
                    .cornerRadius(8)
                    .foregroundColor(AppColors.textPrimary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Пароль")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
                
                SecureField("••••••••", text: $password)
                    .textContentType(.password)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(AppColors.surface)
                    .cornerRadius(8)
                    .foregroundColor(AppColors.textPrimary)
            }
            
            Button(action: {
                Task {
                    await authService.login(email: email, password: password)
                }
            }) {
                if authService.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                } else {
                    Text("Войти")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(AppColors.accentBlue)
            .foregroundColor(AppColors.accentWhite)
            .cornerRadius(8)
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
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
                
                TextField("name@example.com", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(AppColors.surface)
                    .cornerRadius(8)
                    .foregroundColor(AppColors.textPrimary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Имя пользователя")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
                
                TextField("username", text: $username)
                    .autocapitalization(.none)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(AppColors.surface)
                    .cornerRadius(8)
                    .foregroundColor(AppColors.textPrimary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Пароль")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
                
                SecureField("Минимум 6 символов", text: $password)
                    .textContentType(.newPassword)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(AppColors.surface)
                    .cornerRadius(8)
                    .foregroundColor(AppColors.textPrimary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Подтверждение пароля")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
                
                SecureField("Повторите пароль", text: $confirmPassword)
                    .textContentType(.newPassword)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(AppColors.surface)
                    .cornerRadius(8)
                    .foregroundColor(AppColors.textPrimary)
            }
            
            Button(action: {
                Task {
                    await authService.register(email: email, username: username, password: password)
                }
            }) {
                if authService.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                } else {
                    Text("Зарегистрироваться")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(AppColors.accentBlue)
            .foregroundColor(AppColors.accentWhite)
            .cornerRadius(8)
            .disabled(!isFormValid || authService.isLoading)
            .opacity(isFormValid ? 1.0 : 0.5)
        }
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthService())
}
