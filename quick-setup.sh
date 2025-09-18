#!/bin/bash
# 🚀 Quick Setup Script for Full Stack Workout Tracker
# Run this script to set up the complete development environment

echo "🏋️ Setting up Full Stack Workout Tracker..."

# Check prerequisites
echo "📋 Checking prerequisites..."

# Check Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Please install Node.js v16+ from https://nodejs.org/"
    exit 1
fi

# Check MongoDB
if ! command -v mongod &> /dev/null; then
    echo "❌ MongoDB not found. Please install MongoDB from https://www.mongodb.com/try/download/community"
    exit 1
fi

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found. Please install Flutter from https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ All prerequisites found!"

# Setup Backend
echo "🔧 Setting up backend..."
cd backend

# Install dependencies
echo "📦 Installing backend dependencies..."
npm install

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📄 Creating backend .env file..."
    cp .env.example .env
    echo "⚠️  Please edit backend/.env with your configuration"
fi

# Setup Frontend
echo "📱 Setting up Flutter frontend..."
cd ../nutrition_app

# Install Flutter dependencies
echo "📦 Installing Flutter dependencies..."
flutter pub get

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📄 Creating Flutter .env file..."
    cat > .env << EOL
# Backend Configuration
BASE_URL=http://10.0.2.2:3000/api/v1

# Development Settings
DEV_BYPASS=false
DEV_BYPASS_USER=dev_user
TOKEN=development_token_placeholder
ADMIN_USER=dev_user

# Feature Flags
BACKEND_ENABLED=true
EOL
fi

echo "🎉 Setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Start MongoDB: mongod --dbpath=/your/data/path"
echo "2. Start backend: cd backend && npm start"
echo "3. Run Flutter app: cd nutrition_app && flutter run"
echo ""
echo "📖 For detailed instructions, see IMPLEMENTATION_GUIDE.md"