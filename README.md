# ABIYAHE - Travel Planning Made Easy

## Group Details
- **Group Name**: ABIYAHE
- **Members**:
  - Athalia Marfil
  - Jared Carranza
  - Rafael Landicho


## Program Description
ABIYAHE is a mobile application designed to simplify travel planning and coordination. The app allows users to:
- Create and manage travel plans
- Share travel plans with friends
- Join travel plans via QR codes
- Set travel preferences and interests
- Connect with other travelers
- Receive notifications for travel updates
- Manage travel schedules and itineraries

## Installation Guide

### Prerequisites
- Flutter SDK (version 2.18.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Firebase account
- Git

### Setup Steps
1. Clone the repository:
   ```bash
   git clone [repository-url]
   cd project-abiyahe
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Firebase:
   - Create a new Firebase project
   - Add Android app to Firebase project
   - Download `google-services.json` and place it in `android/app/`
   - Enable Authentication, Firestore, and Cloud Messaging

4. Run the app:
   ```bash
   flutter run
   ```

## How to Use the App

### User Registration
1. Open the app
2. Click "Sign Up"
3. Fill in required information:
   - First Name
   - Last Name
   - Username
   - Email
   - Password
   - Travel Preferences (optional)
   - Interests (optional)

### Creating a Travel Plan
1. Log in to your account
2. Navigate to "My Travel Plans"
3. Click "Create New Plan"
4. Fill in plan details:
   - Destination
   - Dates
   - Activities
   - Budget
   - Other preferences

### Sharing Travel Plans
1. Open your travel plan
2. Choose sharing method:
   - Share with Friends: Select from your friend list
   - Share via QR: Generate QR code for others to scan

### Joining a Travel Plan
1. Scan QR code shared by friend
2. Or accept invitation from friend
3. View and contribute to the travel plan

### Managing Friends
1. Go to "Friends" section
2. Add friends by username
3. Accept/decline friend requests
4. View friend profiles and travel plans

### Notifications
- Receive notifications for:
  - Friend requests
  - Travel plan updates
  - Invitations to join plans
  - Schedule reminders

## Features
- User Authentication
- Travel Plan Management
- Friend System
- QR Code Sharing
- Push Notifications
- Profile Customization
- Travel Preferences
- Real-time Updates

## Technical Stack
- Flutter
- Firebase Authentication
- Cloud Firestore
- Firebase Cloud Messaging
- Provider State Management
- Local Notifications


## References
- https://locationiq.com/
- https://pub.dev/packages/flutter_typeahead
- https://unsplash.com/developers
- https://api.flutter.dev/flutter/material/TabBar-class.html
- https://pub.dev/packages/flutter_local_notifications
- https://api.flutter.dev/flutter/material/showDateRangePicker.html
- https://pub.dev/packages/syncfusion_flutter_datepicker
- https://firebase.google.com/docs/firestore/query-data/indexing
- https://pub.dev/packages/http


