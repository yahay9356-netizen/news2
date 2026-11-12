# News

A Flutter news app for iOS and Android using NewsAPI for headlines and search.

## Run

Create a NewsAPI key, then run the app with the key supplied at build time:

```powershell
flutter run --dart-define="NEWS_API_KEY=your_key"
```

Build an Android APK:

```powershell
flutter build apk --release --dart-define="NEWS_API_KEY=your_key"
```

Or build an Android app bundle for Google Play:

```powershell
flutter build appbundle --release --dart-define="NEWS_API_KEY=your_key"
```

The app also accepts the key when building for iOS:

```powershell
flutter build ios --release --dart-define="NEWS_API_KEY=your_key"
```

Do not commit the key. A key passed with `--dart-define` is included in the
compiled app and can be extracted, so use a backend proxy before distributing
the app publicly.

The Figma file's preview image is visible, but its full design requires access
to the file. The current UI follows the preview's dark news-app style and
category-based home screen.
