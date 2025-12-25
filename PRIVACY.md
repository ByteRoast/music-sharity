# Privacy Policy for Music Sharity

**Last updated: December 17, 2025**

## Overview

Music Sharity ("we", "our", or "the app") is committed to protecting your privacy. This Privacy Policy explains our data practices for the Music Sharity mobile and desktop application.

**TL;DR: We don't collect, store, or transmit any personal data. Period.**

## Information We Do NOT Collect

Music Sharity is designed with privacy as a core principle. We explicitly **DO NOT** collect:

- ❌ Personal information (name, email, phone number)
- ❌ User accounts or login credentials
- ❌ Music listening history or preferences
- ❌ Device information or identifiers
- ❌ Location data
- ❌ Analytics or usage statistics
- ❌ Cookies or tracking data
- ❌ IP addresses
- ❌ Any other personally identifiable information

## How the App Works

Music Sharity operates entirely on your device:

1. ✅ You paste or share a music link
2. ✅ The app converts it via the Odesli API
3. ✅ You receive the converted link
4. ✅ **No data is stored or transmitted to our servers**

We don't have servers. We don't have databases. We don't collect anything.

## Third-Party Services

Music Sharity uses the following third-party API to convert music links:

### Odesli API (song.link)
- **Purpose**: Convert music links between all supported platforms
- **Data sent**: Music URLs only (no personal data)
- **Privacy Policy**: [odesli.co/privacy](https://odesli.co/privacy)

**Important notes:**
- Odesli receives only the music links you provide
- We don't send any personal or device information
- We have no control over their data practices
- Please review their privacy policy if you have concerns

## Technical Infrastructure (Web Version Only)

### CORS Proxy for Web Browsers

Due to browser security restrictions (CORS), **the web version only** of Music Sharity uses a privacy-first serverless proxy to communicate with the Odesli API.

**Important privacy guarantees:**

- ✅ **Zero data storage**: The proxy does not store any request data
- ✅ **Zero user tracking**: No analytics, cookies, or tracking mechanisms
- ✅ **Zero IP logging**: User IP addresses are not forwarded or logged
- ✅ **Transparent relay**: The proxy simply forwards requests to Odesli API
- ✅ **Open source**: The proxy code is publicly available in our [proxy repository](https://github.com/ByteRoast/music-sharity-proxy)
- ✅ **No logs retention**: Logging is explicitly disabled in the worker configuration

**Why is this proxy needed?**

Web browsers enforce CORS (Cross-Origin Resource Sharing) policies that prevent direct API calls to external services. The proxy exists solely to bypass this browser limitation. It acts as a transparent relay with **zero data retention**.

**Technical implementation:**
- Platform: Cloudflare Workers (Edge Computing)
- Runtime: V8 Isolate (serverless, stateless)
- Network: 300+ global data centers
- Logging: Explicitly disabled (`observability.enabled = false`)
- Data retention: None (stateless execution)

**Data flow (Web version only):**
```
Your Browser → Cloudflare Worker → Odesli API → Cloudflare Worker → Your Browser
             (no logging)        (public API)      (no logging)
```

**Native apps (Android, iOS, Windows, macOS, Linux):**

Native applications communicate **directly** with the Odesli API without any proxy or intermediary, ensuring maximum privacy and zero additional infrastructure.

**Transparency:**

The proxy source code is fully open source and auditable:
- Repository: [github.com/ByteRoast/music-sharity-proxy](https://github.com/ByteRoast/music-sharity-proxy)
- Configuration: `wrangler.toml` shows `observability.enabled = false`
- Worker code: `worker.js` contains no logging or data collection logic

If you have privacy concerns about the web version, we recommend using our native applications (Android, iOS, Windows, macOS, Linux) which guarantee direct API communication with zero intermediaries.

## Data Storage

Music Sharity does **NOT** store any data:

- ✅ No conversion history
- ✅ No cached links
- ✅ No user preferences saved
- ✅ No local databases
- ✅ No API keys or secrets
- ✅ All conversions happen in real-time and are immediately discarded

## Permissions Required

### Android

Music Sharity requests the following permissions:

**Internet Access** (`android.permission.INTERNET`)
- **Purpose**: Required to communicate with the Odesli API
- **Data transmitted**: Music URLs only (no personal data)

**No other permissions are requested.**

### Windows / Desktop

No special permissions required. Standard network access for API calls.

## Children's Privacy

Music Sharity does not knowingly collect personal information from anyone, including children under 13 (or applicable age in your region).

Since we don't collect any data at all, the app is safe for all ages.

## Your Rights (GDPR Compliance)

Since Music Sharity does not collect, store, or process any personal data, the following rights don't apply (because there's no data to access, modify, or delete):

- Right to access
- Right to rectification
- Right to erasure
- Right to data portability
- Right to object

If you have any questions about data protection, please contact us.

## Open Source Transparency

Music Sharity is **open source** under the GPL v3 license. You can:

- ✅ View the complete source code: [github.com/byteroast/music-sharity](https://github.com/byteroast/music-sharity)
- ✅ Verify our privacy claims yourself
- ✅ Build the app from source
- ✅ Audit the code for any data collection

**Transparency is our priority.**

## Changes to This Privacy Policy

We may update this Privacy Policy from time to time to reflect:
- Changes in legal requirements
- App functionality updates
- User feedback

**We will notify you of changes by:**
- Updating the "Last updated" date
- Posting the new policy in the app repository
- (For significant changes) Displaying a notice in the app

**Continued use of the app after changes constitutes acceptance of the updated policy.**

## Third-Party Links

Music Sharity converts links to third-party music streaming services. When you open these links, you leave our app and are subject to the privacy policies of those services:

- [Spotify Privacy Policy](https://www.spotify.com/privacy)
- [Deezer Privacy Policy](https://www.deezer.com/legal/personal-datas)
- [Apple Music Privacy](https://www.apple.com/legal/privacy/)
- [YouTube Music Privacy](https://policies.google.com/privacy)
- [Tidal Privacy Policy](https://tidal.com/privacy)

We are not responsible for the privacy practices of these third parties.

## Data Security

Since we don't collect or store data, there is no data to secure. However:

- ✅ All API communications use HTTPS encryption
- ✅ The app contains no API keys or secrets
- ✅ The app source code is publicly auditable
- ✅ No passwords or sensitive data are handled

## International Users

Music Sharity is available worldwide. Since we don't collect data:

- ✅ No data crosses borders
- ✅ No data residency concerns
- ✅ GDPR, CCPA, and other privacy regulations are inherently satisfied

## Contact Us

If you have questions about this Privacy Policy or Music Sharity's privacy practices:

**GitHub Issues**: [github.com/byteroast/music-sharity/issues](https://github.com/byteroast/music-sharity/issues)  
**Project Repository**: [github.com/byteroast/music-sharity](https://github.com/byteroast/music-sharity)

## Legal Information

**App Name**: Music Sharity  
**Developer**: Sikelio (Byte Roast)  
**License**: GNU General Public License v3.0  
**Open Source**: Yes  
**Data Collection**: None  

---

## Summary

**Music Sharity is privacy-first:**

| Question | Answer |
|----------|--------|
| Do you collect personal data? | ❌ No |
| Do you track users? | ❌ No |
| Do you use analytics? | ❌ No |
| Do you store conversion history? | ❌ No |
| Do you have user accounts? | ❌ No |
| Do you sell data? | ❌ No (we don't have any!) |
| Do you store API keys? | ❌ No |
| Is the source code public? | ✅ Yes |
| Can I verify privacy claims? | ✅ Yes (open source) |

**Your privacy is guaranteed because we simply don't collect anything.**

---

*This privacy policy was created with transparency and user privacy as the top priorities. If you have suggestions for improvement, please open an issue on GitHub.*
