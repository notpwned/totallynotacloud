# totallynotacloud

Minimalist cloud storage application for iOS and macOS built with SwiftUI.

## Features

- Dark minimalist design with white and blue buttons
- Native iOS and macOS applications built with SwiftUI
- Architecture ready for authentication and server integration
- Modular MVVM architecture
- Drag & drop support (macOS)
- File management (upload, delete, organize)
- Real-time storage statistics

## Platforms

### iOS
- Minimum iOS 16.0
- iPhone optimized
- Native iOS UI patterns
- Tab-based navigation

### macOS
- Minimum macOS 13.0
- Sidebar navigation
- Drag & drop file uploads
- Desktop-optimized UI
- Window management

## Installation

### Quick Start

1. Clone the repository
```bash
git clone https://github.com/notpwned/totallynotacloud.git
cd totallynotacloud
```

2. Run setup script
```bash
chmod +x setup-xcode-projects.sh
./setup-xcode-projects.sh
```

3. Open in Xcode

**For iOS:**
```bash
xed iOS/
```

**For macOS:**
```bash
xed macOS/
```

4. Create Xcode projects (see XCODE_SETUP.md for detailed instructions)

### Manual Setup

See [XCODE_SETUP.md](XCODE_SETUP.md) for step-by-step Xcode project setup.

## Project Structure

```
totallynotacloud/
├── iOS/
│   ├── Models/
│   │   ├── CloudFile.swift
│   │   └── User.swift
│   ├── Services/
│   │   ├── AuthService.swift
│   │   └── StorageService.swift
│   ├── App/
│   │   ├── totallynotacloudApp.swift
│   │   └── AppColors.swift
│   └── Views/
│       ├── AuthView.swift
│       ├── MainTabView.swift
│       ├── FilesView.swift
│       ├── StorageView.swift
│       └── ProfileView.swift
│
├── macOS/
│   ├── App/
│   │   ├── totallynotacloudApp.swift
│   │   └── AppColors.swift
│   └── Views/
│       ├── AuthView.swift
│       └── ContentView.swift
│
├── README.md
├── DEVELOPMENT.md
├── XCODE_SETUP.md
├── API_SPEC.md
├── ROADMAP.md
├── .gitignore
└── setup-xcode-projects.sh
```

## Technology Stack

- **SwiftUI** - Modern declarative UI framework
- **Swift Concurrency** - Async/await for asynchronous operations
- **Combine** - Reactive programming framework
- **MVVM** - Clean architecture pattern

## Architecture

### Models
- `CloudFile` - File representation with metadata
- `User` - User profile and storage quota
- `UploadProgress` - Upload progress tracking

### Services
- `AuthService` - Authentication management (mock ready for real API)
- `StorageService` - File and storage management

### Views

**iOS Views:**
- AuthView - Login/signup screen
- MainTabView - Tab navigation
- FilesView - File listing
- StorageView - Storage statistics
- ProfileView - User profile

**macOS Views:**
- AuthView - Login/signup (desktop optimized)
- ContentView - Main window with sidebar
- FilesDetailView - File list in detail pane
- StorageDetailView - Storage visualization
- ProfileDetailView - User profile details

## Features in Development

### iOS
- [x] Authentication UI (mock)
- [x] File listing
- [x] Storage visualization
- [x] Profile management
- [ ] Real API integration
- [ ] DocumentPicker for file selection
- [ ] Keychain integration
- [ ] Offline mode
- [ ] Share extension

### macOS
- [x] Authentication UI (desktop)
- [x] Sidebar navigation
- [x] File listing
- [x] Storage visualization
- [x] Drag & drop file uploads
- [ ] Real API integration
- [ ] Keyboard shortcuts
- [ ] Menu bar integration
- [ ] Save as functionality

## Building from Source

### Build iOS
```bash
xcodebuild -scheme totallynotacloud -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Build macOS
```bash
xcodebuild -scheme totallynotacloud -configuration Debug -destination 'platform=macOS'
```

## Testing

Default test credentials (mock):
- Email: `test@example.com`
- Password: `password123`

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Documentation

- [DEVELOPMENT.md](DEVELOPMENT.md) - Development guide and setup
- [XCODE_SETUP.md](XCODE_SETUP.md) - Detailed Xcode project setup
- [API_SPEC.md](API_SPEC.md) - REST API specification for backend
- [ROADMAP.md](ROADMAP.md) - Development roadmap for 2026

## Color Scheme

- **Background**: `#0D0D10` (very dark gray)
- **Surface**: `#1B1B21` (dark gray)
- **Primary Text**: `#FFFFFF` (white)
- **Secondary Text**: `#A6A6A6` (gray)
- **Accent Blue**: `#0077FF` (iOS blue)

## License

MIT - See LICENSE file for details

---

**Status**: In active development

For questions or issues, open a GitHub issue!
