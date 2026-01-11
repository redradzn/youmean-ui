# YouMean - UI/UX Repository

<div align="center">

**Privacy-First | Anonymous | No Data Collection | Open Source UI**

*"Unlock sacred logic-driven ancient knowledge lost to time"*

</div>

---

## 🚨 Important Notice

This repository contains **ONLY the UI/UX code** for YouMean. The backend, proprietary algorithms, and calculation engines are **NOT** included and remain private to protect intellectual property.

### What's Included (Public):
✅ Flutter UI/UX code (`lib/` folder)
✅ Platform configurations (iOS, Android, Web, Desktop)
✅ API service layer (client-side only)
✅ Design system and interface components

### What's NOT Included (Private/Offline):
🔒 Rust backend server
🔒 Proprietary calculation algorithms
🔒 Python astronomical engines
🔒 Translation/interpretation logic
🔒 Database schemas and historical data

---

## 🎯 About YouMean

YouMean is a privacy-first application that combines:
- **Science**: Astronomical calculations and probability analysis
- **Religion**: Ancient wisdom interpreted through logical frameworks
- **Spirituality**: Pattern recognition across time and space

### Core Principles:
- ✨ **Anonymous** - No user accounts required
- 🔒 **Privacy-First** - All calculations done offline
- 🚫 **No Tracking** - Zero data collection or ads
- 📖 **Transparent UI** - Open-source interface
- 🧠 **Proprietary Logic** - Protected algorithms

---

## 🏗️ Architecture

### Thin Client Design (Privacy by Architecture):

```
┌─────────────────────────────────────┐
│   FLUTTER UI (THIS REPO - PUBLIC)   │
│  - User interface                   │
│  - Form inputs                      │
│  - Results display                  │
│  - No business logic                │
└─────────────────────────────────────┘
              ⬇️ API Calls
┌─────────────────────────────────────┐
│   RUST BACKEND (PRIVATE - OFFLINE)  │
│  - Request queue system             │
│  - Database storage                 │
│  - NO calculation logic             │
└─────────────────────────────────────┘
              ⬇️ Manual Processing
┌─────────────────────────────────────┐
│ PYTHON ALGORITHMS (PRIVATE-OFFLINE) │
│  - Proprietary calculations         │
│  - Astronomical engine              │
│  - Translation/interpretation       │
│  - Pattern matching                 │
└─────────────────────────────────────┘
```

### How It Works:

1. **User submits data** → Stored as "pending" in queue
2. **User sees waiting screen** → "Come back in 24-48 hours"
3. **Creator processes offline** → Uses private algorithms on local machine
4. **Results uploaded** → Marked as "completed" in database
5. **User retrieves results** → Displays in beautiful UI

**The "brain" stays offline. The server is just a messenger.**

---

## 🚀 Getting Started (UI Development)

### Prerequisites:
- Flutter SDK 3.10.4+
- Dart SDK
- A code editor (VS Code, Android Studio)

### Installation:

```bash
# Clone this repository
git clone https://github.com/yourusername/youmean.git
cd youmean

# Install dependencies
flutter pub get

# Run on Chrome (recommended for development)
flutter run -d chrome

# Or run on your preferred platform
flutter run -d macos    # macOS
flutter run -d windows  # Windows
flutter run -d linux    # Linux
```

### Development:

```bash
# Hot reload during development
# Press 'r' in the terminal

# Format code
flutter format lib/

# Analyze code
flutter analyze
```

---

## 📁 Project Structure

```
youmean/
├── lib/
│   ├── main.dart              # Main app entry point
│   └── services/
│       └── api_service.dart   # API client (connects to backend)
├── web/                       # Web-specific files
├── android/                   # Android configuration
├── ios/                       # iOS configuration
├── macos/                     # macOS configuration
├── linux/                     # Linux configuration
├── windows/                   # Windows configuration
├── pubspec.yaml               # Dependencies
└── README.md                  # This file

# NOT INCLUDED (Protected):
# rust/                       # Backend (PRIVATE)
# *.db                        # Databases (PRIVATE)
# astro_engine.py             # Algorithms (PRIVATE)
# translation_engine.py       # Algorithms (PRIVATE)
```

---

## 🎨 UI Features

### Included in This Repo:
- ✅ Belief system selection (Science/God/Spirituality)
- ✅ Birth data input (Date, Time, Place)
- ✅ Emotional state capture
- ✅ Waiting/polling screen
- ✅ Results display ("Mind Selfie" table)
- ✅ Support tiers page
- ✅ About project page
- ✅ Responsive design (Mobile/Desktop)
- ✅ Dark mode support

---

## 🔌 API Integration

The UI connects to a local backend server (not included) via HTTP:

### Endpoints Used:
```
POST /api/submit        # Submit new request
GET  /api/poll/:id      # Poll for results
GET  /api/health        # Server health check
```

**Note**: To run the full application, you need the proprietary backend server running on `localhost:3000`. This repository only provides the UI layer.

---

## 🤝 Contributing

### UI/UX Contributions Welcome!
We welcome contributions to improve the user interface and experience:

- 🎨 Design improvements
- 🐛 Bug fixes
- 📱 Platform-specific optimizations
- ♿ Accessibility enhancements
- 🌍 Internationalization (i18n)
- 📖 Documentation improvements

### What We DON'T Accept:
- ❌ Backend or algorithm implementations
- ❌ Changes to API contracts without discussion
- ❌ Attempts to reverse-engineer the backend logic

### How to Contribute:

1. Fork this repository
2. Create a feature branch (`git checkout -b feature/amazing-ui`)
3. Commit your changes (`git commit -m 'Add amazing UI feature'`)
4. Push to the branch (`git push origin feature/amazing-ui`)
5. Open a Pull Request

---

## 📄 License

**UI/UX Code**: MIT License (Open Source)

**Backend & Algorithms**: Proprietary - All Rights Reserved

The Flutter UI code in this repository is open source under the MIT License. However, the backend server, calculation algorithms, and proprietary logic remain private and are not licensed for use, modification, or distribution.

See [LICENSE](LICENSE) for details.

---

## 🔒 Security & Privacy

### Our Commitment:
- **No telemetry** or analytics in the UI
- **No third-party tracking** scripts
- **No user accounts** or authentication required
- **Local-first** processing architecture
- **Offline calculations** protect IP and user data

### Reporting Security Issues:
If you find a security vulnerability in the UI code, please email: security@youmean.com (replace with your actual email)

---

## 📞 Contact & Support

- **Creator**: Ardet
- **Website**: [Coming Soon]
- **Issues**: [GitHub Issues](https://github.com/yourusername/youmean/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/youmean/discussions)

---

## 🙏 Acknowledgments

- Built with [Flutter](https://flutter.dev/)
- Backend powered by Rust (private)
- Astronomical calculations (proprietary)
- Ancient wisdom decoded through modern logic

---

## ⚠️ Disclaimer

YouMean provides insights based on astronomical patterns and historical correlations. Results are for entertainment and self-reflection purposes. This is not professional advice (medical, financial, or otherwise).

---

<div align="center">

**Made with 💙 by Ardet**

*Decoding ancient wisdom through modern science and logical reasoning*

</div>
