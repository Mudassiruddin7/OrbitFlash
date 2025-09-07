OrbitFlash — Flutter Mobile App

Production-ready cross-platform (iOS & Android) mobile client for OrbitFlash — a realtime, L2-first arbitrage monitoring & operator app that integrates with OrbitFlash backend services (opportunity feed, tasks, metrics). This README explains architecture, install/build steps, auth/wallet flows, API contract, testing, CI, security, and release guidance in detail so a dev or juror can immediately run, audit, or extend the app.

Table of contents

What this app is

Key features & user journeys

Architecture & tech stack

Project structure

Environment variables & configuration

Auth & Wallet flow (challenge → sign → JWT)

Backend API contract & WebSocket events (exact)

Local development: setup & run

Mock server (for local dev & QA)

Testing: unit, integration, e2e

CI / GitHub Actions example

Production build & release

Security & hardening checklist

Monitoring, logging & observability

Acceptance checklist for QA / Jury

Troubleshooting & FAQ

Contributing & code style

License & contact

What this app is

OrbitFlash mobile is a single-screen, scrollable mobile app built in Flutter + TypeScript-style logic (Dart) that provides:

Real-time feed of arbitrage opportunities detected on Arbitrum.

Wallet connect & challenge-based authentication (WalletConnect v2).

Push + in-app alerts for subscription criteria.

Task request flow: mobile can request execution; actual on-chain flash-loan execution is performed server-side and governed (multisig/HSM).

Offline cache & queue for resilient UX when network is intermittent.

Secure credential storage and role-based UI (observer vs operator).

This README documents how to run, extend, test, and ship the app.

Key features & user journeys

Observer: Connect wallet → view live opportunities → subscribe to alerts → view historical logs.

Operator: Connect + authenticated role → request execution (POST /api/v1/opportunities/:id/execute) → watch taskId progress via WebSocket.

Admin QA: Toggle mock-mode → replay market events → verify acceptance checks and alerts.

Architecture & tech stack

Frontend (Flutter)

Language: Dart (Flutter stable)

State: flutter_riverpod for global & asynchronous state

HTTP: dio (with interceptors for JWT)

WebSocket: web_socket_channel or socket_io_client (reconnect logic)

Wallet: walletconnect_dart + web3dart for signature utilities

Secure storage: flutter_secure_storage (Keychain / Keystore)

Local DB / cache: sqflite or hive (for opportunity cache & queued actions)

Push notifications: firebase_messaging (FCM) + platform APNs setup for iOS

Animations: rive / lottie for hero visuals; use Animated* widgets for lightweight motion

Charts: fl_chart or charts_flutter for KPI widgets

Testing: flutter_test (unit), integration_test (integration/e2e), optional Detox for more heavy flows

CI: GitHub Actions (macos + ubuntu runners) to run tests, build Android, and produce artifacts

Backend (integrates with OrbitFlash services)

REST / WebSocket API contract described below. Mobile app expects those endpoints.

Project structure (recommended)
/orbitflash-flutter
├─ android/
├─ ios/
├─ lib/
│  ├─ main.dart
│  ├─ app.dart
│  ├─ widgets/
│  │  ├─ navbar.dart
│  │  ├─ hero_card.dart
│  │  └─ opportunity_card.dart
│  ├─ screens/
│  │  └─ home_screen.dart
│  ├─ providers/
│  │  ├─ auth_provider.dart
│  │  ├─ ws_provider.dart
│  │  └─ opportunities_provider.dart
│  ├─ services/
│  │  ├─ api.dart         // dio instance + interceptors
│  │  ├─ auth_service.dart
│  │  ├─ ws_service.dart
│  │  └─ push_service.dart
│  ├─ models/
│  │  └─ opportunity.dart
│  ├─ storage/
│  │  └─ local_db.dart   // sqlite/hive wrapper
│  └─ utils/
│     └─ format.dart
├─ test/
├─ integration_test/
├─ assets/
└─ README.md

Environment variables & configuration

Place runtime config in a non-committed secrets.json or use CI secrets / native config. Example .env like fields (never commit secrets):

MOBILE_APP_ENV=development
API_BASE_URL=https://api.orbitflash.example
WS_BASE_URL=wss://ws.orbitflash.example
WALLETCONNECT_PROJECT_ID=TODO
FIREBASE_SERVER_KEY=TODO            # for push registration with backend
SENTRY_DSN=TODO
PUSH_SENDER_ID=TODO                 # FCM


In code, treat these as compile-time or runtime config (use flutter_dotenv or platform environment variables injected by CI).

Auth & Wallet flow (challenge → sign → JWT) — exact steps

This is the secure, required flow your backend expects (do not bypass).

Connect wallet via WalletConnect v2

Start a WalletConnect session from the app (walletconnect_dart).

Obtain the address and chainId once the user approves.

Request challenge from server

final resp = await api.post('/api/v1/auth/challenge', data: {'address': address});
final challenge = resp.data['challenge'];    // "Sign this: login:metadata:..."
final challengeId = resp.data['challengeId'];


Sign the challenge using the connected wallet

Use WalletConnect personal_sign or EIP-712 if supported:

final signature = await walletConnector.personalSign(message: challenge, address: address);


Verify signature and retrieve JWT

final verifyResp = await api.post('/api/v1/auth/verify', data: {
  'address': address,
  'signature': signature,
  'challengeId': challengeId
});
final token = verifyResp.data['token'];
// store token in secure storage
await secureStorage.write(key: 'jwt', value: token);
dio.options.headers['Authorization'] = 'Bearer $token';


WebSocket auth

Connect to WS_BASE_URL with ?token=<JWT> or send an auth event immediately after connecting.

WebSocket must support both unauthenticated public feed and authenticated private feed.

Logout / revoke

On logout, clear SecureStorage and optionally call POST /api/v1/auth/revoke if implemented.

Important: Never store private keys or raw mnemonics in the mobile app. All signing is performed by the user's wallet app via WalletConnect.

Backend API contract (exact endpoints and expected JSON)

Use these endpoints exactly as specified. The mobile app integrates with them.

GET /api/v1/opportunities/recent?limit=50

{
  "data": [ { /* Opportunity object (see below) */ } ],
  "meta": { "limit": 50, "cursor": "..." }
}


GET /api/v1/opportunities/:id — detailed fields (historicalSlippage[], estimatedReturnUsd, route)

POST /api/v1/subscriptions
Request body:

{
  "type": "opportunity_threshold",
  "criteria": { "minProfitUsd": 50, "minConfidence": 0.8 },
  "channels": ["push", "in_app"]
}


POST /api/v1/opportunities/:id/execute
Request body:

{
  "requestedBy": "wallet:0xabc...",
  "nonce": "uuid-or-timestamp",
  "authSignature": "0x..." // optional user signature
}


Response:

{ "taskId": "task_123", "status": "queued", "message": "Execution queued" }


GET /api/v1/tasks/:taskId — get logs, txHash, status

GET /api/v1/user/me — returns roles (operator/observer)

POST /api/v1/push/register

{ "token": "<FCM/APNs token>", "wallet": "0x...", "platform": "android|ios" }


GET /api/v1/metrics/overview — KPIs (executionSuccessRate, avgExecutionTime, profitPerTx)

WebSocket event stream (exact events the app must handle)

Connect: wss://.../v1/stream?token=<JWT_OR_NULL>

Event types:

opportunity.new — payload: Opportunity

opportunity.update — payload: Opportunity (updated fields)

opportunity.executed — payload: { id, taskId, txHash, profitRealized, executedAt }

alert.system — payload: { level: "info|warning|critical", message, timestamp }

metrics.update — payload: { executionSuccessRate, avgExecutionTime, profitPerTx }

Reconnect & backfill: on reconnect, client should send last seen timestamp: { "lastSeen": "2025-09-05T12:00:00Z" } to receive missed events.

Local development: setup & run
Prerequisites

Flutter SDK (stable) installed (>= 3.x). Use flutter doctor to validate.

Android SDK or Xcode for iOS.

Node.js & yarn/npm for mock server (optional).

adb for Android emulator.

Clone & setup
git clone git@github.com:your-org/orbitflash-flutter.git
cd orbitflash-flutter
flutter pub get
# create local config file (do NOT commit)
cp config/example.secrets.json config/secrets.json
# edit config/secrets.json with your API_BASE_URL and WALLETCONNECT_PROJECT_ID

Run on device / emulator
flutter run              # choose emulator or connected device
# or run specific:
flutter run -d emulator-5554

Quick debug tips

Use flutter logs to view runtime logs.

Enable verbose Dio logging during dev (toggle via env).

Mock server (recommended for QA)

A simple Node/Express mock server that implements the REST and WebSocket contract above is required for offline QA. Provide mock/ folder with:

npm install

npm run start → serves http://localhost:3000 & ws ws://localhost:3000/stream

Admin endpoints:

POST /mock/events to emit an opportunity.new or opportunity.executed to all WS clients (helpful for testing push & UI).

Use:

cd mock
npm ci
npm run start
# emit an event:
curl -X POST http://localhost:3000/mock/events -H 'Content-Type: application/json' -d '{"type":"opportunity.new", "payload":{...}}'

Testing: unit, integration, e2e
Unit tests

Use flutter_test for widget and unit tests.

flutter test


Key test targets: auth flow (mocking WalletConnect), opportunities provider, offline queue logic.

Integration / e2e

Use integration_test package:

flutter test integration_test/app_test.dart


Test scenarios:

Connect wallet (mock)

Load feed, tap opportunity details

Subscribe and receive mock opportunity.new push

Code coverage

Use lcov export and CI reporter to fail if critical coverage < 80% for providers and services.

CI / GitHub Actions example (summary)

A CI workflow should:

Install Flutter SDK (setup-flutter action)

flutter pub get

flutter analyze

flutter test

Build Android artifact (apk) on ubuntu-latest:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test --coverage
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v3
        with:
          name: app-release-apk
          path: build/app/outputs/flutter-apk/app-release.apk


Add macOS runner to build iOS artifacts (requires macOS runner, codesigning & provisioning credentials via secrets).

Production build & release
Android
# update android/gradle.properties, keystore signing config (secure)
flutter build apk --release
# or for Play Store bundle:
flutter build appbundle --release


Upload to Google Play Console internal track.

iOS

flutter build ipa --release on macOS with correct provisioning.

Use Xcode or fastlane for uploading to TestFlight.

Notes: Keep signing keys secure (CI secret manager). Use ephemeral signing for CI where possible.

Security & hardening checklist (must satisfy before production)

 No secrets checked into repo. .gitignore includes signing keys and config/secrets.json.

 All tokens and JWT stored in flutter_secure_storage.

 Certificate pinning for API endpoints in production (library or native network layer).

 App revocation endpoint: ability to revoke JWT server-side and force-app logout.

 Strict rate-limiting on any execute button (client-side and server-side).

 Logging scrubbed: never log signed messages or raw signatures.

 Sentry integrated and configured not to log PII.

 Dependency checks and regular audits (keep packages up-to-date).

Monitoring, logging & observability

In-app basic telemetry: connect events, subscribe events, request execute attempts (send to analytics with anonymized IDs).

Crash reporting: Sentry or similar.

Health-check: on app start, call GET /api/v1/health and display backend status indicator in header.

Acceptance checklist for QA / Jury

 App builds & runs on Android and iOS emulators.

 WalletConnect session initiates and returns address (mock wallet acceptable).

 Challenge-sign-auth flow yields JWT and WebSocket auth works.

 Live feed displays opportunity.new events and persists most recent 200 items offline.

 Subscribe to alert and receive push/in-app messages on mock events.

 Request Execute returns taskId from mock server and updates status via WebSocket (opportunity.executed).

 All sensitive storage uses secure storage.

 UI respects prefers-reduced-motion (user toggles in settings).

Troubleshooting & FAQ

Q: WalletConnect doesn’t open wallet app on device

Ensure deep linking is configured for WalletConnect and the wallet app supports incoming connection. Use a test wallet like Rainbow or MetaMask mobile.

Q: WebSocket disconnects frequently

Implement exponential backoff reconnect and send lastSeen timestamp on reconnect to backfill missed events.

Q: Mock server not streaming events

Check mock server logs; ensure POST /mock/events returns 200 and emits to all connected WS clients.

Q: Push notifications not received on iOS

Confirm APNs configuration, push certificate, and that you used correct provisioning profile and entitlements.

Contributing & code style

Use flutter format and dart analyze before PR.

Tests required for new providers or services.

Branching: feature branches, PRs to develop, protected main.

Use CHANGELOG.md and Semantic Versioning.

License & contact

License: MIT (or choose org license). Include LICENSE file.

Contact / maintainers: add team email, Slack/Discord channel for DevRel and Ops.

Final notes (developer guidance)

The mobile app should never attempt to run a flash loan locally — it only requests and observes. That constraint is central to operational safety and regulatory prudence.

Include a short "Why server-side execution" note in the app About modal to reassure jurors and users.

Provide a short screencast (1–2 minutes) that demonstrates connecting a mock wallet, watching a live opportunity feed, subscribing to an alert, and requesting an execution (using mock server). This is invaluable for juries.
