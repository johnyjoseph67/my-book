Google Sheets Integration Setup Guide
Step 1 — Create a Google Cloud Project
Go to https://console.cloud.google.com
Click "New Project" → name it "Expense Tracker"
Select your new project
Step 2 — Enable APIs
In your Google Cloud project:
Go to APIs & Services → Library
Search and enable: Google Sheets API
Search and enable: Google Drive API
Step 3 — Create OAuth 2.0 Credentials
Go to APIs & Services → Credentials
Click Create Credentials → OAuth client ID
Application type: Android
Package name: `com.yourname.expense\_tracker`
SHA-1 fingerprint:
```bash
   # Debug keystore:
   keytool -list -v -keystore \~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
Click Create → download `google-services.json`
Place `google-services.json` in `android/app/`
Step 4 — iOS Setup (if needed)
In Credentials, also create an iOS OAuth client ID
Bundle ID: `com.yourname.expenseTracker`
Download `GoogleService-Info.plist`
Place in `ios/Runner/`
Step 5 — Android Manifest
Add to `android/app/src/main/AndroidManifest.xml` inside `<application>`:
```xml
<activity
    android:name="com.google.android.gms.auth.api.signin.internal.SignInHubActivity"
    android:screenOrientation="portrait"
    android:theme="@android:style/Theme.Translucent.NoTitleBar"/>
```
Add permissions above `<application>`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS\_NETWORK\_STATE"/>
```
Step 6 — Configure Your Spreadsheet ID
Open `lib/utils/app\_theme.dart` and replace:
```dart
static const String spreadsheetId = 'YOUR\_SPREADSHEET\_ID';
```
With your actual Sheet ID from the URL:
`https://docs.google.com/spreadsheets/d/THIS\_IS\_YOUR\_ID/edit`
So for your sheet:
```dart
static const String spreadsheetId = '1QCrT-Fu0F\_TH4OVkmj-iMTnjfwWfjMubunHNd-M7ySY';
```
Step 7 — Prepare Your Google Sheet
Make sure your sheet has a tab named "Expenses" with these column headers in Row 1:
A	B	C	D	E	F	G
Date	Amount	Category	SubCategory	PaymentMethod	Note	ID
Step 8 — Share Your Sheet
Share your Google Sheet with "Anyone with the link can edit"
OR share it with the specific Google account the user logs in with.
Step 9 — Run the App
```bash
# Get dependencies
flutter pub get

# Run on device/emulator
flutter run

# Build release APK
flutter build apk --release

# Build release iOS
flutter build ios --release
```
Project File Structure
```
expense\_tracker/
├── lib/
│   ├── main.dart                         # App entry point
│   ├── models/
│   │   └── expense\_model.dart            # Expense \& MonthlySummary models
│   ├── services/
│   │   ├── sheets\_service.dart           # Google Sheets API integration
│   │   └── expense\_provider.dart         # State management (Provider)
│   ├── screens/
│   │   ├── splash\_screen.dart            # Login / splash
│   │   ├── home\_screen.dart              # Home + bottom nav
│   │   ├── add\_expense\_screen.dart       # Add expense form
│   │   └── dashboard\_screen.dart         # Admin dashboard with charts
│   ├── widgets/
│   │   ├── balance\_card.dart             # Monthly balance hero card
│   │   ├── expense\_tile.dart             # Individual transaction row
│   │   └── category\_grid.dart           # Category icon grid
│   └── utils/
│       └── app\_theme.dart                # Theme, colors, constants
├── pubspec.yaml                          # Dependencies
└── SETUP.md                              # This file
```
Troubleshooting
Sign-in fails with PlatformException:
→ Check SHA-1 fingerprint matches your keystore
→ Verify `google-services.json` is in `android/app/`
Sheets API returns 403:
→ Make sure Google Sheets API is enabled in Cloud Console
→ Make sure the sheet is shared with the signed-in account
No data appears:
→ Check `spreadsheetId` is correct in `app\_theme.dart`
→ Check sheet tab is named exactly "Expenses"
→ Check column headers are in Row 1 (data starts Row 2)
C:\Program Files\Java\jdk-26.0.1
client id :662974268871-mgoclhaubjutnl0m3ccaqmuivc0a28hq.apps.googleusercontent.com



Alias name: androiddebugkey
Creation date: Apr 22, 2026
Entry type: PrivateKeyEntry
Certificate chain length: 1
Certificate[1]:
Owner: C=US, O=Android, CN=Android Debug
Issuer: C=US, O=Android, CN=Android Debug
Serial number: 1
Valid from: Wed Apr 22 14:30:02 GMT+04:00 2026 until: Fri Apr 14 14:30:02 GMT+04:00 2056
Certificate fingerprints:
         SHA1: F0:6B:99:FE:E8:25:68:C7:B3:4E:01:94:3F:6B:75:B4:C3:80:E9:43
         SHA256: EA:20:8F:AF:0F:8A:76:04:8D:A0:7E:4E:29:D6:6A:66:03:33:6C:88:74:95:54:03:18:E5:71:F1:71:EF:5C:0B
Signature algorithm name: SHA256withRSA
Subject Public Key Algorithm: 2048-bit RSA key
Version: 1

![Image 1]("https://github.com/user-attachments/assets/13197a7f-219b-400e-aec9-8f080038544e") ![Image 2]("https://github.com/user-attachments/assets/13197a7f-219b-400e-aec9-8f080038544e) ![Image 3]("https://github.com/user-attachments/assets/13197a7f-219b-400e-aec9-8f080038544e)

