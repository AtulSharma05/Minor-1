# Workout Tracker Backend Setup

## Prerequisites

Before running the backend, you need to install the following:

### 1. Install Node.js (v18 or higher)
- Download from: https://nodejs.org/
- Verify installation: `node --version` and `npm --version`

### 2. Install MongoDB
- **Option A - Local MongoDB:**
  - Download from: https://www.mongodb.com/try/download/community
  - Start MongoDB service: `mongod`
  
- **Option B - MongoDB Atlas (Cloud):**
  - Create free account at: https://www.mongodb.com/atlas
  - Get connection string and update MONGODB_URI in .env

## Installation

1. **Navigate to backend directory:**
   ```bash
   cd backend
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Configure environment:**
   - Copy `.env.example` to `.env`
   - Update database connection and JWT secrets

4. **Start the server:**
   ```bash
   npm start
   ```

## API Endpoints

### Base URL: `http://localhost:5000/api/v1`

### Health Check
- `GET /health` - Server status

### Authentication
- `POST /auth/register` - Register new user
- `POST /auth/login` - User login
- `POST /auth/refresh` - Refresh access token
- `POST /auth/logout` - Logout user
- `POST /auth/logout-all` - Logout from all devices
- `GET /auth/me` - Get current user profile

## Request Examples

### Register User
```bash
POST /api/v1/auth/register
Content-Type: application/json

{
  "username": "johndoe",
  "email": "john@example.com",
  "password": "password123",
  "fullName": "John Doe",
  "age": 25,
  "height": 175,
  "weight": 70
}
```

### Login User
```bash
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "password123"
}
```

### Get User Profile (Protected)
```bash
GET /api/v1/auth/me
Authorization: Bearer <accessToken>
```

## Response Format

All API responses follow this format:

```json
{
  "status": "success" | "fail" | "error",
  "message": "Description of the result",
  "data": {
    // Response data here
  }
}
```

## Development

- Server runs on port 5000 by default
- MongoDB connection required for full functionality
- JWT tokens expire in 24 hours (configurable)
- Refresh tokens expire in 7 days

## Next Steps

1. Install Node.js and MongoDB
2. Run `npm install` in the backend directory
3. Configure your .env file
4. Start the server with `npm start`
5. Test endpoints using Postman or similar tool

## Integration with Flutter App

The backend is designed to work with the Flutter app's AuthNotifier:
- Response format matches expected data structure
- Token handling compatible with app's authentication flow
- Error responses provide clear feedback for UI

## File Structure

```
backend/
├── package.json          # Dependencies and scripts
├── .env                 # Environment configuration
├── src/
│   ├── server.js        # Main server file
│   ├── config/
│   │   └── database.js  # MongoDB connection
│   ├── middleware/
│   │   └── errorHandler.js # Error handling
│   ├── models/
│   │   └── User.js      # User model
│   └── routes/
│       └── auth.js      # Authentication routes
```