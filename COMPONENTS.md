# Components Documentation

Detailed description of all components in totallynotacloud.

## Models

### CloudFile

**File**: `Models/CloudFile.swift`

Represents a file or folder in cloud storage.

```swift
struct CloudFile: Identifiable, Codable {
    let id: String
    let name: String
    let size: Int64
    let mimeType: String
    let uploadedAt: Date
    let updatedAt: Date
    var isDirectory: Bool = false
    var parentId: String?
}
```

**Computed Properties:**
- `formattedSize`: Human-readable file size ("2.5 MB")
- `fileIcon`: SF Symbol name based on MIME type

**Supported MIME Types:**
- Images: `image/jpeg`, `image/png`, `image/gif`
- Documents: `application/pdf`, `text/plain`, `application/msword`
- Video: `video/mp4`, `video/quicktime`
- Archive: `application/zip`
- Folders: `application/x-folder`

### User

**File**: `Models/User.swift`

Represents authenticated user with storage quota.

```swift
struct User: Codable, Identifiable {
    let id: String
    let email: String
    let username: String
    let createdAt: Date
    var storageUsed: Int64 = 0
    var storageLimit: Int64 = 10_737_418_240 // 10 GB
}
```

**Computed Properties:**
- `storageUsagePercent`: Percentage of used storage (0-100)
- `remainingStorage`: Available storage in bytes
- `formattedStorageUsed`: Formatted used storage ("2.5 GB")
- `formattedStorageLimit`: Formatted limit ("10 GB")

### Auth Models

**LoginRequest**
```swift
struct LoginRequest: Codable {
    let email: String
    let password: String
}
```

**RegisterRequest**
```swift
struct RegisterRequest: Codable {
    let email: String
    let username: String
    let password: String
}
```

**AuthResponse**
```swift
struct AuthResponse: Codable {
    let token: String
    let user: User
}
```

### UploadProgress

**File**: `Models/CloudFile.swift`

Tracks upload progress for UI feedback.

```swift
struct UploadProgress: Identifiable {
    let id: String = UUID().uuidString
    let fileName: String
    var progress: Double = 0.0 // 0.0 to 1.0
    var isComplete: Bool = false
    var error: String?
}
```

## Services

### AuthService

**File**: `Services/AuthService.swift`

Manages user authentication and session.

**Published Properties:**
- `user: User?` - Current authenticated user
- `isAuthenticated: Bool` - Authentication status
- `isLoading: Bool` - Request in progress
- `errorMessage: String?` - Last error

**Key Methods:**

```swift
// Check saved authentication
func checkAuthStatus()

// Login (mock implementation)
func login(email: String, password: String) async

// Register (mock implementation)
func register(email: String, username: String, password: String) async

// Logout and clear session
func logout()
```

**Storage:**
- Tokens saved in `UserDefaults` (mock)
- Key: `"authToken"`

**API Base URL:**
```
https://api.totallynotacloud.local
```
(Update to real server URL in production)

### StorageService

**File**: `Services/StorageService.swift`

Manages files and file operations.

**Published Properties:**
- `files: [CloudFile]` - Current file list
- `currentFolder: CloudFile?` - Active folder
- `isLoading: Bool` - Loading state
- `uploadProgress: [UploadProgress]` - Active uploads
- `errorMessage: String?` - Last error

**Key Methods:**

```swift
// Load files from folder
func loadFiles(folderId: String? = nil) async

// Upload file to storage
func uploadFile(data: Data, name: String, mimeType: String) async

// Delete file from storage
func deleteFile(_ file: CloudFile) async

// Rename file
func renameFile(_ file: CloudFile, newName: String) async

// Create new folder
func createFolder(name: String) async
```

**Mock Data:**
- 2 folders (Documents, Photos)
- 3 files (PDF, Keynote, PNG)
- Hardcoded in `loadMockFiles()`

## iOS Views

### AuthView

**File**: `Views/AuthView.swift`

Authentication screen with login/signup forms.

**Features:**
- Toggle between login and registration
- Email and password validation
- Form submission with loading state
- Error message display

**Sub-components:**
- `LoginFormView` - Login form fields
- `RegisterFormView` - Registration form with password confirmation

### MainTabView

**File**: `Views/MainTabView.swift`

Three-tab navigation container.

**Tabs:**
1. Files (FilesView)
2. Storage (StorageView)
3. Profile (ProfileView)

**Features:**
- Tab bar appearance customization
- Color-coded tabs
- Custom tab icons

### FilesView

**File**: `Views/FilesView.swift`

File listing and management.

**Features:**
- File list with icons
- Context menu (delete)
- Create folder dialog
- Upload progress display
- Empty state

**Sub-components:**
- `FileRowView` - Individual file row

### StorageView

**File**: `Views/StorageView.swift`

Storage usage visualization and statistics.

**Features:**
- Progress bar (percentage used)
- Usage text (GB used/total)
- Statistics cards (remaining, files, folders)
- Usage tips/suggestions

**Sub-components:**
- `StatisticRow` - Single stat item
- `TipView` - Storage tip card

### ProfileView

**File**: `Views/ProfileView.swift`

User profile and account settings.

**Features:**
- User avatar and name
- Account information
- Navigation links (Settings, Security, Help)
- Sign out button with confirmation

**Sub-components:**
- `InfoCard` - Information display
- `SettingsView` - Placeholder for settings
- `SecurityView` - Placeholder for security
- `HelpView` - Placeholder for help

## macOS Views

### macOS AuthView

**File**: `macOS/Views/AuthView.swift`

Desktop-optimized authentication screen.

**Features:**
- Larger text fields
- Desktop button styling
- Native TextFieldStyle
- Optimized form layout

### ContentView

**File**: `macOS/Views/ContentView.swift`

Main window with split view layout.

**Features:**
- Sidebar navigation
- Detail pane
- Drag & drop support
- File operations context menu

**Sub-components:**
- `SidebarView` - Left sidebar
- `FilesDetailView` - Files detail pane
- `FileRowView` - File row in list
- `StorageDetailView` - Storage detail pane
- `ProfileDetailView` - Profile detail pane

### Drag & Drop Implementation

```swift
// Handle file drops
.onDrop(of: ["public.file-url"], isTargeted: $isDropping) { providers in
    for provider in providers {
        provider.loadItem(forTypeIdentifier: "public.file-url") { item, error in
            if let url = item as? URL {
                // Upload file
            }
        }
    }
    return true
}
```

**Supported File Types:**
- All files (public.file-url)
- MIME type detection for proper icons

## Color System

**File**: `App/AppColors.swift`

```swift
struct AppColors {
    // Backgrounds
    static let background = Color(red: 0.08, green: 0.08, blue: 0.10)
    static let surface = Color(red: 0.11, green: 0.11, blue: 0.13)
    static let surfaceLight = Color(red: 0.16, green: 0.16, blue: 0.18)
    
    // Text
    static let textPrimary = Color.white
    static let textSecondary = Color(white: 0.65)
    
    // Accents
    static let accentBlue = Color(red: 0.0, green: 0.48, blue: 1.0)
    static let accentWhite = Color.white
    
    // Status
    static let divider = Color(white: 0.20)
    static let success = Color(red: 0.34, green: 0.85, blue: 0.39)
    static let error = Color(red: 1.0, green: 0.23, blue: 0.19)
    static let warning = Color(red: 1.0, green: 0.59, blue: 0.0)
}
```

**Usage:**
```swift
Text("Hello")
    .foregroundColor(AppColors.textPrimary)
    .background(AppColors.surface)
```

## Entry Points

### iOS

**File**: `App/totallynotacloudApp.swift`

```swift
@main
struct totallynotacloudApp: App {
    @StateObject private var authService = AuthService()
    @StateObject private var storageService = StorageService()
    
    var body: some Scene {
        WindowGroup {
            if authService.isAuthenticated {
                MainTabView() // Authenticated state
            } else {
                AuthView() // Login state
            }
        }
    }
}
```

### macOS

**File**: `macOS/App/totallynotacloudApp.swift`

```swift
@main
struct totallynotacloudApp: App {
    @StateObject private var authService = AuthService()
    @StateObject private var storageService = StorageService()
    
    var body: some Scene {
        WindowGroup("totallynotacloud") {
            if authService.isAuthenticated {
                ContentView() // Main window
            } else {
                AuthView() // Login window
            }
        }
        .windowStyle(.hiddenTitleBar)
    }
}
```

## State Management

**Pattern**: MVVM with @ObservedObject

```swift
// In views:
@EnvironmentObject var authService: AuthService
@EnvironmentObject var storageService: StorageService

// In app:
windowGroup {
    MainView()
        .environmentObject(authService)
        .environmentObject(storageService)
}
```

## Async Operations

**Pattern**: Swift Concurrency (async/await)

```swift
// In view:
Button("Login") {
    Task {
        await authService.login(email: email, password: password)
    }
}

// In service:
func login(email: String, password: String) async {
    DispatchQueue.main.async {
        self.isLoading = true
    }
    
    // Async operation
    try? await Task.sleep(nanoseconds: 2_000_000_000)
    
    DispatchQueue.main.async {
        self.isLoading = false
    }
}
```

## Reactive Updates

**Pattern**: Combine with @Published

```swift
class AuthService: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
}
```

## Next Steps

1. Study Models for data structures
2. Review Services for business logic
3. Examine Views for UI implementation
4. Understand color system and styling
5. Replace mock methods with real API calls

See [DEVELOPMENT.md](DEVELOPMENT.md) for architecture details.
