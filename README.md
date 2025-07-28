# Meetified - AI-Powered Dating App

Meetified is an innovative AI-powered dating app that revolutionizes how people connect through conversational AI profile building and intelligent matching algorithms.

## 🌟 Features

### Core Features
- **AI-Powered Profile Building**: Natural conversation with AI to build authentic profiles
- **Smart Compatibility Matching**: Advanced algorithms analyze both presented and derived data
- **Anonymous Chat System**: Start conversations without revealing identities initially
- **Question Exchange System**: Ask questions through AI to learn more about matches
- **Premium Identity Reveal**: Upgrade for instant identity reveals
- **UPI Payment Integration**: Seamless Indian payment system with automatic verification

### Technical Features
- **Flutter Framework**: Cross-platform mobile development
- **Firebase Backend**: Authentication, Firestore, Storage, and Messaging
- **OpenAI GPT-3.5**: Conversational AI for profile building and matching
- **Dark/Light Themes**: Adaptive UI with system preference support
- **Real-time Chat**: Anonymous messaging with identity revelation options
- **Push Notifications**: Stay updated with matches and messages

## 🏗️ Architecture

### System Architecture
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │   Firebase      │    │   OpenAI API    │
│   (Android)     │◄──►│   Backend       │◄──►│   (GPT-3.5)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Key Components
- **Authentication**: Phone-based authentication with SMS verification
- **Profile Management**: AI-assisted profile building and management
- **Matching Engine**: Sophisticated compatibility scoring algorithm
- **Chat System**: Real-time messaging with anonymity features
- **Payment System**: Direct UPI integration with verification
- **Notification System**: Firebase Cloud Messaging integration

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Android Studio / VS Code
- Firebase project setup
- OpenAI API key

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/meetified.git
   cd meetified
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase for your project
   flutterfire configure --project=your-project-id
   ```

4. **Set up API keys**
   - Add your OpenAI API key to `Openapi.key` file
   - Configure Firebase credentials in `firebase_options.dart`

5. **Run the app**
   ```bash
   flutter run
   ```

## 📱 App Structure

```
lib/
├── main.dart                 # App entry point
├── src/
│   ├── app.dart             # Main app widget
│   ├── core/                # Core functionality
│   │   ├── constants/       # App constants
│   │   ├── models/          # Data models
│   │   ├── providers/       # State management
│   │   ├── routing/         # Navigation
│   │   ├── services/        # Core services
│   │   └── theme/           # App theming
│   └── features/            # Feature modules
│       ├── auth/            # Authentication
│       ├── chat/            # Chat system
│       ├── home/            # Home screen
│       ├── matching/        # Matching system
│       ├── onboarding/      # Onboarding flow
│       ├── payment/         # Payment system
│       ├── profile/         # Profile management
│       └── settings/        # App settings
```

## 🔧 Configuration

### Firebase Setup
1. Create a Firebase project
2. Enable Authentication (Phone)
3. Set up Firestore Database
4. Configure Firebase Storage
5. Add Firebase Cloud Messaging

### OpenAI Setup
1. Get OpenAI API key
2. Add to `Openapi.key` file
3. Configure usage limits

### UPI Payment Setup
1. Configure UPI ID in constants
2. Set up payment verification
3. Test with sandbox environment

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Run widget tests
flutter test test/widget_test.dart
```

## 🏃‍♂️ Running in Production

### Build Release APK
```bash
flutter build apk --release
```

### Build App Bundle
```bash
flutter build appbundle --release
```

### Environment Configuration
- Update Firebase configuration for production
- Set production OpenAI API keys
- Configure production UPI settings
- Enable production payment verification

## 📊 Features Implementation Status

- ✅ Flutter project structure with proper architecture
- ✅ Firebase configuration and authentication system
- ✅ Core data models (User, Profile, Match, Chat, etc.)
- ✅ AI chat service with OpenAI GPT-3.5 integration
- ✅ Matching algorithm with compatibility scoring
- ✅ UI screens for onboarding, profile building, matching
- ✅ Theme management (dark/light themes)
- 🔄 Anonymous chat system with identity revelation
- 🔄 UPI payment integration with verification
- 🔄 Emoji picker and expression system
- 🔄 Hold matchmaking and money-back guarantee features
- 🔄 Firebase Cloud Functions for daily matching
- 🔄 Testing and error handling

## 🔐 Security & Privacy

- Phone number authentication
- Anonymous chat capabilities
- Data encryption in transit and at rest
- GDPR compliance features
- User data protection
- Secure payment processing

## 💰 Monetization

### Premium Features (₹99/month)
- Instant identity reveals
- Unlimited daily matches
- Advanced AI insights
- Priority matching
- Undo actions
- Enhanced chat features
- Money-back guarantee

### Payment Methods
- UPI (Google Pay, PhonePe, Paytm, BHIM)
- Direct bank transfer
- Automatic verification system

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Team

- **Development**: AI-powered dating app team
- **Design**: Modern, intuitive user experience
- **AI Integration**: OpenAI GPT-3.5 implementation
- **Backend**: Firebase and cloud services

## 📞 Support

For support, email support@meetified.com or join our Discord community.

## 🔮 Roadmap

- [ ] iOS app development
- [ ] Video chat integration
- [ ] Advanced AI personality matching
- [ ] Social media integration
- [ ] Event-based matching
- [ ] International expansion
- [ ] Machine learning improvements

---

Made with ❤️ by the Meetified team