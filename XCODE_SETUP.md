# Xcode Project Setup Guide

Since we're managing files via Git instead of committing .xcodeproj bundles, here's how to set up the Xcode projects.

## iOS Project Setup

### Create iOS Project

1. **Open Xcode**
   ```bash
   xed iOS/
   ```

2. **Create New Project**
   - Select "App" template
   - Product Name: `totallynotacloud`
   - Team ID: (leave empty or select yours)
   - Organization ID: `com.example`
   - Bundle ID: `com.example.totallynotacloud`
   - Platform: iOS
   - Interface: SwiftUI
   - Life Cycle: SwiftUI App

3. **Project Structure**
   ```
   iOS/totallynotacloud.xcodeproj/
   ├── project.pbxproj
   └── xcshareddata/
       └── xcschemes/
           └── totallynotacloud.xcscheme
   
   iOS/totallynotacloud/
   ├── App/
   │   ├── totallynotacloudApp.swift
   │   └── AppColors.swift
   ├── Models/
   │   ├── CloudFile.swift
   │   └── User.swift
   ├── Services/
   │   ├── AuthService.swift
   │   └── StorageService.swift
   └── Views/
       ├── AuthView.swift
       ├── MainTabView.swift
       ├── FilesView.swift
       ├── StorageView.swift
       └── ProfileView.swift
   ```

4. **Configure Project Settings**
   - Minimum Deployment: iOS 16.0
   - App Icons: Add from Assets
   - Launch Screen: Storyboard or SwiftUI

## macOS Project Setup

### Create macOS Project

1. **Open Xcode**
   ```bash
   xed macOS/
   ```

2. **Create New Project**
   - Select "App" template
   - Product Name: `totallynotacloud`
   - Team ID: (leave empty or select yours)
   - Organization ID: `com.example`
   - Bundle ID: `com.example.totallynotacloud.macos`
   - Platform: macOS
   - macOS Version: 13.0+
   - Interface: SwiftUI
   - Life Cycle: SwiftUI App

3. **Project Structure**
   ```
   macOS/totallynotacloud.xcodeproj/
   ├── project.pbxproj
   └── xcshareddata/
       └── xcschemes/
           └── totallynotacloud.xcscheme
   
   macOS/totallynotacloud/
   ├── App/
   │   ├── totallynotacloudApp.swift
   │   └── AppColors.swift
   └── Views/
       ├── AuthView.swift
       └── ContentView.swift
   ```

4. **Configure Project Settings**
   - Minimum Deployment: macOS 13.0
   - App Sandbox: Enabled (if distributing via App Store)
   - File Access: User Selected Files

## Shared Code Structure

### For Both iOS and macOS

Create a **Shared** folder at root level:

```
Shared/
├── Models/
│   ├── CloudFile.swift
│   └── User.swift
└── Services/
    ├── AuthService.swift
    └── StorageService.swift
```

Then:
1. Add files to both project's Build Phases → Compile Sources
2. Or use File References in Xcode
3. Link both targets to shared files

## Build Phases

### iOS Build Phases
1. Copy Bundle Resources
2. Compile Sources (ensure all .swift files included)
3. Link Binary With Libraries

### macOS Build Phases
Same as iOS, plus:
- Sign Content (if distributing)
- Create App Structure (automatic)

## Build Settings

### Both Targets
```
Swift Version: 5.9
Code Generation: Release/Debug
Optimization Level: -Onone (Debug) / -O (Release)
Debug Information Format: DWARF
```

### iOS Specific
```
Deployment Target: iOS 16.0
Supported Platforms: iphoneos
Valid Architectures: arm64
```

### macOS Specific
```
Deployment Target: macOS 13.0
Supported Platforms: macosx
Valid Architectures: arm64 x86_64
```

## Running the App

### iOS
```bash
# Select iPhone simulator
Cmd + R  # Build and Run
```

### macOS
```bash
# Select My Mac (Designed for Mac)
Cmd + R  # Build and Run
```

## Code Signing

### Development (Local)
1. Select team in project settings
2. Xcode auto-manages signing
3. Build & Run normally

### Distribution
1. Create App IDs in Apple Developer
2. Create provisioning profiles
3. Set team & signing identity
4. Archive and upload to App Store

## Troubleshooting

### Missing Files
If Xcode can't find .swift files:
1. File → Add Files to project
2. Uncheck "Copy items if needed"
3. Select "Create folder references"

### Build Errors
```bash
# Clean build folder
Cmd + Shift + K

# Clean build cache
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

### Simulator Issues
```bash
# Reset simulator
xcrun simctl erase all

# List available devices
xcrun simctl list
```

## Useful Commands

```bash
# Build from command line
xcodebuild -scheme totallynotacloud -configuration Debug

# Test
xcodebuild test -scheme totallynotacloud -destination 'platform=iOS Simulator,name=iPhone 15'

# Archive
xcodebuild -scheme totallynotacloud archive
```

## Next Steps

1. ✅ Create iOS project
2. ✅ Create macOS project
3. ✅ Add all .swift files to targets
4. ✅ Configure build settings
5. ✅ Test build and run
6. Add Unit Tests
7. Configure CI/CD (GitHub Actions)
8. Setup TestFlight distribution

## Resources

- [Apple SwiftUI Documentation](https://developer.apple.com/xcode/swiftui/)
- [Xcode Build Settings Reference](https://help.apple.com/xcode/mac/current/#/itcaec37c2a6)
- [iOS App Distribution Guide](https://developer.apple.com/ios/submit/)
- [macOS App Distribution Guide](https://developer.apple.com/macos/submit/)

---

**Note**: Don't commit .xcodeproj files to git. They're regenerated locally and can cause merge conflicts. Manage them through this guide and Xcode's UI.
