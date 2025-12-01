# 🎓 IIITNR Hub

<div align="center">
  
  ![Flutter](https://img.shields.io/badge/Flutter-3.10.1-02569B?style=for-the-badge&logo=flutter)
  ![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart)
  ![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
  ![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

  **Your Smart Student Companion for IIIT Naya Raipur**
  
  A comprehensive academic management platform designed exclusively for students of Indian Institute of Information Technology, Naya Raipur.

  [Features](#-features) • [Screenshots](#-screenshots) • [Installation](#-installation) • [Tech Stack](#-tech-stack) • [Contributing](#-contributing)

</div>

---

## 📋 Table of Contents

- [About](#-about)
- [Features](#-features)
- [Screenshots](#-screenshots)
- [Installation](#-installation)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [Usage](#-usage)
- [Contributing](#-contributing)
- [License](#-license)
- [Contact](#-contact)

---

## 🌟 About

**IIITNR Hub** is a modern, dark-themed student portal application built with Flutter. It provides a centralized platform for students to manage their academic schedules, stay updated with college events, and access important information about IIIT Naya Raipur.

The app features a sleek, GitHub-inspired dark UI with glowing effects, terminal-style cards, and a professional user experience designed for the modern student.

### Key Highlights

- 🎨 **Modern Dark Theme** - GitHub-inspired UI with glowing nebula effects
- 📅 **Branch-Specific Timetables** - Personalized schedules for CSE, DSAI, ECE, and CORE
- 🎉 **Event Management** - Never miss college fests, workshops, or seminars
- 👤 **User Authentication** - Secure login with branch selection
- 📱 **Responsive Design** - Works seamlessly on web and mobile platforms
- 🔥 **Firebase Integration** - Real-time data sync and authentication

---

## ✨ Features

### 🏠 **Overview Dashboard**
- Clean, terminal-style interface with radial gradient glow effects
- Quick access to all major modules
- Real-time student statistics
- Dynamic hover effects on interactive elements

### 📅 **Smart Timetable**
- **Branch-Specific Schedules**: Separate timetables for:
  - 💻 **CSE** (Computer Science & Engineering)
  - 📊 **DSAI** (Data Science & Artificial Intelligence)
  - ⚡ **ECE** (Electronics & Communication Engineering)
  - ⚙️ **CORE** (Mechanical Engineering)
- Color-coded classes for easy identification
- Time slots with room locations
- Weekly view (Monday - Friday)

### 🎉 **Events & Activities**
- Upcoming college events and fests
- Technical competitions and hackathons
- Industry interaction sessions
- Cultural festivals
- One-click event registration

### ℹ️ **About Section**
- Mission statement
- Student reviews and testimonials
- App features showcase
- Rating system

### 📧 **Contact Support**
- Multiple contact channels (email, phone, location)
- Interactive feedback form
- Quick links to academic departments
- Working hours information

### 🔐 **Authentication**
- Student login with email validation
- Branch selection during signup
- User profile display in header
- Persistent session management

---

## 📸 Screenshots

<div align="center">

| Home Dashboard | Timetable View |
|:---:|:---:|
| ![Dashboard](screenshots/dashboard.png) | ![Timetable](screenshots/timetable.png) |

| Events Page | Login Screen |
|:---:|:---:|
| ![Events](screenshots/events.png) | ![Login](screenshots/login.png) |

</div>

---

## 🚀 Installation

### Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.10.1 or higher) - [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Dart SDK** (3.0 or higher) - Comes with Flutter
- **Firebase Account** - [Create Firebase Project](https://console.firebase.google.com/)
- **Git** - [Install Git](https://git-scm.com/downloads)
- **VS Code** or **Android Studio** (recommended IDEs)

### Step 1: Clone the Repository

```bash
git clone https://github.com/shikharrsrivastava/IIITNR-Hub.git
cd IIITNR-Hub
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

### Step 3: Firebase Configuration

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable **Authentication** (Email/Password)
3. Enable **Cloud Firestore**
4. Enable **Firebase Storage**
5. Download configuration files:
   - For **Android**: `google-services.json` → Place in `android/app/`
   - For **iOS**: `GoogleService-Info.plist` → Place in `ios/Runner/`
   - For **Web**: Copy Firebase config to `lib/firebase_options.dart`

### Step 4: Run the Application

#### For Web
```bash
flutter run -d chrome
```

#### For Mobile (Android/iOS)
```bash
flutter run
```

#### For Production Build
```bash
# Web
flutter build web --release

# Android APK
flutter build apk --release

# iOS
flutter build ios --release
```

---

## 🛠️ Tech Stack

### Frontend
- **Flutter** - UI framework for cross-platform development
- **Material Design 3** - Modern UI components
- **Dart** - Programming language

### Backend & Services
- **Firebase Authentication** - User authentication
- **Cloud Firestore** - Real-time database
- **Firebase Storage** - File storage for user profiles

### Packages Used

| Package | Version | Purpose |
|---------|---------|---------|
| `firebase_core` | ^2.32.0 | Firebase initialization |
| `firebase_auth` | ^4.19.1 | User authentication |
| `cloud_firestore` | ^4.17.4 | Database operations |
| `firebase_storage` | ^11.7.7 | File storage |
| `image_picker` | ^1.2.1 | Profile image selection |
| `image_cropper` | ^11.0.0 | Image editing |
| `url_launcher` | ^6.2.5 | Open external links |
| `intl` | ^0.20.2 | Date/time formatting |
| `http` | ^1.1.0 | API requests |
| `flutter_markdown` | ^0.6.14 | Markdown rendering |

---

## 📂 Project Structure

```
iiitnr_planner/
├── lib/
│   ├── main.dart                      # App entry point
│   ├── firebase_options.dart          # Firebase configuration
│   └── screens/
│       ├── login_screen.dart          # Authentication UI
│       ├── timetable_screen.dart      # Branch timetables
│       ├── events_screen.dart         # Events listing
│       ├── assignments_screen.dart    # Assignment tracker
│       ├── announcements_screen.dart  # College announcements
│       ├── profile_screen.dart        # User profile
│       └── chatbot_screen.dart        # AI assistant
├── android/                           # Android-specific files
├── ios/                               # iOS-specific files
├── web/                               # Web-specific files
├── assets/
│   └── images/
│       └── logo.png                   # App logo
├── pubspec.yaml                       # Dependencies
├── README.md                          # This file
└── firebase.json                      # Firebase hosting config
```

---

## 💻 Usage

### For Students

1. **Launch the App**
   - Open IIITNR Hub on your device or browser

2. **Login**
   - Click "Sign In" in the top navigation
   - Enter your IIIT NR email
   - Select your branch (CSE/DSAI/ECE/CORE)
   - Click "Login"

3. **View Timetable**
   - Navigate to "Timetable" from the sidebar
   - Your branch-specific schedule will be displayed
   - Switch between branches if needed

4. **Check Events**
   - Click "Events" in the sidebar
   - View upcoming college events
   - Register for events with one click

5. **Get Support**
   - Navigate to "Contact" section
   - Fill out the feedback form or use contact details

### For Developers

```bash
# Run in debug mode
flutter run

# Run with hot reload
# Press 'r' in terminal to hot reload
# Press 'R' to hot restart

# Check for issues
flutter doctor

# Format code
flutter format .

# Run tests
flutter test

# Analyze code
flutter analyze
```

---

## 🤝 Contributing

We welcome contributions from the IIIT NR community! Here's how you can help:

### Reporting Bugs

1. Check if the bug is already reported in [Issues](https://github.com/shikharrsrivastava/IIITNR-Hub/issues)
2. If not, create a new issue with:
   - Clear title and description
   - Steps to reproduce
   - Expected vs actual behavior
   - Screenshots if applicable

### Suggesting Features

1. Open a new issue with the `enhancement` label
2. Describe the feature and its benefits
3. Add mockups or examples if possible

### Pull Requests

1. **Fork** the repository
2. **Create** a new branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make** your changes and commit:
   ```bash
   git commit -m "Add: your feature description"
   ```
4. **Push** to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```
5. **Open** a Pull Request with a clear description

### Code Style Guidelines

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused
- Format code with `flutter format`

---

## 📜 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2025 Shikhar Srivastava

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software...
```

---

## 📞 Contact

### Project Maintainer
**Shikhar Srivastava**
- GitHub: [@shikharrsrivastava](https://github.com/shikharrsrivastava)
- Email: [shikharsrivastava@iiitnr.edu.in](mailto:shikharsrivastava@iiitnr.edu.in)

### IIIT Naya Raipur
- **Website**: [www.iiitnr.ac.in](https://www.iiitnr.ac.in)
- **Email**: support@iiitnr.edu.in
- **Phone**: +91-7718-287-001
- **Address**: IIIT Naya Raipur, Chhattisgarh, India

### Support Channels
- 🐛 **Bug Reports**: [GitHub Issues](https://github.com/shikharrsrivastava/IIITNR-Hub/issues)
- 💡 **Feature Requests**: [GitHub Discussions](https://github.com/shikharrsrivastava/IIITNR-Hub/discussions)
- 📧 **General Inquiries**: tech@iiitnr.edu.in

---

## 🙏 Acknowledgments

- **IIIT Naya Raipur** - For the inspiration and support
- **Flutter Team** - For the amazing framework
- **Firebase** - For backend services
- **GitHub** - For the UI inspiration
- **All Contributors** - For making this project better

---

## 🗺️ Roadmap

### Version 1.1 (Planned)
- [ ] Assignment submission portal
- [ ] Grade tracking system
- [ ] Push notifications
- [ ] Dark/Light theme toggle
- [ ] Offline mode support

### Version 1.2 (Future)
- [ ] AI-powered chatbot
- [ ] Study group finder
- [ ] Resource sharing platform
- [ ] Alumni network
- [ ] Job placement portal

---

## 📊 Project Stats

![GitHub stars](https://img.shields.io/github/stars/shikharrsrivastava/IIITNR-Hub?style=social)
![GitHub forks](https://img.shields.io/github/forks/shikharrsrivastava/IIITNR-Hub?style=social)
![GitHub watchers](https://img.shields.io/github/watchers/shikharrsrivastava/IIITNR-Hub?style=social)
![GitHub contributors](https://img.shields.io/github/contributors/shikharrsrivastava/IIITNR-Hub)
![GitHub issues](https://img.shields.io/github/issues/shikharrsrivastava/IIITNR-Hub)
![GitHub pull requests](https://img.shields.io/github/issues-pr/shikharrsrivastava/IIITNR-Hub)

---

<div align="center">

### ⭐ Star this repository if you find it helpful!

**Made with ❤️ for IIIT Naya Raipur Students**

[Back to Top](#-iiitnr-hub)

</div>
