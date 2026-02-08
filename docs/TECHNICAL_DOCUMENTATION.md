# Pocket Coach - Technical Documentation

## 1. Tech Stack
*   **Framework**: Flutter (Dart) - for cross-platform mobile development (iOS & Android).
*   **State Management**: Riverpod - for robust, compile-safe dependency injection and state handling.
*   **Navigation**: GoRouter - for declarative routing and deep linking support.
*   **Backend / AI**: OpenAI API (`gpt-4o-mini`) - for generating intelligent coaching responses.
*   **Local Storage**: Hive - for fast, offline-first persistence of chat history and user settings.
*   **Analytics**: Firebase Analytics - for tracking user engagement and events.
*   **Monetization**: RevenueCat - for managing in-app subscriptions and entitlements.

## 2. Architecture
The app follows a **Feature-First, Layered Architecture** to ensure detailed separation of concerns and scalability.

### Structure
*   `lib/features/`: Contains feature-specific code (e.g., `chat`, `coaches`, `monetization`).
    *   `presentation/`: Widgets, screens, and controllers (UI logic).
    *   `domain/`: Entities and business logic models (pure Dart).
    *   `data/`: Repositories and data sources (API calls, local DB).
*   `lib/shared/`: Reusable components (UI widgets, utility services).
*   `lib/app/`: App-wide configuration (routing, theme, initialization).

### Key Components
*   **PromptBuilder**: A service that dynamically constructs AI prompts by combining the User's Context, the Coach's Persona (system instructions), and the Conversation History.
*   **ChatRepository**: Manages local storage of messages using Hive, ensuring chats are available offline.
*   **SubscriptionService**: Centralizes all RevenueCat interactions (check status, purchase, restore).

## 3. RevenueCat Implementation
We use RevenueCat to abstract the complexities of Apple's StoreKit and Google Play Billing.

### Configuration
*   **Entitlements**: We defined a single entitlement identifier: `Pocket Coach Plus` (mapped to `pro` access in code).
*   **Offerings**: The `current` offering is fetched to display available packages (Monthly/Annual) dynamically.

### Key Flows
1.  **Initialization**: `Purchases.configure()` is called at app startup. The user's ID is anonymized but consistent.
2.  **Paywall**: 
    *   Triggered when a user tries to access a Pro feature (e.g., locked coach, message limit reached).
    *   Displays packages from the current Offering.
    *   Handles purchases via `Purchases.purchasePackage()`.
3.  **Entitlement Check**:
    *   `SubscriptionService` listens to the CustomerInfo stream.
    *   `subscriptionStatusProvider` (Riverpod) exposes the current state (`free` or `pro`) to the UI.
    *   UI components (like `CoachCard` or `ChatInput`) reactively update to lock/unlock features based on this state.
4.  **Restore**: A "Restore Purchases" button calls `Purchases.restorePurchases()` to sync entitlements if the user reinstalls the app.

### Code Example (Entitlement Check)
```dart
final customerInfo = await Purchases.getCustomerInfo();
final isPro = customerInfo.entitlements.all['Pocket Coach Plus']?.isActive ?? false;
```
