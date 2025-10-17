# CORIDE - Together We Go

A smart ride-sharing application designed to enhance transportation efficiency through intelligent route matching and shared travel coordination.

## Features

- **User Authentication**: Email/password authentication with role-based access (Passenger/Driver)
- **Firebase Integration**: Real-time database, authentication, and cloud messaging
- **Modern UI**: Beautiful, responsive Flutter interface
- **Role-based Access**: Different experiences for passengers and drivers
- **Profile Management**: User profile creation and management

## Tech Stack

- **Frontend**: Flutter with Dart
- **Backend**: Firebase (Authentication, Firestore, Cloud Messaging)
- **State Management**: Provider
- **Maps**: Google Maps Platform
- **Architecture**: Clean architecture with separation of concerns

## Project Structure

```
lib/
├── constants/          # App constants and configurations
├── models/            # Data models (User, AuthResult)
├── providers/          # State management (AuthProvider)
├── screens/           # UI screens
│   ├── auth/         # Authentication screens
│   └── home/         # Main app screens
├── services/          # Business logic services
├── utils/            # Utility functions
└── widgets/          # Reusable UI components
```

## Setup Instructions

### Prerequisites

1. **Flutter SDK**: Install Flutter (3.8.1 or higher)
2. **Firebase Project**: Create a Firebase project
3. **Android Studio**: For Android development
4. **Xcode**: For iOS development (macOS only)

### Firebase Setup

1. **Create Firebase Project**:
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project named "coride-app"
   - Enable Authentication and Firestore Database

2. **Configure Authentication**:
   - Go to Authentication > Sign-in method
   - Enable Email/Password authentication

3. **Configure Firestore**:
   - Go to Firestore Database
   - Create database in production mode
   - Set up security rules (for development, you can use test mode)

4. **Download Configuration Files**:
   - Download `google-services.json` for Android
   - Download `GoogleService-Info.plist` for iOS
   - Replace the placeholder files in the project

### Installation

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd coride
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**:
   - Replace the placeholder Firebase configuration files with your actual ones
   - Update the package name in `android/app/build.gradle.kts` if needed

4. **Run the application**:
   ```bash
   flutter run
   ```

## Usage

### For Passengers
1. Sign up with email/password
2. Select "Passenger" role during registration
3. Access ride-finding features (coming soon)
4. View ride history and profile

### For Drivers
1. Sign up with email/password
2. Select "Driver" role during registration
3. Access driver features (coming soon)
4. Manage vehicle information

## Development

### Adding New Features

1. **Models**: Add new data models in `lib/models/`
2. **Services**: Add business logic in `lib/services/`
3. **Screens**: Add new screens in `lib/screens/`
4. **Providers**: Add state management in `lib/providers/`

### Code Structure

- **Models**: Define data structures and serialization
- **Services**: Handle API calls and business logic
- **Providers**: Manage application state
- **Screens**: UI components and user interactions
- **Widgets**: Reusable UI components

## Firebase Security Rules

For development, you can use these basic rules:

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

## Future Enhancements

- [ ] Google Maps integration for location services
- [ ] Real-time ride matching with ML algorithms
- [ ] Push notifications for ride updates
- [ ] Payment integration
- [ ] Driver verification system
- [ ] Ride history and analytics
- [ ] Rating and review system

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please contact the development team or create an issue in the repository.