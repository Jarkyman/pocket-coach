# PocketCoach Production Guide 🚀

This guide contains every step required to take PocketCoach from development to the App Store and Google Play Store.

---

## 🏗️ Phase 1: Identity & Credentials

### 1.1 Project Identifiers
Ensure your store records match these exact identifiers:
- **iOS Bundle ID**: `com.hartvigsolutions.pocketCoach`
- **Android Application ID**: `com.hartvigsolutions.pocket_coach`

### 1.2 Android Signing Key
You must have a release keystore to upload to Google Play.
1. Run this command:
   ```bash
   keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias pocketcoach
   ```
2. Create `android/key.properties` (never commit this) with:
   ```ini
   storePassword=[YOUR_PASSWORD]
   keyPassword=[YOUR_PASSWORD]
   keyAlias=pocketcoach
   storeFile=upload-keystore.jks
   ```

---

## 🍏 Phase 2: Apple App Store (iOS)

### 2.1 Developer Portal Setup
1. Go to [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/identifiers/list).
2. **Identifier**: Create a new App ID with Bundle ID `com.hartvigsolutions.pocketCoach`. Enable "In-App Purchase".
3. **Provisioning Profile**: Create a "Distribution" profile for this App ID.

### 2.2 App Store Connect
1. Create a "New App" with the name **PocketCoach**.
2. **Primary Language**: English (or Danish, your choice).
3. **SKU**: `pocketcoach_v1`.

### 2.3 RevenueCat Connectivity (StoreKit 2)
Apple and RevenueCat now recommend using an **In-App Purchase Key** instead of the old Shared Secret.

1. Go to [App Store Connect > Users and Access](https://appstoreconnect.apple.com/access/integrations/api).
2. Select the **Integrations** tab and then **In-App Purchase**.
3. Click the **+** button to generate a new key. Name it "RevenueCat".
4. Download the `.p8` file (⚠️ You can only download this once! Keep it safe).
5. In RevenueCat: Go to **Project Settings > Apps > [Your iOS App]**.
6. Upload the `.p8` file and enter the Key ID and Issuer ID (found on the same page in App Store Connect).

---

## 🤖 Phase 3: Google Play Console (Android)

### 3.1 Create App
1. Create a new App in [Google Play Console](https://play.google.com/console).
2. Set as "App" (not Game) and "Free" (Monetization is via IAP).

### 3.2 Service Account (For RevenueCat)
RevenueCat needs permission to talk to Google to verify receipts.
1. Follow the [RevenueCat Google Play Setup Guide](https://www.revenuecat.com/docs/google-play-store-configuration-guide).
2. You will generate a **JSON Key File**.
3. Upload this JSON to RevenueCat under **Project Settings > Apps > [Your Android App]**.

---

## 💳 Phase 4: Monetization (RevenueCat)

### 4.1 Products & Offerings
1. **Entitlement**: Create one called `Pocket Coach Plus`.
2. **Products**: Create products in App Store/Play Store (e.g., `pc_monthly_99`).
3. **Add to RevenueCat**: Add these store product IDs to your RevenueCat dashboard and attach them to the `Pocket Coach Plus` entitlement.

---

## 🚀 Phase 5: Build & Submit

### 5.1 Environment Check
Update `.env` with **Production Keys**:
- `REVENUECAT_IOS_API_KEY`: Production key from dashboard.
- `REVENUECAT_ANDROID_API_KEY`: Production key from dashboard.
- `OPENAI_API_KEY`: Your paid production key.

### 5.2 Build Commands
**Android**:
```bash
flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols
```
**iOS**:
```bash
flutter build ipa --release --obfuscate --split-debug-info=build/ios/outputs/symbols
```

---

## 📸 Phase 6: Store Assets
You will need:
- **Icon**: 1024x1024px.
- **iPhone Screenshots**: 6.5" (iPhone 15/14/13 Pro Max) and 5.5" (iPhone 8 Plus).
- **Android Screenshots**: At least 2 phone screenshots.
- **Privacy Policy URL**: Link to your hosted privacy policy.
