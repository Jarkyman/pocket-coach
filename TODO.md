# PocketCoach – Roadmap & Release

## 🚀 Releasing
- [ ] Run `flutter clean` & `flutter pub get`
- [ ] Build IPA: `flutter build ipa --release --obfuscate --split-debug-info=build/ios/outputs/symbols`
- [ ] Upload to Transporter and verify "Invalid executable" error is gone
- [ ] Submit for Review on App Store
- [ ] Take Screenshots using `DEMO_MODE=true`
- [ ] Finalize store descriptions (Danish & English)

---

## 🔮 Future Projects
### 📱 Tablet & iPad Optimization
- [ ] Fix text scaling: Currently text is too small on large screens. Implement a responsive typography system.
- [ ] Layout adjustments: Use more of the screen real estate on iPads (sidebars, multi-column layouts).

### 🔔 Notifications & Engagement
- [ ] Daily Nudges: Remind users to check in with their coach.
- [ ] Interactive Notifications: Quick reply to coach messages from the lock screen.

### 🔌 App Integrations
- [ ] **Calendar**: Let coaches see your schedule to help with planning.
- [ ] **Health/Fitness**: Sync with Apple Health / Google Fit for fitness coaches.
- [ ] **Reminders/Todoist**: Export "Next Actions" directly to your favorite todo app.

### 🧠 Advanced AI Features
- [ ] Voice Input: Talk to your coach.
- [ ] Streaming responses for faster-feeling chat.
- [ ] Multiple context profiles (e.g., "Work Mode" vs "Personal Development").

---

## ✅ Completed (MVP)
- [x] Design System (Light/Dark mode)
- [x] Coach Library & Details
- [x] Personal Context Profile
- [x] OpenAI Integration (GPT-4o-mini)
- [x] RevenueCat Monetization & Paywall
- [x] Demo Mode for Screenshots
- [x] Text Selection in Chat
- [x] Coach Images & Avatars
- [x] Firebase Analytics
