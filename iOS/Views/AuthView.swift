import SwiftUI

struct AuthView: View {
    @StateObject private var viewModel = AccessKeyViewModel()
    @State private var showKeyModal = false
    @State private var showImportSheet = false
    @State private var importKeyId = ""
    @State private var importPrivateKey = ""
    @Binding var isAuthenticated: Bool
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 32) {
                VStack(spacing: 12) {
                    Text("totallynotacloud").font(.system(size: 28, weight: .bold)).foregroundColor(AppColors.textPrimary)
                    Text("Private. Encrypted. Yours.").font(.system(size: 13, weight: .regular)).foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                VStack(spacing: 16) {
                    Button(action: { Task { await viewModel.generateAccessKey(); showKeyModal = true } }) {
                        HStack {
                            Image(systemName: "key.fill").font(.system(size: 16))
                            Text("Generate Access Key")
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(AppColors.accent)
                        .foregroundColor(AppColors.background)
                        .font(.system(size: 14, weight: .semibold))
                        .cornerRadius(8)
                    }
                    
                    Button(action: { showImportSheet = true }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down").font(.system(size: 16))
                            Text("Import Access Key")
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(AppColors.surfaceLight)
                        .foregroundColor(AppColors.textPrimary)
                        .font(.system(size: 14, weight: .semibold))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                VStack(spacing: 8) {
                    Text("Your privacy is guaranteed.").font(.system(size: 12, weight: .regular)).foregroundColor(AppColors.textTertiary)
                    Text("No accounts. No tracking. No data stored.").font(.system(size: 12, weight: .regular)).foregroundColor(AppColors.textTertiary)
                }
            }
            .padding(.vertical, 48)
        }
        .sheet(isPresented: $showKeyModal) {
            if let key = viewModel.generatedKey {
                VStack(spacing: 16) {
                    HStack {
                        Text("Your Access Key").font(.system(size: 18, weight: .semibold)).foregroundColor(AppColors.textPrimary)
                        Spacer()
                        Button(action: { showKeyModal = false }) {
                            Image(systemName: "xmark.circle.fill").font(.system(size: 20)).foregroundColor(AppColors.textTertiary)
                        }
                    }
                    .padding(16)
                    
                    ScrollView {
                        VStack(spacing: 16) {
                            VStack(spacing: 12) {
                                Text("Key ID:").font(.system(size: 12, weight: .semibold)).foregroundColor(AppColors.textSecondary).frame(maxWidth: .infinity, alignment: .leading)
                                Text(key.keyId).font(.system(size: 11, weight: .regular, design: .monospaced)).foregroundColor(AppColors.textPrimary).frame(maxWidth: .infinity, alignment: .leading).padding(8).background(AppColors.surface).cornerRadius(6)
                                
                                Button(action: { UIPasteboard.general.string = key.keyId }) {
                                    HStack {
                                        Image(systemName: "doc.on.doc").font(.system(size: 12))
                                        Text("Copy")
                                    }
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(AppColors.accent)
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            
                            VStack(spacing: 12) {
                                Text("Private Key (save securely):").font(.system(size: 12, weight: .semibold)).foregroundColor(AppColors.textSecondary).frame(maxWidth: .infinity, alignment: .leading)
                                Text(key.privateKey).font(.system(size: 10, weight: .regular, design: .monospaced)).foregroundColor(AppColors.textPrimary).lineLimit(4).frame(maxWidth: .infinity, alignment: .leading).padding(8).background(AppColors.surface).cornerRadius(6)
                                
                                Button(action: { UIPasteboard.general.string = key.privateKey }) {
                                    HStack {
                                        Image(systemName: "doc.on.doc").font(.system(size: 12))
                                        Text("Copy")
                                    }
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(AppColors.accent)
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                        .padding(16)
                    }
                    .frame(maxHeight: .infinity)
                    
                    Button(action: {
                        Task {
                            await viewModel.confirmAccessKey()
                            DispatchQueue.main.async {
                                isAuthenticated = true
                                showKeyModal = false
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill").font(.system(size: 16))
                            Text("Continue")
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(AppColors.accent)
                        .foregroundColor(AppColors.background)
                        .font(.system(size: 14, weight: .semibold))
                        .cornerRadius(8)
                    }
                    .padding(16)
                }
                .background(AppColors.background)
                .presentationDetents([.height(500)])
                .presentationCornerRadius(16)
            }
        }
        .sheet(isPresented: $showImportSheet) {
            VStack(spacing: 16) {
                HStack {
                    Text("Import Access Key").font(.system(size: 18, weight: .semibold)).foregroundColor(AppColors.textPrimary)
                    Spacer()
                    Button(action: { showImportSheet = false }) {
                        Image(systemName: "xmark.circle.fill").font(.system(size: 20)).foregroundColor(AppColors.textTertiary)
                    }
                }
                .padding(16)
                
                ScrollView {
                    VStack(spacing: 16) {
                        VStack(spacing: 12) {
                            Text("Key ID:").font(.system(size: 12, weight: .semibold)).foregroundColor(AppColors.textSecondary).frame(maxWidth: .infinity, alignment: .leading)
                            TextField("Paste your Key ID", text: $importKeyId)
                                .font(.system(size: 14, weight: .regular, design: .monospaced))
                                .padding(12)
                                .background(AppColors.surface)
                                .cornerRadius(6)
                        }
                        
                        VStack(spacing: 12) {
                            Text("Private Key:").font(.system(size: 12, weight: .semibold)).foregroundColor(AppColors.textSecondary).frame(maxWidth: .infinity, alignment: .leading)
                            TextEditor(text: $importPrivateKey)
                                .font(.system(size: 12, weight: .regular, design: .monospaced))
                                .padding(12)
                                .background(AppColors.surface)
                                .cornerRadius(6)
                                .frame(height: 120)
                        }
                    }
                    .padding(16)
                }
                .frame(maxHeight: .infinity)
                
                Button(action: {
                    Task {
                        await viewModel.importAccessKey(keyId: importKeyId, privateKey: importPrivateKey)
                        if viewModel.errorMessage == nil {
                            DispatchQueue.main.async {
                                isAuthenticated = true
                                showImportSheet = false
                            }
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill").font(.system(size: 16))
                        Text("Import")
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(AppColors.accent)
                    .foregroundColor(AppColors.background)
                    .font(.system(size: 14, weight: .semibold))
                    .cornerRadius(8)
                }
                .padding(16)
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(AppColors.error)
                        .padding(.horizontal, 16)
                }
            }
            .background(AppColors.background)
            .presentationDetents([.height(500)])
            .presentationCornerRadius(16)
        }
    }
}

class AccessKeyViewModel: ObservableObject {
    @Published var generatedKey: AccessKey?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let storageService = StorageService()
    private let keychainService = KeychainService.shared
    
    func generateAccessKey() async {
        DispatchQueue.main.async { self.isLoading = true }
        
        do {
            let key = try await storageService.generateNewAccessKey()
            DispatchQueue.main.async {
                self.generatedKey = key
                self.isLoading = false
                self.errorMessage = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to generate key: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func confirmAccessKey() async {
        guard let key = generatedKey else { return }
        
        do {
            try keychainService.saveAccessKey(key)
            storageService.setCurrentAccessKey(key)
            DispatchQueue.main.async {
                self.errorMessage = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to save key: \(error.localizedDescription)"
            }
        }
    }
    
    func importAccessKey(keyId: String, privateKey: String) async {
        guard !keyId.isEmpty, !privateKey.isEmpty else {
            DispatchQueue.main.async {
                self.errorMessage = "Key ID and Private Key are required"
            }
            return
        }
        
        do {
            let key = AccessKey(
                keyId: keyId,
                publicKey: "",
                privateKey: privateKey,
                createdAt: Date(),
                permissions: ["read", "write", "delete"]
            )
            
            try keychainService.saveAccessKey(key)
            storageService.setCurrentAccessKey(key)
            
            DispatchQueue.main.async {
                self.generatedKey = key
                self.errorMessage = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to import key: \(error.localizedDescription)"
            }
        }
    }
}
