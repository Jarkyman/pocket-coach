# Production Release Checklist – PocketCoach

Follow these steps to generate production builds for the App Store and Google Play Store.

> [!IMPORTANT]
> For a full step-by-step walkthrough of store setup, certificates, and RevenueCat connection, see the [Comprehensive Production Guide](PRODUCTION_GUIDE.md).

## 1. Secrets & Environment
- [ ] Update `.env` with **Production** API keys:
  - `OPENAI_API_KEY`: Official production key (not trial/dev).
  - `REVENUECAT_IOS_API_KEY`: RevenueCat **Live** App Store key.
  - `REVENUECAT_ANDROID_API_KEY`: RevenueCat **Live** Play Store key.

## 2. Android Release (Google Play)
### Signing Configuration
- [ ] Ensure you have a `key.properties` file in `android/` (ignored by git).
- [ ] Verify `android/app/build.gradle.kts` uses the `release` signing config (currently uses debug for convenience).

### Generate App Bundle (.aab)
Run the following command:
```bash
flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols
```
- Upload the resulting `.aab` file from `build/app/outputs/bundle/release/` to the Google Play Console.

## 3. iOS Release (Apple App Store)
### Signing & Certificates
- [ ] Open `ios/Runner.xcworkspace` in Xcode.
- [ ] Under **Signing & Capabilities**, ensure a production Team/Profile is selected.

### Generate Archive
Run the following command:
```bash
flutter build ipa --release --obfuscate --split-debug-info=build/ios/outputs/symbols
```
- Open the generated Xcode Archive and use the **Distribute App** flow in Xcode to upload to TestFlight/App Store Connect.

## 4. Final Sanity Checks
- [ ] **Purchases**: Verify that the paywall loads (even if it's sandbox mode).
- [ ] **Analytics**: Confirm that basic events are showing up in the Firebase DebugView.
- [ ] **Legal**: Ensure Privacy Policy and TOS URLs (if required) point to your hosted versions or are included in the metadata.

## 5. Store Metadata
- [ ] Prepare 6.5" and 5.5" iPhone screenshots.
- [ ] Prepare Android phone screenshots (and tablet if supported).
- [ ] Write compelling app descriptions and keywords.
