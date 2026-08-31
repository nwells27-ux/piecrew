# iOS setup for Firebase

After you run `flutter create --org com.yourpie --project-name piecrew .`:

1. Copy `ios-config/GoogleService-Info.plist` (from this project) into
   `ios/Runner/GoogleService-Info.plist`.

2. Open `ios/Runner.xcworkspace` in Xcode (not the .xcodeproj) and drag
   `GoogleService-Info.plist` into the Runner group in the file navigator,
   with "Copy items if needed" checked and the Runner target selected —
   this registers it with the Xcode build so it actually ships in the app.

3. Firebase requires iOS 13 or later. Check `ios/Podfile` has:
   ```ruby
   platform :ios, '13.0'
   ```
   (uncomment or add that line near the top if it's not already set).

4. Run `cd ios && pod install && cd ..` once, then `flutter run` as usual.

No other native iOS changes are needed — this app doesn't use Google
Sign-In, push-only capabilities, or anything else requiring extra
entitlements beyond what `flutter create` sets up by default.
