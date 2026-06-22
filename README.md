# 📦 Inventra — Inventory Management System

A modern, cross-platform Inventory Management System built with Flutter.  
Inventra is designed to help businesses efficiently manage products, sales, purchases, suppliers, and inventory analytics with a clean, scalable, and modular architecture.

---

## 🚀 Features

- 📊 Real-time dashboard with analytics
- 📦 Product management (add, update, delete, scan)
- 🧾 Sales & purchase tracking system
- 👥 Supplier management module
- 🔔 Smart notifications & low stock alerts
- 📉 Inventory monitoring system
- 📁 Offline-first support with sync system
- 🔐 Authentication system (Firebase ready)
- 📄 Reports generation & export (PDF/CSV)
- 🤖 AI-powered insights (if enabled)

---

## 🛠️ Tech Stack

- **Framework:** Flutter (Dart)
- **State Management:** Provider / Riverpod
- **Backend:** Firebase / REST API
- **Database:** SQLite / Cloud Firestore
- **Authentication:** Firebase Auth
- **Architecture:** Feature-based Clean Architecture

---

## 📁 Project Structure
lib/
├── core/ # Core utilities, constants, themes
├── features/ # Feature modules (clean architecture)
├── models/ # Data models
├── services/ # API, Firebase, sync services
├── screens/ # UI screens
├── widgets/ # Reusable UI components
└── main.dart # App entry point

---

## ⚙️ Installation & Setup

### 1️⃣ Clone the repository
```bash
git clone https://github.com/heerpatel3737/Inventra.git
cd Inventra
2️⃣ Install dependencies
flutter pub get
3️⃣ Run the app
flutter run
🔐 Environment Variables

Create a .env file in the root directory:

API_KEY=your_api_key_here
BASE_URL=your_backend_url
GROQ_API_KEY=your_groq_api_key
GCP_API_KEY=your_google_cloud_api_key

⚠️ IMPORTANT: Never commit .env to GitHub.
🔥 Firebase Setup

If using Firebase:

Place google-services.json here:

android/app/

Then configure Firebase services:

Authentication
Firestore Database
Cloud Messaging (optional)
Build APK

To generate release APK:

flutter build apk --release

Output:

build/app/outputs/flutter-apk/app-release.apk
🧠 Architecture

This project follows a scalable feature-based architecture:

Clean separation of concerns
Modular feature design
Reusable components
Service-based backend integration
🔒 Security
Sensitive files are excluded via .gitignore
API keys must never be hardcoded
.env must remain local only
Firebase rules must be secured properly
👨‍💻 Author
GitHub: https://github.com/heerpatel3737
⭐ Support

If you like this project:

⭐ Star the repository
🔄 Share it
🚀 Contribute improvements