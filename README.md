# Forgejo Code Browser

A beautiful Flutter app for browsing Forgejo repositories and reviewing code on iOS and Android.

## Features

- **Secure Authentication**: Connect to your Forgejo instance using personal access tokens
- **Repository Browsing**: View all your repositories with search and filtering
- **File Navigation**: Browse repository file trees with intuitive navigation
- **Code Viewer**: Beautiful syntax-highlighted code viewer with:
  - Support for 30+ programming languages
  - Line numbers toggle
  - Light/dark theme toggle
  - Copy to clipboard functionality
  - Horizontal and vertical scrolling for wide code

## Screenshots

*(Screenshots would go here)*

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- iOS development environment (for iOS deployment)
- Android development environment (for Android deployment)
- A Forgejo instance with API access

### Installation

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd forgejo_browser
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Creating a Forgejo Access Token

1. Log in to your Forgejo instance
2. Navigate to **Settings** > **Applications**
3. Under **Generate New Token**, give your token a name (e.g., "Mobile Code Browser")
4. Select scopes (minimum required: `repo`)
5. Click **Generate Token**
6. Copy the token immediately (you won't be able to see it again)

## Usage

1. Launch the app
2. Enter your Forgejo server URL (e.g., `https://forgejo.example.com`)
3. Paste your personal access token
4. Tap **Connect**
5. Browse your repositories
6. Navigate through files and review code

## Supported Languages

The app provides syntax highlighting for:

- Dart, JavaScript, TypeScript
- Python, Java, Kotlin, Swift
- Go, Rust, C, C++
- Ruby, PHP, C#
- Shell scripts (Bash, Zsh)
- SQL, JSON, YAML, XML
- HTML, CSS, SCSS
- Markdown
- And more!

## Architecture

```
lib/
├── main.dart                     # App entry point
├── models/
│   └── repository.dart           # Data models
├── services/
│   └── forgejo_api.dart          # API client
└── screens/
    ├── login_screen.dart         # Authentication screen
    ├── repository_list_screen.dart  # Repository list
    ├── file_browser_screen.dart  # File tree navigation
    └── code_viewer_screen.dart   # Code viewer with syntax highlighting
```

## Dependencies

- `http` - HTTP client for API calls
- `flutter_highlight` - Syntax highlighting
- `shared_preferences` - Local storage for credentials

## Privacy & Security

- Your access token is stored locally on your device using `shared_preferences`
- All API calls use HTTPS (when your Forgejo instance supports it)
- No data is sent to third parties
- The app only requests necessary permissions

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is open source and available under the MIT License.

## Support

For issues and feature requests, please create an issue on GitHub.

## Roadmap

Potential future features:
- [ ] Offline caching
- [ ] Diff viewer for commits
- [ ] Pull request browsing
- [ ] Issue tracking
- [ ] Multiple account support
- [ ] Bookmarks/favorites
- [ ] Code search within repositories
- [ ] Dark mode persistence
- [ ] Tablet/large screen optimization

## Acknowledgments

- Built with Flutter
- Syntax highlighting powered by flutter_highlight
- Icons from Material Design
