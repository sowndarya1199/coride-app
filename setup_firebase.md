# Firebase Setup Guide for CORIDE

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name: `coride-app`
4. Enable Google Analytics (optional)
5. Click "Create project"

## Step 2: Enable Authentication

1. In Firebase Console, go to "Authentication" > "Sign-in method"
2. Click on "Email/Password"
3. Enable "Email/Password" provider
4. Click "Save"

## Step 3: Create Firestore Database

1. Go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select a location for your database
5. Click "Done"

## Step 4: Configure Android App

1. In Firebase Console, click "Add app" and select Android
2. Enter package name: `com.example.coride`
3. Enter app nickname: `CORIDE Android`
4. Click "Register app"
5. Download the `google-services.json` file
6. Replace the placeholder file in `android/app/google-services.json`

## Step 5: Configure iOS App (if developing for iOS)

1. In Firebase Console, click "Add app" and select iOS
2. Enter bundle ID: `com.example.coride`
3. Enter app nickname: `CORIDE iOS`
4. Click "Register app"
5. Download the `GoogleService-Info.plist` file
6. Replace the placeholder file in `ios/Runner/GoogleService-Info.plist`

## Step 6: Update Security Rules (Development)

For development, you can use these basic Firestore rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Step 7: Test the Setup

1. Run the Flutter app: `flutter run`
2. Try to create a new account
3. Check if the user appears in Firebase Authentication
4. Check if user data is saved in Firestore Database

## Troubleshooting

### Common Issues:

1. **"Firebase not initialized"**: Make sure you've replaced the configuration files
2. **"Permission denied"**: Check your Firestore security rules
3. **"Invalid API key"**: Verify the configuration files are correct
4. **Build errors**: Make sure you've run `flutter clean` and `flutter pub get`

### Next Steps:

1. Set up proper Firestore security rules for production
2. Configure Firebase Cloud Messaging for notifications
3. Add Google Maps API key for location services
4. Set up proper user roles and permissions

## Production Considerations

1. **Security Rules**: Implement proper Firestore security rules
2. **API Keys**: Use environment variables for sensitive keys
3. **User Roles**: Implement proper role-based access control
4. **Data Validation**: Add server-side validation
5. **Monitoring**: Set up Firebase Analytics and Crashlytics
