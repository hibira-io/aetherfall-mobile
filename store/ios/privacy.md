# App Privacy answers (App Store Connect → App Privacy)

Apple has no public API for these answers, so they are filled in by hand in
App Store Connect. Keep this file and the console in step, and update it when
the game starts collecting something new (for example push tokens or an
analytics SDK). These are the answers entered in App Store Connect
(confirmed by Danny, 2026-11-14).

**Do you or your third-party partners collect data from this app?** Yes.

**Tracking (used to track the user across other companies' apps or sites):** No.
The app has no ads, no ad SDK and no third-party analytics SDK.

| Data type | Where it comes from | Linked to the user | Used for tracking | Purposes |
| --- | --- | --- | --- | --- |
| Contact info → Email address | Sign-in with an email code or a provider | Yes | No | App functionality |
| Identifiers → User ID | Account ID | Yes | No | App functionality |
| Purchases → Purchase history | In-app purchases, verified by our server | Yes | No | App functionality |
| User content → Gameplay content | Characters, inventory, progress | Yes | No | App functionality |
| User content → Other user content | Character names, chat messages | Yes | No | App functionality |
| User content → Customer support | Support chat and tickets | Yes | No | App functionality |
| Usage data → Product interaction | Server logs and gameplay events | Yes | No | App functionality, Analytics |
| Diagnostics → Other diagnostic data | Server logs (IP, device, errors), kept 90 days | Yes | No | App functionality |
| Location, contacts, health, financial info, browsing history, sensitive info, crash data | Not collected | | | |

Notes:
- Payment card details never reach us: Apple takes the payment.
- The privacy policy URL is https://aetherfall.hibira.io/legal/privacy/.
- If a crash reporter or push notifications are added to the app, add
  Diagnostics → Crash data or Identifiers → Device ID here and in App Store
  Connect before that build is submitted.
