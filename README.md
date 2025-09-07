# 🚀 OrbitFlash Mobile App

The **OrbitFlash Mobile App** is the cross-platform companion for the **OrbitFlash Arbitrage Engine**.  
It delivers real-time arbitrage opportunities, monitoring, and wallet connectivity in a secure, performant, and user-friendly mobile experience.

This app is built with **Flutter (Dart)** for **iOS & Android**, aligned with the backend microservices and APIs.

---

## 📖 Table of Contents
1. [Overview](#overview)
2. [Core Features](#core-features)
3. [Architecture](#architecture)
4. [Tech Stack](#tech-stack)
5. [Setup & Installation](#setup--installation)
6. [Configuration](#configuration)
7. [Project Structure](#project-structure)
8. [API Integration](#api-integration)
9. [Wallet Integration](#wallet-integration)
10. [Offline & Caching](#offline--caching)
11. [Monitoring & Logging](#monitoring--logging)
12. [Testing](#testing)
13. [Security](#security)
14. [CI/CD Pipeline](#cicd-pipeline)
15. [Contributing](#contributing)
16. [License](#license)

---

## 📌 Overview
OrbitFlash is a **high-frequency arbitrage system on Arbitrum**.  
The mobile app provides **real-time visibility, notifications, and secure wallet interactions** for traders and operators.

It acts as the **user-facing interface** to:
- Monitor arbitrage signals
- View live market metrics
- Receive push alerts
- Manage subscriptions & tasks
- Connect wallets (sign-only, no private key exposure)
- Trigger server-side "execute" requests (on-chain actions remain backend-governed)

---

## 🌟 Core Features
- **🔐 WalletConnect v2** integration for wallet login & message signing
- **📡 Real-time WebSocket Feed** for opportunities (`opportunity.new`, `opportunity.update`, `opportunity.executed`)
- **📊 Live Metrics Dashboard**: success rate, gas efficiency, slippage accuracy
- **⚡ Offline-first Caching** with retry queue (SQLite + Hive)
- **📱 Responsive UI** across iOS & Android
- **📤 Push Notifications** (FCM for Android, APNs for iOS)
- **🛡️ Secure Storage** of JWT/session tokens (Keychain / Keystore)
- **🌍 Role-based UI** (observer vs operator)
- **🎨 Smooth Animations** (Rive/Lottie + GPU-accelerated transitions)

---

## 🏗️ Architecture
The app follows **Clean Architecture** with **MVVM pattern**:

```

lib/
├── core/             # Constants, themes, utils
├── data/             # API clients, models, repositories
├── domain/           # Entities, use cases
├── presentation/     # Screens, widgets, animations
├── services/         # Wallet, push, logging, caching
├── main.dart         # App entry point

````

- **State Management**: Riverpod + StateNotifier  
- **Navigation**: GoRouter  
- **Offline Cache**: Hive + SQLite  
- **Dependency Injection**: GetIt + Riverpod  
- **Animations**: Rive + Lottie + Impeller (GPU)

---

## ⚙️ Tech Stack
- **Framework**: Flutter (Dart 3.x, Flutter 3.19+)  
- **State Management**: Riverpod  
- **Animations**: Rive, Lottie, AnimatedBuilder  
- **Database**: SQLite (drift) + Hive (key-value)  
- **Network**: Dio (REST) + WebSocket channel  
- **Wallet**: WalletConnect v2 + Viem/Ethers bindings  
- **Push Notifications**: Firebase Cloud Messaging (Android) / APNs (iOS)  
- **Error Tracking**: Sentry  
- **Analytics**: Firebase Analytics  
- **Testing**: Flutter Test, Mockito, Integration Tests  
- **CI/CD**: GitHub Actions + Fastlane + Firebase App Distribution  

---

## 🚀 Setup & Installation

### Prerequisites
- Flutter SDK ≥ 3.19  
- Dart ≥ 3.3  
- Android Studio / Xcode  
- Firebase CLI (for push notifications)  
- Access to OrbitFlash backend APIs  

### Clone the repo
```bash
git clone https://github.com/orbitflash/orbitflash-mobile.git
cd orbitflash-mobile
````

### Install dependencies

```bash
flutter pub get
```

### Configure Firebase (Push Notifications)

1. Add `google-services.json` (Android: `android/app/`)
2. Add `GoogleService-Info.plist` (iOS: `ios/Runner/`)
3. Enable FCM + APNs in Firebase Console

### Run the app

```bash
flutter run
```

---

## 🔧 Configuration

Create a `.env` file in the root:

```env
API_BASE_URL=https://api.orbitflash.xyz/api/v1
WS_BASE_URL=wss://api.orbitflash.xyz/ws
WALLETCONNECT_PROJECT_ID=your_project_id_here
SENTRY_DSN=your_sentry_dsn_here
PUSH_SERVER_API_KEY=your_push_key
```

---

## 🗂️ Project Structure

```
lib/
├── core/
│   ├── theme.dart
│   ├── constants.dart
│   └── utils.dart
├── data/
│   ├── models/
│   ├── repositories/
│   └── api_client.dart
├── domain/
│   ├── entities/
│   └── usecases/
├── presentation/
│   ├── screens/
│   ├── widgets/
│   └── animations/
├── services/
│   ├── wallet_service.dart
│   ├── push_service.dart
│   └── cache_service.dart
└── main.dart
```

---

## 🌐 API Integration

The app consumes OrbitFlash backend REST & WebSocket APIs:

### REST Endpoints

* `POST /auth/challenge` → wallet sign-in challenge
* `POST /auth/verify` → verify signature, get JWT
* `GET /opportunities` → list opportunities
* `POST /opportunities/:id/execute` → request server execution
* `GET /metrics/overview` → system metrics
* `GET /user/me` → user profile
* `POST /push/register` → register device for notifications

### WebSocket Events

* `opportunity.new`
* `opportunity.update`
* `opportunity.executed`
* `alert.system`
* `metrics.update`

---

## 🔑 Wallet Integration

* WalletConnect v2 (Flutter SDK)
* Session management via secure storage
* Supports Rainbow, MetaMask, Coinbase Wallet
* Sign-only authentication (no raw private key exposure)
* Fallback: “View-Only Mode” if no wallet available

---

## 📦 Offline & Caching

* Hive for key-value (JWT, preferences, sessions)
* SQLite (Drift) for opportunity cache & task queue
* Retry mechanism with exponential backoff
* Offline-first: users can browse cached opportunities

---

## 📊 Monitoring & Logging

* **Sentry** for error reporting
* **Logger package** for structured logs
* **Firebase Analytics** for user behavior
* Audit logs for every execution request

---

## 🧪 Testing

### Unit Tests

```bash
flutter test
```

### Integration Tests

```bash
flutter drive --target=test_driver/app.dart
```

### Coverage

```bash
flutter test --coverage
```

---

## 🔐 Security

* Secure JWT storage via Flutter Secure Storage (Keychain/Keystore)
* Certificate pinning for API calls
* Enforced HTTPS for all requests
* No secrets in repo (all via `.env`)
* Strict input validation before API calls
* Role-based UI rendering (observer vs operator)

---

## ⚡ CI/CD Pipeline

* **GitHub Actions** for CI (lint, test, build)
* **Fastlane** for deployment:

  * Beta builds → Firebase App Distribution
  * Production builds → Play Store / App Store
* Auto code signing via EAS & Fastlane Match
* `.env.example` provided for secret placeholders

---

## 🤝 Contributing

1. Fork the repo
2. Create a feature branch: `git checkout -b feature/amazing`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push: `git push origin feature/amazing`
5. Create Pull Request

---

## 📜 License

MIT License © 2025 OrbitFlash
Free to use, modify, and distribute under the terms of the license.

---

## 📹 Demo Video

A walkthrough demo (1–3 mins) is included in `/docs/demo.mp4`.

---

```

---

⚡ This is the **final one-shot `README.md` file**.  
Do you also want me to generate the **skeleton Flutter folder with placeholder Dart files** so that your devs (or Bloom.diy) get a **ready-to-extend project** aligned with this README?
```
