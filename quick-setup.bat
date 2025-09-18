@echo off
REM 🚀 Quick Setup Script for Full Stack Workout Tracker (Windows)
REM Run this script to set up the complete development environment

echo 🏋️ Setting up Full Stack Workout Tracker...

REM Check prerequisites
echo 📋 Checking prerequisites...

REM Check Node.js
node --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Node.js not found. Please install Node.js v16+ from https://nodejs.org/
    pause
    exit /b 1
)

REM Check MongoDB
mongod --version >nul 2>&1
if errorlevel 1 (
    echo ❌ MongoDB not found. Please install MongoDB from https://www.mongodb.com/try/download/community
    pause
    exit /b 1
)

REM Check Flutter
flutter --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Flutter not found. Please install Flutter from https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

echo ✅ All prerequisites found!

REM Setup Backend
echo 🔧 Setting up backend...
cd backend

REM Install dependencies
echo 📦 Installing backend dependencies...
npm install

REM Create .env file if it doesn't exist
if not exist .env (
    echo 📄 Creating backend .env file...
    copy .env.example .env
    echo ⚠️  Please edit backend\.env with your configuration
)

REM Setup Frontend
echo 📱 Setting up Flutter frontend...
cd ..\nutrition_app

REM Install Flutter dependencies
echo 📦 Installing Flutter dependencies...
flutter pub get

REM Create .env file if it doesn't exist
if not exist .env (
    echo 📄 Creating Flutter .env file...
    echo # Backend Configuration > .env
    echo BASE_URL=http://10.0.2.2:3000/api/v1 >> .env
    echo. >> .env
    echo # Development Settings >> .env
    echo DEV_BYPASS=false >> .env
    echo DEV_BYPASS_USER=dev_user >> .env
    echo TOKEN=development_token_placeholder >> .env
    echo ADMIN_USER=dev_user >> .env
    echo. >> .env
    echo # Feature Flags >> .env
    echo BACKEND_ENABLED=true >> .env
)

echo 🎉 Setup complete!
echo.
echo 📋 Next steps:
echo 1. Start MongoDB: mongod --dbpath=C:\data\db
echo 2. Start backend: cd backend ^&^& npm start
echo 3. Run Flutter app: cd nutrition_app ^&^& flutter run
echo.
echo 📖 For detailed instructions, see IMPLEMENTATION_GUIDE.md

pause