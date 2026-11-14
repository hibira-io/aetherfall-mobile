# App Privacy answers (App Store Connect → App Privacy)

Apple has no public API for these answers, so they are filled in by hand in
App Store Connect. Keep this file and the console in step, and update it when
the game starts collecting something new (for example chat, analytics or push
tokens). Proposed answers, waiting for Danny's confirmation:

**Do you or your third-party partners collect data from this app?** Yes.

**Tracking (used to track the user across other companies' apps or sites):** No.
The app has no ads, no ad SDK and no analytics SDK.

| Data type | Collected | Linked to the user | Used for tracking | Purposes |
| --- | --- | --- | --- | --- |
| Contact info → Email address | Yes (sign-in with email code or a provider) | Yes | No | App functionality |
| Identifiers → User ID (account ID) | Yes | Yes | No | App functionality |
| Purchases → Purchase history (in-app purchases, verified by our server) | Yes | Yes | No | App functionality |
| User content → Other user content (character names; chat messages once chat ships) | Yes | Yes | No | App functionality |
| Usage data, diagnostics, location, contacts, health, financial info, browsing history, sensitive info | No | | | |

Notes:
- Payment card details never reach us: Apple takes the payment.
- The privacy policy URL is https://aetherfall.hibira.io/legal/privacy/.
- When GA4 analytics (pixel-realm analytics consent) reaches the app build,
  add Usage data → Product interaction (Analytics, not linked, no tracking).
