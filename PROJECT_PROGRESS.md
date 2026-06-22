# Project Progress - Common Inventory Management Software

## Completed Features
- **Security & Env Setup**: Created `.env` and `.env.example` configurations using `flutter_dotenv`.
- **Firebase Core & Auth**:
  - Setup Firebase options loading dynamically from environment variables.
  - Implemented reactive `AuthGate` routing layer.
  - Completed real email/password login, registration, password reset, and Google Sign-In using Riverpod and Firebase Auth.
  - Integrated live Auth state in sidebar and custom drawer, removing hardcoded names ("Aanya Kapoor", "Riya Sharma") and role placeholders.
- **Database Schema & Offline Queue**:
  - Extended local native SQLite and Web SharedPreferences databases to support `sync_queue` caching.
  - Linked all data repositories (Categories, Suppliers, Products, Sales, Purchases, Settings, Notifications) to SQLite database helper classes.
- **Offline Sync & Real-time Firestore Sync**:
  - Implemented background `SyncService` listening to `Connectivity` status.
  - Integrated CRUD operation sync listeners for `products`, `categories`, and `suppliers` so offline writes queue up and auto-upload upon connection restoration.
  - Added duplicate product prevention logic during API import and unified category auto-creation.
- **REST API Integration**:
  - Integrated public products API from `fakestoreapi.com` inside `ApiService`.
  - Added "Import API Products" action to the Products catalogue screen with loading states and success notifications.
  - Enhanced API service to prevent duplicate product records, save imported items directly to SQLite and Firestore, and auto-create and link category entities dynamically.
- **Notifications**:
  - Implemented `NotificationService` supporting Firebase Cloud Messaging (FCM) and `flutter_local_notifications` fallbacks.
  - Added low stock detection checks that trigger system-level alerts when inventory drops below 5 units.
- **Analytics Dashboard (fl_chart)**:
  - Refactored trend panel to render a premium curved line chart representing monthly sales using `fl_chart`.
- **AI Analytics Service**:
  - Created `AIService` supporting Gemini API (with OpenAI fallback) to run cognitive audits on the product catalog.
  - Added `AnalyticsAiPanel` to the interface letting users select and generate Health Audits, 30d Demand forecasts, and Reorder plans.
- **PDF Report Export**:
  - Developed a robust, cross-platform PDF generation system that produces styled documents for Inventory Valuations, Sales logs, and Reorder lists.
- **Dynamic Dashboard & Repository-driven Data Sources**:
  - Removed all hardcoded values in "Stock Overview" and "Recent Activity".
  - Connected dashboard metrics and graphs directly to SQLite data sources, enabling real-time auto-refresh on changes.
- **Categories Module**:
  - Removed all hardcoded product counts. Category product counts are calculated dynamically from actual product database records.
- **UI Settings Polish**:
  - Fixed dark mode visibility and contrast issues for dropdowns, settings tiles, and custom dialogs.

## In Progress
- **Verification & Deployment Prep**: Validating the integrated features against native Android, iOS, and Web environments.
- **Code Audit**: Auditing remaining hardcoded demo/mock data sources across other screens (like suppliers, sales, and purchases) and linking them to repository-driven providers.

## Pending
- None.

## Issues / Fixes Applied
- **Appearance Dropdown dark mode contrast**: Updated the dropdown widget style to ensure perfect contrast and visibility of selected items and text in dark theme.
- **Hardcoded name in Sidebar/Drawer**: Subscribed both widgets to `authStateProvider` to show the correct authenticated profile info.
- **Dynamic Category Count**: Replaced category total product count with a computed state from categories + products provider.

## Next Steps

### 1. Local Environment Key Configuration
- Ensure your local `.env` file is created in the project root directory and populated with active service credentials:
  ```env
  FIREBASE_API_KEY=your_firebase_key
  FIREBASE_APP_ID=your_firebase_app_id
  FIREBASE_MESSAGING_SENDER_ID=your_sender_id
  FIREBASE_PROJECT_ID=your_project_id
  GEMINI_API_KEY=your_gemini_key
  OPENAI_API_KEY=your_openai_key
  ```

### 2. Configure Firebase Messaging (FCM) Credentials
- **Android**: Place `google-services.json` in the `android/app/` directory.
- **iOS**: Place `GoogleService-Info.plist` in the `ios/Runner/` directory.
- Verify push permissions are properly requested during application launch in `NotificationService`.

### 3. Production Bundling & Testing
- Compile and test production builds on target platforms:
  ```bash
  # Web compilation
  flutter build web --release

  # Android compilation
  flutter build apk --release

  # iOS compilation (Requires macOS)
  flutter build ipa --release
  ```

### 4. Conflict Resolution Auditing
- Review synchronization behaviors under high latency network environments.
- Verify Firestore Security Rules are set to restrict read/write access to authenticated owners.
