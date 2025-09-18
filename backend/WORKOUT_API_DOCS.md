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