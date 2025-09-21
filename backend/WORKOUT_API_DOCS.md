# Workout Tracking API Documentation

## Overview

The Workout Tracking API provides comprehensive endpoints for managing user workouts, including creation, retrieval, updates, deletion, and analytics. All workout endpoints require JWT authentication.

**Base URL:** `http://localhost:3000/api/v1`

## Authentication

All workout endpoints require a valid JWT token in the Authorization header:

```
Authorization: Bearer <access_token>
```

To get an access token, use the authentication endpoints:
- `POST /api/v1/auth/register` - Register a new user
- `POST /api/v1/auth/login` - Login existing user
- `POST /api/v1/auth_user/client_login` - Flutter-compatible login

## Workout Endpoints

### 1. Create Workout

**Endpoint:** `POST /api/v1/workouts`

**Description:** Create a new workout entry for the authenticated user.

**Headers:**
```
Content-Type: application/json
Authorization: Bearer <access_token>
```

**Request Body:**
```json
{
  "exerciseName": "Morning Run",           // Required: Exercise name
  "workoutType": "cardio",                 // Optional: cardio|strength|flexibility|sports|other
  "duration": 30,                         // Required: Duration in minutes
  "caloriesBurned": 300,                  // Optional: Auto-calculated if not provided
  "date": "2025-09-18T10:00:00.000Z",    // Optional: Defaults to current time
  "sets": 3,                              // Optional: For strength training
  "reps": 10,                             // Optional: For strength training
  "weight": 80,                           // Optional: Weight in kg
  "notes": "Great morning run!",          // Optional: Additional notes
  "intensityLevel": "moderate"            // Optional: low|moderate|high|extreme
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "message": "Workout created successfully",
  "data": {
    "workout": {
      "_id": "64f123456789abcdef123456",
      "userId": "64f123456789abcdef123455",
      "exerciseName": "Morning Run",
      "workoutType": "cardio",
      "duration": 30,
      "caloriesBurned": 300,
      "date": "2025-09-18T10:00:00.000Z",
      "intensityLevel": "moderate",
      "notes": "Great morning run!",
      "createdAt": "2025-09-18T10:00:00.000Z",
      "updatedAt": "2025-09-18T10:00:00.000Z",
      "caloriesPerMinute": 10
    }
  }
}
```

### 2. Get All Workouts

**Endpoint:** `GET /api/v1/workouts`

**Description:** Retrieve all workouts for the authenticated user with pagination and filtering.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Query Parameters:**
- `limit` (optional): Number of workouts per page (default: 20)
- `page` (optional): Page number (default: 1)
- `startDate` (optional): Filter workouts from this date (ISO string)
- `endDate` (optional): Filter workouts until this date (ISO string)
- `workoutType` (optional): Filter by workout type
- `sortBy` (optional): Sort field (default: 'date')
- `sortOrder` (optional): Sort order 'asc' or 'desc' (default: 'desc')

**Example:** `GET /api/v1/workouts?limit=10&page=1&workoutType=cardio&startDate=2025-09-01`

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Workouts retrieved successfully",
  "data": {
    "workouts": [
      {
        "_id": "64f123456789abcdef123456",
        "exerciseName": "Morning Run",
        "workoutType": "cardio",
        "duration": 30,
        "caloriesBurned": 300,
        "date": "2025-09-18T10:00:00.000Z",
        "intensityLevel": "moderate",
        "caloriesPerMinute": 10
      }
    ],
    "pagination": {
      "currentPage": 1,
      "totalPages": 5,
      "totalCount": 50,
      "hasNextPage": true,
      "hasPrevPage": false
    }
  }
}
```

### 3. Get Single Workout

**Endpoint:** `GET /api/v1/workouts/:id`

**Description:** Retrieve a specific workout by ID (user can only access their own workouts).

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Workout retrieved successfully",
  "data": {
    "workout": {
      "_id": "64f123456789abcdef123456",
      "userId": "64f123456789abcdef123455",
      "exerciseName": "Morning Run",
      "workoutType": "cardio",
      "duration": 30,
      "caloriesBurned": 300,
      "date": "2025-09-18T10:00:00.000Z",
      "sets": null,
      "reps": null,
      "weight": null,
      "notes": "Great morning run!",
      "intensityLevel": "moderate",
      "createdAt": "2025-09-18T10:00:00.000Z",
      "updatedAt": "2025-09-18T10:00:00.000Z"
    }
  }
}
```

### 4. Update Workout

**Endpoint:** `PUT /api/v1/workouts/:id`

**Description:** Update an existing workout (user can only update their own workouts).

**Headers:**
```
Content-Type: application/json
Authorization: Bearer <access_token>
```

**Request Body:** (All fields optional)
```json
{
  "exerciseName": "Updated Morning Run",
  "duration": 35,
  "caloriesBurned": 350,
  "notes": "Ran an extra 5 minutes today!"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Workout updated successfully",
  "data": {
    "workout": {
      "_id": "64f123456789abcdef123456",
      "exerciseName": "Updated Morning Run",
      "duration": 35,
      "caloriesBurned": 350,
      "notes": "Ran an extra 5 minutes today!",
      "updatedAt": "2025-09-18T11:00:00.000Z"
    }
  }
}
```

### 5. Delete Workout

**Endpoint:** `DELETE /api/v1/workouts/:id`

**Description:** Delete a workout (user can only delete their own workouts).

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Workout deleted successfully",
  "data": null
}
```

### 6. Get Workout Statistics

**Endpoint:** `GET /api/v1/workouts/stats`

**Description:** Get comprehensive workout statistics for the authenticated user.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Query Parameters:**
- `startDate` (optional): Start date for statistics (default: 30 days ago)
- `endDate` (optional): End date for statistics (default: today)

**Example:** `GET /api/v1/workouts/stats?startDate=2025-09-01&endDate=2025-09-30`

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Workout statistics retrieved successfully",
  "data": {
    "period": {
      "startDate": "2025-09-01T00:00:00.000Z",
      "endDate": "2025-09-30T23:59:59.999Z"
    },
    "overview": {
      "totalWorkouts": 25,
      "totalDuration": 750,
      "totalCalories": 7500,
      "avgDuration": 30,
      "avgCalories": 300,
      "workoutTypes": ["cardio", "strength", "flexibility"],
      "currentStreak": 5
    },
    "workoutsByType": [
      {
        "_id": "cardio",
        "count": 15,
        "totalDuration": 450,
        "totalCalories": 4500
      },
      {
        "_id": "strength",
        "count": 8,
        "totalDuration": 240,
        "totalCalories": 2400
      }
    ],
    "topExercises": [
      {
        "_id": "Running",
        "count": 10,
        "avgDuration": 30,
        "avgCalories": 300
      },
      {
        "_id": "Weight Training",
        "count": 5,
        "avgDuration": 45,
        "avgCalories": 250
      }
    ],
    "weeklyProgress": [
      {
        "_id": { "year": 2025, "week": 37 },
        "workoutCount": 4,
        "totalDuration": 120,
        "totalCalories": 1200
      }
    ]
  }
}
```

### 7. Get Recent Workouts

**Endpoint:** `GET /api/v1/workouts/recent`

**Description:** Get recent workouts from the last 7 days.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Recent workouts retrieved successfully",
  "data": {
    "workouts": [
      {
        "_id": "64f123456789abcdef123456",
        "exerciseName": "Morning Run",
        "workoutType": "cardio",
        "duration": 30,
        "caloriesBurned": 300,
        "date": "2025-09-18T10:00:00.000Z"
      }
    ],
    "count": 1
  }
}
```

## Error Responses

### Authentication Errors

**401 Unauthorized:**
```json
{
  "status": "fail",
  "message": "Access token is required"
}
```

**401 Unauthorized:**
```json
{
  "status": "fail",
  "message": "Invalid token"
}
```

### Validation Errors

**400 Bad Request:**
```json
{
  "status": "fail",
  "message": "Exercise name and duration are required"
}
```

**400 Bad Request:**
```json
{
  "status": "fail",
  "message": "Invalid workout ID"
}
```

### Not Found Errors

**404 Not Found:**
```json
{
  "status": "fail",
  "message": "Workout not found"
}
```

### Server Errors

**500 Internal Server Error:**
```json
{
  "status": "error",
  "message": "Something went wrong!"
}
```

## Data Models

### Workout Schema

```javascript
{
  _id: ObjectId,                    // Auto-generated
  userId: ObjectId,                 // Reference to User
  exerciseName: String,             // Required, max 100 characters
  workoutType: String,              // Enum: cardio|strength|flexibility|sports|other
  duration: Number,                 // Required, 1-600 minutes
  caloriesBurned: Number,           // Required, 0-5000 calories
  date: Date,                       // Required, defaults to now
  sets: Number,                     // Optional, 1-50
  reps: Number,                     // Optional, 1-1000
  weight: Number,                   // Optional, 0.5-500 kg
  notes: String,                    // Optional, max 500 characters
  intensityLevel: String,           // Enum: low|moderate|high|extreme
  createdAt: Date,                  // Auto-generated
  updatedAt: Date                   // Auto-generated
}
```

## Flutter Integration

For Flutter app integration, use these key endpoints:

1. **Login:** `POST /api/v1/auth_user/client_login`
2. **Create Workout:** `POST /api/v1/workouts`
3. **Get Workouts:** `GET /api/v1/workouts?limit=20&page=1`
4. **Get Stats:** `GET /api/v1/workouts/stats`
5. **Get Recent:** `GET /api/v1/workouts/recent`

### Example Flutter HTTP Request

```dart
// Create workout example
final response = await http.post(
  Uri.parse('http://10.0.2.2:3000/api/v1/workouts'),
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $accessToken',
  },
  body: jsonEncode({
    'exerciseName': 'Morning Run',
    'workoutType': 'cardio',
    'duration': 30,
    'caloriesBurned': 300,
    'intensityLevel': 'moderate'
  }),
);
```

## Testing

Use the provided PowerShell test script to test all endpoints:

```powershell
.\test-workout-api.ps1
```

This script tests:
- ✅ Server health
- ✅ User registration and authentication
- ✅ Workout CRUD operations
- ✅ Authentication protection
- ✅ Data validation
- ✅ Statistics endpoints
- ✅ Pagination and filtering

## Security Features

- 🔒 JWT-based authentication
- 🔒 User ownership validation (users can only access their own workouts)
- 🔒 Input validation and sanitization
- 🔒 Rate limiting (configured in server)
- 🔒 CORS protection
- 🔒 Helmet security headers

## Performance Features

- ⚡ Database indexes for efficient querying
- ⚡ Pagination for large datasets
- ⚡ Aggregation pipelines for statistics
- ⚡ Optimized queries with field selection

## Future Enhancements

The workout tracking system is designed to be easily extensible:

1. **Social Features:** Share workouts with friends
2. **Challenges:** Create and join workout challenges
3. **AI Recommendations:** Personalized workout suggestions
4. **Wearable Integration:** Sync with fitness trackers
5. **Nutrition Integration:** Link with meal tracking
6. **Progress Photos:** Upload and track visual progress

---

# System Architecture of NutriWork

## Overview

NutriWork is a full-stack fitness tracking application built with a modern, scalable architecture that supports both online and offline functionality. The system follows a microservices-inspired design with clear separation of concerns.

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    NutriWork System Architecture                 │
├─────────────────────────────────────────────────────────────────┤
│  Frontend Layer (Flutter)                                      │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐              │
│  │    UI/UX    │ │   State     │ │   Local     │              │
│  │  Components │ │ Management  │ │  Storage    │              │
│  │             │ │ (Provider)  │ │   (Hive)    │              │
│  └─────────────┘ └─────────────┘ └─────────────┘              │
├─────────────────────────────────────────────────────────────────┤
│  API Gateway & Middleware Layer                                │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐              │
│  │    CORS     │ │     JWT     │ │    Rate     │              │
│  │  Handling   │ │    Auth     │ │  Limiting   │              │
│  └─────────────┘ └─────────────┘ └─────────────┘              │
├─────────────────────────────────────────────────────────────────┤
│  Backend Services Layer (Node.js)                              │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐              │
│  │   Auth      │ │   Workout   │ │   Analytics │              │
│  │  Service    │ │   Service   │ │   Service   │              │
│  └─────────────┘ └─────────────┘ └─────────────┘              │
├─────────────────────────────────────────────────────────────────┤
│  Data Persistence Layer                                        │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐              │
│  │  MongoDB    │ │   Redis     │ │   File      │              │
│  │  Database   │ │   Cache     │ │  Storage    │              │
│  │             │ │ (Optional)  │ │ (Optional)  │              │
│  └─────────────┘ └─────────────┘ └─────────────┘              │
└─────────────────────────────────────────────────────────────────┘
```

## Detailed System Components

### 1. Frontend Architecture (Flutter)

#### **UI Layer**
```
lib/
├── pages/                  # Screen components
│   ├── auth/              # Authentication screens
│   ├── dashboard/         # Main dashboard
│   ├── workout/           # Workout-related screens
│   └── profile/           # User profile screens
├── widgets/               # Reusable UI components
│   ├── cards/            # Custom card widgets
│   ├── forms/            # Form components
│   └── charts/           # Data visualization
└── theme/                # App theming and styles
```

#### **State Management Layer**
```
lib/
├── notifiers/             # State management (Provider)
│   ├── auth_notifier.dart
│   ├── workout_notifier.dart
│   └── stats_notifier.dart
├── models/               # Data models
│   ├── user.dart
│   ├── workout.dart
│   └── local_user.dart
└── services/            # Business logic
    ├── data_service.dart
    ├── api_service.dart
    └── local_storage_service.dart
```

#### **Data Flow Architecture**
```
User Interaction
       ↓
   UI Components
       ↓
 State Notifiers (Provider)
       ↓
   Data Services
       ↓
┌─────────────────┐
│ Online Mode     │ ← → API Client → Backend
├─────────────────┤
│ Offline Mode    │ ← → Local Storage (Hive)
└─────────────────┘
```

### 2. Backend Architecture (Node.js)

#### **Server Structure**
```
backend/
├── src/
│   ├── server.js          # Main application entry
│   ├── config/           # Configuration files
│   │   ├── database.js   # MongoDB connection
│   │   └── cors.js       # CORS configuration
│   ├── middleware/       # Express middleware
│   │   ├── auth.js       # JWT authentication
│   │   ├── validate.js   # Input validation
│   │   ├── rateLimiter.js # Rate limiting
│   │   └── errorHandler.js # Global error handling
│   ├── routes/           # API route definitions
│   │   ├── auth.js       # Authentication routes
│   │   ├── frontendAuth.js # Flutter-compatible auth
│   │   ├── workouts.js   # Workout CRUD operations
│   │   └── analytics.js  # Statistics and analytics
│   ├── controllers/      # Business logic controllers
│   │   ├── authController.js
│   │   ├── workoutController.js
│   │   └── analyticsController.js
│   ├── models/          # Database schemas (Mongoose)
│   │   ├── User.js      # User schema
│   │   ├── Workout.js   # Workout schema
│   │   └── Session.js   # Session management
│   ├── utils/           # Helper utilities
│   │   ├── apiError.js  # Custom error classes
│   │   ├── catchAsync.js # Async error wrapper
│   │   └── validators.js # Input validators
│   └── constants/       # Application constants
└── tests/              # API testing scripts
```

#### **API Layer Architecture**
```
HTTP Request
       ↓
Express Router
       ↓
Authentication Middleware
       ↓
Validation Middleware
       ↓
Rate Limiting Middleware
       ↓
Route Controller
       ↓
Business Logic Layer
       ↓
Database Layer (MongoDB)
       ↓
Response Formation
       ↓
HTTP Response
```

### 3. Database Schema Architecture

#### **User Collection**
```javascript
User {
  _id: ObjectId,
  username: String (unique),
  email: String (unique),
  password: String (hashed),
  profile: {
    age: Number,
    weight: Number,
    height: Number,
    activityLevel: String
  },
  stats: {
    totalWorkouts: Number,
    currentStreak: Number,
    totalCaloriesBurned: Number
  },
  refreshTokens: [String],
  createdAt: Date,
  updatedAt: Date
}
```

#### **Workout Collection**
```javascript
Workout {
  _id: ObjectId,
  userId: ObjectId (ref: User),
  exerciseName: String,
  workoutType: String,
  duration: Number,
  caloriesBurned: Number,
  details: {
    sets: Number,
    reps: Number,
    weight: Number,
    distance: Number
  },
  intensityLevel: String,
  date: Date,
  createdAt: Date
}
```

### 4. Security Architecture

#### **Authentication Flow**
```
1. User Registration/Login
   ↓
2. Password Hashing (bcrypt)
   ↓
3. JWT Token Generation
   ↓
4. Token Storage (Frontend)
   ↓
5. Request Authentication
   ↓
6. Token Validation
   ↓
7. User Authorization
```

#### **Security Layers**
- **Input Validation**: Joi schema validation
- **Authentication**: JWT-based stateless auth
- **Authorization**: Role-based access control
- **Rate Limiting**: Prevent abuse and DoS
- **CORS**: Cross-origin request security
- **Data Encryption**: Password hashing, sensitive data protection

### 5. Data Synchronization Architecture

#### **Hybrid Online/Offline Strategy**
```
┌─────────────────────────────────────────┐
│            Frontend App                 │
├─────────────────────────────────────────┤
│  Local Storage (Hive)                   │
│  ┌─────────────┐ ┌─────────────────────┐ │
│  │  Immediate  │ │    Sync Queue       │ │
│  │   Storage   │ │  (Pending Actions)  │ │
│  └─────────────┘ └─────────────────────┘ │
├─────────────────────────────────────────┤
│         Network Layer                   │
│  ┌─────────────┐ ┌─────────────────────┐ │
│  │ Online Mode │ │   Offline Mode      │ │
│  │ (Live API)  │ │ (Local Storage)     │ │
│  └─────────────┘ └─────────────────────┘ │
├─────────────────────────────────────────┤
│         Backend API                     │
└─────────────────────────────────────────┘
```

#### **Sync Strategy**
1. **Write-First Local**: All changes saved locally first
2. **Background Sync**: API calls happen in background
3. **Conflict Resolution**: Last-write-wins strategy
4. **Retry Logic**: Failed requests queued for retry
5. **Status Indicators**: UI shows sync status

### 6. Scalability Architecture

#### **Horizontal Scaling Options**
```
Load Balancer (Nginx)
       ↓
┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│   Node.js   │ │   Node.js   │ │   Node.js   │
│  Instance 1 │ │  Instance 2 │ │  Instance N │
└─────────────┘ └─────────────┘ └─────────────┘
       ↓               ↓               ↓
┌─────────────────────────────────────────────┐
│        MongoDB Cluster (Replica Set)        │
│  ┌─────────┐ ┌─────────┐ ┌─────────────────┐│
│  │ Primary │ │Secondary│ │   Secondary     ││
│  │  Node   │ │  Node   │ │     Node        ││
│  └─────────┘ └─────────┘ └─────────────────┘│
└─────────────────────────────────────────────┘
```

### 7. Development & Deployment Architecture

#### **Development Environment**
```
Developer Machine
├── Flutter Development
│   ├── Android Studio/VS Code
│   ├── Flutter SDK
│   └── Android Emulator
├── Backend Development
│   ├── Node.js Runtime
│   ├── MongoDB Local Instance
│   └── API Testing Tools
└── Version Control (Git)
```

#### **Production Deployment**
```
┌─────────────────┐  ┌─────────────────┐
│   Mobile App    │  │   Web Dashboard │
│  (Play Store/   │  │   (Optional)    │
│   App Store)    │  │                 │
└─────────────────┘  └─────────────────┘
        ↓                      ↓
┌─────────────────────────────────────────┐
│          API Gateway/CDN                │
│         (Cloudflare/AWS)                │
└─────────────────────────────────────────┘
        ↓
┌─────────────────────────────────────────┐
│       Backend Services                  │
│    (Heroku/DigitalOcean/AWS)           │
└─────────────────────────────────────────┘
        ↓
┌─────────────────────────────────────────┐
│       Database Layer                    │
│    (MongoDB Atlas/Self-hosted)          │
└─────────────────────────────────────────┘
```

### 8. Performance Architecture

#### **Optimization Strategies**
1. **Database Optimization**
   - Proper indexing on frequently queried fields
   - Aggregation pipelines for analytics
   - Connection pooling

2. **API Optimization**
   - Response caching (Redis optional)
   - Pagination for large datasets
   - Compression middleware

3. **Frontend Optimization**
   - Lazy loading of screens
   - Image optimization
   - Local caching strategies

4. **Network Optimization**
   - Request batching
   - Efficient data structures
   - Minimal payload sizes

### 9. Monitoring & Analytics Architecture

#### **Logging Strategy**
```
Application Logs
       ↓
┌─────────────────┐
│ Winston Logger  │ → File System
│   (Backend)     │ → Console Output
└─────────────────┘ → External Service (Optional)

Flutter Logs
       ↓
┌─────────────────┐
│ Debug Console   │ → Development Logs
│ Crash Reporting │ → Production Monitoring
└─────────────────┘
```

## Technology Stack Summary

### **Frontend**
- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **Local Storage**: Hive
- **HTTP Client**: Dio/http
- **Charts**: fl_chart

### **Backend**
- **Runtime**: Node.js
- **Framework**: Express.js
- **Database**: MongoDB + Mongoose
- **Authentication**: JWT
- **Validation**: Joi
- **Testing**: Custom PowerShell scripts

### **DevOps & Tools**
- **Version Control**: Git/GitHub
- **API Testing**: Postman, Custom scripts
- **Documentation**: Markdown
- **Environment**: Docker (optional)

This architecture provides a robust, scalable foundation for the NutriWork application with clear separation of concerns, offline capability, and room for future enhancements.

---

# Database Schema – Page 19

## MongoDB Collections Overview

NutriWork uses MongoDB with optimized schemas for performance and scalability:

### User Collection Schema
```javascript
{
  _id: ObjectId,                    // Primary key
  username: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    minlength: 3,
    maxlength: 30
  },
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    validate: [validator.isEmail, 'Please provide a valid email']
  },
  password: {
    type: String,
    required: true,
    minlength: 6,
    select: false                   // Never return password in queries
  },
  fullName: {
    type: String,
    trim: true,
    maxlength: 100
  },
  profile: {
    age: { type: Number, min: 13, max: 120 },
    weight: { type: Number, min: 20, max: 500 },     // kg
    height: { type: Number, min: 50, max: 300 },     // cm
    gender: { type: String, enum: ['male', 'female', 'other'] },
    activityLevel: { 
      type: String, 
      enum: ['sedentary', 'light', 'moderate', 'active', 'very_active'],
      default: 'moderate'
    },
    profilePicture: String
  },
  preferences: {
    units: {
      weight: { type: String, enum: ['kg', 'lbs'], default: 'kg' },
      distance: { type: String, enum: ['km', 'miles'], default: 'km' }
    },
    notifications: {
      workoutReminders: { type: Boolean, default: true },
      achievementAlerts: { type: Boolean, default: true }
    }
  },
  stats: {
    totalWorkouts: { type: Number, default: 0 },
    totalCaloriesBurned: { type: Number, default: 0 },
    totalDuration: { type: Number, default: 0 },      // minutes
    currentStreak: { type: Number, default: 0 },
    longestStreak: { type: Number, default: 0 },
    lastWorkoutDate: Date
  },
  refreshTokens: [String],          // Array of valid refresh tokens
  isActive: { type: Boolean, default: true },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
}

// Indexes for Performance
db.users.createIndex({ "email": 1 }, { unique: true })
db.users.createIndex({ "username": 1 }, { unique: true })
```

### Workout Collection Schema
```javascript
{
  _id: ObjectId,                    // Primary key
  userId: {
    type: ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  exerciseName: {
    type: String,
    required: true,
    trim: true,
    maxlength: 100
  },
  workoutType: {
    type: String,
    enum: ['cardio', 'strength', 'flexibility', 'sports', 'other'],
    default: 'other'
  },
  duration: {                       // Duration in minutes
    type: Number,
    required: true,
    min: 1,
    max: 600
  },
  caloriesBurned: {
    type: Number,
    required: true,
    min: 0,
    max: 5000
  },
  date: {
    type: Date,
    required: true,
    default: Date.now,
    index: true
  },
  details: {
    sets: { type: Number, min: 1, max: 50 },
    reps: { type: Number, min: 1, max: 1000 },
    weight: { type: Number, min: 0.5, max: 500 },    // kg
    distance: { type: Number, min: 0.1, max: 1000 }, // km
    restTime: { type: Number, min: 0, max: 300 }     // seconds
  },
  intensityLevel: {
    type: String,
    enum: ['low', 'moderate', 'high', 'extreme'],
    default: 'moderate'
  },
  notes: {
    type: String,
    maxlength: 500,
    trim: true
  },
  tags: [String],                   // Custom tags for workouts
  location: {
    name: String,
    coordinates: {
      latitude: Number,
      longitude: Number
    }
  },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
}

// Compound Indexes for Efficient Queries
db.workouts.createIndex({ "userId": 1, "date": -1 })
db.workouts.createIndex({ "userId": 1, "workoutType": 1, "date": -1 })
db.workouts.createIndex({ "userId": 1, "exerciseName": 1 })
```

### Session Collection Schema (For Advanced Session Management)
```javascript
{
  _id: ObjectId,
  userId: { type: ObjectId, ref: 'User', required: true },
  refreshToken: { type: String, required: true, unique: true },
  deviceInfo: {
    deviceType: String,             // mobile, web, desktop
    deviceName: String,
    userAgent: String,
    ipAddress: String
  },
  isActive: { type: Boolean, default: true },
  expiresAt: { type: Date, required: true },
  createdAt: { type: Date, default: Date.now }
}

// TTL Index for Automatic Cleanup
db.sessions.createIndex({ "expiresAt": 1 }, { expireAfterSeconds: 0 })
```

---

# User Journey Flowchart – Page 20

## Complete User Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    NutriWork User Journey                       │
└─────────────────────────────────────────────────────────────────┘

[App Launch] → {First Time?} 
                    ↓ Yes              ↓ No
            [Registration] → [Login Screen]
                    ↓                   ↓
            [Enter Details] → [Enter Credentials]
                    ↓                   ↓
            [Backend API] ← [Backend API]
                    ↓                   ↓
            {Success?} ← → {Success?}
                    ↓ Yes              ↓ Yes
            [Store JWT] ← [Store JWT]
                    ↓                   ↓
                [Main Dashboard] ← ─ ─ ─ ┘
                    ↓
            ┌─────────────────────────────┐
            │     Dashboard Options       │
            ├─────────────────────────────┤
            │ • Recent Workouts           │
            │ • Quick Actions             │
            │ • Statistics Overview       │
            │ • Profile Management        │
            └─────────────────────────────┘
                    ↓
        ┌─────────────┬─────────────┬─────────────┐
        ↓             ↓             ↓             ↓
[Log Workout] [View History] [Statistics] [Profile]
        ↓             ↓             ↓             ↓
    
┌─────────────────────────────────────────────────────────────────┐
│                    Workout Logging Flow                         │
├─────────────────────────────────────────────────────────────────┤
│ [Search Exercise] → [Select Type] → [Enter Details]            │
│         ↓               ↓               ↓                       │
│ [Auto-complete] → [Cardio/Strength] → [Sets/Reps/Duration]     │
│         ↓               ↓               ↓                       │
│ [Popular Exercises] → [Templates] → [Calculate Calories]       │
│         ↓               ↓               ↓                       │
│ [Add Notes] → [Save Locally] → [Sync to Backend]              │
│         ↓               ↓               ↓                       │
│ [Optional] → [Immediate] → {Network Available?}                │
│         ↓               ↓               ↓ Yes     ↓ No          │
│ [Geo Location] → [Success] → [Upload] → [Queue]               │
│         ↓               ↓               ↓         ↓             │
│ [Photo Attach] → [Update Stats] → [Confirm] → [Retry Later]   │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    Workout History Flow                         │
├─────────────────────────────────────────────────────────────────┤
│ [History Screen] → {Data Source?}                              │
│         ↓               ↓ Online        ↓ Offline              │
│ [Filter Options] → [API Request] → [Local Storage]            │
│         ↓               ↓               ↓                       │
│ [Date Range] → [Paginated List] ← [Cached Data]               │
│ [Workout Type] → [Real-time Data] ← [Basic List]              │
│ [Search] → [Advanced Filters] ← [Simple Filter]               │
│         ↓               ↓               ↓                       │
│ [Select Workout] → [Workout Details] → [Actions]              │
│         ↓               ↓               ↓                       │
│ [Edit] [Delete] [Share] → [Confirmation] → [Update/Remove]     │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    Statistics & Analytics                       │
├─────────────────────────────────────────────────────────────────┤
│ [Stats Dashboard] → {Data Calculation}                         │
│         ↓               ↓ Online           ↓ Offline           │
│ [Time Periods] → [Server Analytics] → [Local Calculation]      │
│         ↓               ↓                   ↓                   │
│ [Weekly/Monthly] → [Advanced Metrics] → [Basic Stats]          │
│ [Custom Range] → [Trend Analysis] → [Simple Totals]           │
│         ↓               ↓                   ↓                   │
│ [Workout Trends] → [Comparative Data] → [Personal Records]     │
│         ↓               ↓                   ↓                   │
│ [Calorie Burn] → [Goal Progress] → [Streak Counter]           │
│         ↓               ↓                   ↓                   │
│ [Exercise Types] → [Achievement Badges] → [Visual Charts]      │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    Offline/Online Sync                          │
├─────────────────────────────────────────────────────────────────┤
│ [User Action] → [Save Locally First]                           │
│         ↓               ↓                                       │
│ [Immediate UI] → {Network Check}                               │
│         ↓               ↓ Available      ↓ Unavailable         │
│ [Optimistic Update] → [API Call] → [Queue Action]             │
│         ↓               ↓ Success        ↓ Failed              │
│ [Sync Indicator] → [Confirm Success] → [Retry Queue]          │
│         ↓               ↓                 ↓                     │
│ [Background Sync] → [Update Local] → [Mark Pending]           │
│         ↓               ↓                 ↓                     │
│ [Connection Monitor] → [Remove Queue] → [Show Offline]        │
│         ↓               ↓                 ↓                     │
│ [Auto Retry] → [Sync Complete] ← [Manual Retry]               │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    Error Handling Flow                          │
├─────────────────────────────────────────────────────────────────┤
│ [User Action] → {Error Occurs?}                               │
│         ↓ No            ↓ Yes                                  │
│ [Success Flow] → [Error Type Check]                           │
│         ↓               ↓                                       │
│ [Continue] → [Network] [Auth] [Validation] [Server]           │
│         ↓       ↓       ↓      ↓           ↓                   │
│ [Normal] → [Offline] [Login] [Form] [Retry]                   │
│         ↓       ↓       ↓      ↓      ↓                        │
│ [Success] → [Queue] [Redirect] [Fix] [Backoff]                │
│         ↓       ↓       ↓      ↓      ↓                        │
│ [Update UI] → [Show Message] [Highlight] [Progress]           │
└─────────────────────────────────────────────────────────────────┘
```

## User Experience Principles

### 1. **Offline-First Design**
- All actions work offline immediately
- Background synchronization when online
- Clear indicators of sync status

### 2. **Progressive Enhancement**
- Basic functionality always available
- Enhanced features when API is accessible
- Graceful degradation of complex features

### 3. **Intuitive Navigation**
- Logical flow between screens
- Consistent UI patterns
- Quick access to frequent actions

### 4. **Performance Optimization**
- Local-first data access
- Lazy loading of heavy content
- Efficient data structures

### 5. **Error Recovery**
- Clear error messages
- Multiple retry mechanisms
- Fallback options for critical paths