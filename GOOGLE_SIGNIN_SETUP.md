# Google Sign-In Setup Guide for CORIDE

## ✅ **What's Already Done:**

1. **Google Services JSON**: Your `android/app/google-services.json` is properly configured
2. **Dependencies**: `google_sign_in` package added to `pubspec.yaml`
3. **Auth Service**: Google Sign-In method implemented
4. **Auth Provider**: Google Sign-In state management added
5. **UI**: Simple auth screen with Google Sign-In button

## 🔧 **Firebase Console Setup:**

### Step 1: Enable Google Sign-In
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `coride-2071d`
3. Go to **Authentication** > **Sign-in method**
4. Click on **Google** provider
5. **Enable** Google sign-in
6. Add your **support email**
7. Click **Save**

### Step 2: Configure OAuth Consent Screen (if needed)
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project: `coride-2071d`
3. Go to **APIs & Services** > **OAuth consent screen**
4. Configure the consent screen with your app details

## 📱 **App Features:**

### **Simple Auth Screen Includes:**
- ✅ **Email/Password Login**
- ✅ **Email/Password Signup**
- ✅ **Google Sign-In Button**
- ✅ **Toggle between Login/Signup**
- ✅ **Form Validation**
- ✅ **Error Handling**
- ✅ **Loading States**

### **User Experience:**
1. **New Users**: Can sign up with email/password or Google
2. **Existing Users**: Can sign in with email/password or Google
3. **Google Users**: Automatically get "passenger" role by default
4. **Seamless**: Single screen handles both login and signup

## 🚀 **How to Test:**

### **Run the App:**
```bash
flutter run
```

### **Test Scenarios:**
1. **Email/Password Signup**: Create new account
2. **Email/Password Login**: Sign in with existing account
3. **Google Sign-In**: Use Google account (creates new user if first time)
4. **Form Validation**: Try invalid inputs
5. **Error Handling**: Test with wrong credentials

## 🔍 **Troubleshooting:**

### **Common Issues:**

1. **"Google Sign-In Failed"**:
   - Check if Google provider is enabled in Firebase Console
   - Verify `google-services.json` is correct
   - Ensure SHA-1 fingerprint is added to Firebase project

2. **"Sign-in was cancelled"**:
   - User cancelled the Google sign-in flow (normal behavior)

3. **Build Errors**:
   - Run `flutter clean` and `flutter pub get`
   - Check if all dependencies are installed

### **Adding SHA-1 Fingerprint (if needed):**
```bash
# Debug SHA-1
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Release SHA-1 (when you create release keystore)
keytool -list -v -keystore your-release-key.keystore -alias your-key-alias
```

## 📋 **Current Implementation:**

### **Auth Flow:**
1. User opens app → Simple Auth Screen
2. User can choose:
   - Email/Password (Login or Signup)
   - Google Sign-In
3. Success → Home Screen with user data
4. Error → Show error message

### **User Data Storage:**
- **Email/Password Users**: Full profile with role selection
- **Google Users**: Auto-created with "passenger" role
- **All Users**: Stored in Firestore with proper structure

## 🎯 **Next Steps:**

1. **Test the app** with both authentication methods
2. **Customize the UI** if needed
3. **Add role selection** for Google users
4. **Implement profile management**
5. **Add more authentication providers** (Facebook, Apple, etc.)

The app is ready to use! Users can now sign in with either email/password or Google accounts.
