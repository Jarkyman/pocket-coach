# Free vs Pro gating (meget konkret)

**Entitlement:** `pro`

### Free users

* ✅ 3 coaches (fx: Productivity, Deep Work, Systems)
* ✅ 1 context profile
* ✅ Chat med daily cap (fx 10 messages/day)
* ❌ Create Coach
* ❌ Share/Import
* ❌ Premium coaches

### Pro users

* ✅ Alt unlocked
* ✅ Unlimited messages
* ✅ Create Coach
* ✅ Share/Import
* ✅ All coaches
* ✅ Multiple contexts (nice-to-have)

### Paywall triggers (judge-proof)

1. Tryk på **Create Coach** → paywall
2. Tryk på **Share/Import** → paywall
3. Når message cap rammes → paywall sheet


# RevenueCat setup (det du skal oprette)

### Products

* `pocketcoach_pro_monthly`
* `pocketcoach_pro_yearly`

### Entitlement

* `pro`

### Offering

* `default`

App-side:

* `Purchases.getOfferings()`
* `purchasePackage()`
* `restorePurchases()`
* `CustomerInfo.entitlements.active.containsKey("pro")`
