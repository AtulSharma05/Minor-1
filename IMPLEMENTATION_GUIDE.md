# 🚀 Full Stack Workout Tracker - Implementation Guide

## Overview
This guide helps you implement the complete workout tracking system with Node.js backend and Flutter frontend.

## 📋 Prerequisites

### Required Software:
- **Node.js** (v16+) - [Download](https://nodejs.org/)
- **MongoDB** (v5+) - [Download](https://www.mongodb.com/try/download/community)
- **Flutter SDK** (v3.0+) - [Install Guide](https://flutter.dev/docs/get-started/install)
- **Git** - [Download](https://git-scm.com/)

### Development Tools:
- **VS Code** with Flutter/Dart extensions
- **Android Studio** (for Android development)
- **Postman** (optional, for API testing)

## 🛠️ Step-by-Step Implementation

### 1. Clone and Setup Repository

```bash
# Clone the repository
git clone https://github.com/krrish-sehgal/5-sem-Minor.git
cd 5-sem-Minor

# Create environment files
cd backend
cp .env.example .env
```

### 2. Backend Setup (Node.js + MongoDB)

#### Install Dependencies:
```bash
cd backend
npm install
```

#### Configure Environment (.env):
```env
# Database Configuration
MONGODB_URI=mongodb://localhost:27017/workout_tracker_db
NODE_ENV=development
PORT=3000

# JWT Configuration  
JWT_SECRET=your_super_secret_key_here_minimum_32_characters
JWT_EXPIRES_IN=24h
JWT_REFRESH_SECRET=your_refresh_secret_key_here_minimum_32_characters
JWT_REFRESH_EXPIRES_IN=7d

# CORS Configuration
CORS_ORIGIN=http://localhost:3000,http://10.0.2.2:3000

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

#### Start MongoDB:
```bash
# Windows
mongod --dbpath=C:\data\db

# macOS/Linux  
mongod --dbpath=/usr/local/var/mongodb
```

#### Start Backend Server:
```bash
npm start
# Server runs on http://localhost:3000
```

#### Test Backend API:
```bash
# Windows PowerShell
.\test-frontend-api.ps1

# Linux/macOS
curl http://localhost:3000/health
```

### 3. Flutter Frontend Setup

#### Navigate to Flutter App:
```bash
cd ../nutrition_app
```

#### Install Flutter Dependencies:
```bash
flutter pub get
```

#### Configure Environment (.env):
```env
# Backend Configuration
BASE_URL=http://10.0.2.2:3000/api/v1

# Development Settings
DEV_BYPASS=false
DEV_BYPASS_USER=dev_user
TOKEN=development_token_placeholder
ADMIN_USER=dev_user

# Feature Flags
BACKEND_ENABLED=true
```

#### Run Flutter App:
```bash
# List available devices
flutter devices

# Run on Android Emulator
flutter run -d <device_id>

# Run on specific device
flutter run -d emulator-5554
```

## 🏗️ Architecture Overview

### Backend Structure:
```
backend/
├── src/
│   ├── controllers/     # API route handlers
│   ├── middleware/      # Auth, validation, error handling
│   ├── models/         # MongoDB schemas
│   ├── routes/         # API endpoints
│   ├── utils/          # Helper functions
│   └── server.js       # Main server file
├── tests/              # API test scripts
└── package.json
```

### Frontend Structure:
```
nutrition_app/
├── lib/
│   ├── models/         # Data models
│   ├── services/       # API and local storage
│   ├── pages/          # UI screens
│   ├── widgets/        # Reusable components
│   ├── notifiers/      # State management
│   └── main.dart       # App entry point
└── pubspec.yaml
```

## 📊 Key Features Implemented

### 1. Authentication System
- **JWT-based authentication**
- **User registration/login**
- **Token refresh mechanism**
- **Frontend-compatible endpoints**

### 2. Workout Management
- **CRUD operations for workouts**
- **Exercise tracking with sets/reps/weight**
- **Automatic calorie calculation**
- **Workout categories and templates**

### 3. User Statistics
- **Workout streaks tracking**
- **Progress analytics**
- **Personal records**
- **Achievement system**

### 4. Data Services
- **API-first architecture**
- **Offline data caching**
- **Intelligent sync mechanism**
- **Local storage fallback**

## 🔧 API Endpoints

### Authentication:
```
POST /api/v1/auth_user/client_register
POST /api/v1/auth_user/client_login
POST /api/v1/auth_user/client_logout
```

### Workouts:
```
GET    /api/v1/workouts          # List workouts
POST   /api/v1/workouts          # Create workout
GET    /api/v1/workouts/:id      # Get workout
PUT    /api/v1/workouts/:id      # Update workout
DELETE /api/v1/workouts/:id      # Delete workout
```

### Workout Logging:
```
POST   /api/v1/workout-logging/start    # Start workout session
POST   /api/v1/workout-logging/complete # Complete workout
GET    /api/v1/workout-logging/recent   # Get recent workouts
```

## 🧪 Testing

### Backend Testing:
```bash
# Test all APIs
.\test-frontend-api.ps1

# Test specific workout APIs
.\test-workout-api.ps1

# Test authentication
.\test-api.ps1
```

### Frontend Testing:
```bash
# Run Flutter tests
flutter test

# Run integration tests
flutter test integration_test/
```

## 🚨 Troubleshooting

### Common Issues:

#### MongoDB Connection Error:
```bash
# Check if MongoDB is running
mongod --version

# Start MongoDB service
# Windows: Start MongoDB service in Services
# macOS: brew services start mongodb-community
# Linux: sudo systemctl start mongod
```

#### Flutter Build Issues:
```bash
# Clean Flutter cache
flutter clean
flutter pub get

# Rebuild
flutter build apk --debug
```

#### Backend Authentication Issues:
- Check JWT secret in `.env`
- Verify MongoDB connection
- Test endpoints with Postman

#### Frontend Connection Issues:
- Check `BASE_URL` in Flutter `.env`
- Ensure backend is running on correct port
- Verify network permissions in Android manifest

## 📱 Platform-Specific Setup

### Android:
1. **Enable Internet Permission** (already configured)
2. **Configure Network Security** (already configured)
3. **Setup Emulator** with API 21+

### iOS:
1. **Configure Info.plist** for network access
2. **Setup iOS Simulator**
3. **Handle iOS-specific networking**

## 🔐 Security Considerations

### Backend Security:
- **Environment variables** for sensitive data
- **Input validation** on all endpoints
- **Rate limiting** to prevent abuse
- **CORS** configuration for frontend access

### Frontend Security:
- **Secure token storage** using Flutter Secure Storage
- **Input sanitization** on forms
- **Network security** configurations

## 🚀 Deployment Options

### Backend Deployment:
- **Heroku**: Easy deployment with MongoDB Atlas
- **DigitalOcean**: VPS with custom MongoDB setup
- **AWS**: EC2 + RDS/DocumentDB
- **Railway**: Simple Node.js deployment

### Frontend Deployment:
- **Google Play Store**: Android APK
- **Apple App Store**: iOS IPA
- **Web**: Flutter Web build
- **Desktop**: Flutter Desktop apps

## 📞 Support

### Getting Help:
1. **Check logs** in backend console and Flutter debug
2. **Review API documentation** in `WORKOUT_API_DOCS.md`
3. **Test endpoints** using provided PowerShell scripts
4. **Check GitHub Issues** for common problems

### Useful Commands:
```bash
# Backend
npm run dev          # Development mode with nodemon
npm test            # Run tests
npm run lint        # Code linting

# Flutter
flutter doctor      # Check Flutter installation
flutter analyze     # Code analysis
flutter run -v      # Verbose output
```

## 🎯 Next Steps

1. **Test the complete flow**: Registration → Login → Create Workout → View Statistics
2. **Customize UI**: Modify Flutter themes and layouts
3. **Add features**: Extend API with new workout types
4. **Deploy**: Choose deployment platform and go live
5. **Monitor**: Add logging and analytics

## 📄 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Node.js Express Guide](https://expressjs.com/en/guide/routing.html)
- [MongoDB Manual](https://docs.mongodb.com/manual/)
- [JWT.io](https://jwt.io/) - JWT debugging
- [Postman](https://www.postman.com/) - API testing

---

🎉 **Congratulations!** You now have a complete full-stack workout tracking application. The system is production-ready with proper authentication, data persistence, and a modern Flutter interface.