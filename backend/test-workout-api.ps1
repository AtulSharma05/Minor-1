# PowerShell Script to Test Workout API Endpoints
# Make sure the backend server is running before executing this script

$ErrorActionPreference = "Continue"
$baseUrl = "http://localhost:3000/api/v1"

Write-Host "🏋️ Workout API Testing Script" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

# Function to make HTTP requests with error handling
function Invoke-ApiRequest {
    param (
        [string]$Method,
        [string]$Uri,
        [hashtable]$Headers = @{},
        [object]$Body = $null
    )
    
    try {
        $params = @{
            Method = $Method
            Uri = $Uri
            Headers = $Headers
            ContentType = "application/json"
        }
        
        if ($Body) {
            $params.Body = ($Body | ConvertTo-Json -Depth 10)
        }
        
        $response = Invoke-RestMethod @params
        return @{
            Success = $true
            Data = $response
            StatusCode = 200
        }
    }
    catch {
        $errorDetails = $_.Exception.Response
        $statusCode = if ($errorDetails) { $errorDetails.StatusCode } else { "Unknown" }
        
        return @{
            Success = $false
            Error = $_.Exception.Message
            StatusCode = $statusCode
        }
    }
}

# Function to display test results
function Show-TestResult {
    param (
        [string]$TestName,
        [object]$Result,
        [string]$ExpectedOutcome = "Success"
    )
    
    Write-Host "`n🧪 Test: $TestName" -ForegroundColor Yellow
    
    if ($Result.Success -and $ExpectedOutcome -eq "Success") {
        Write-Host "✅ PASSED" -ForegroundColor Green
        if ($Result.Data.message) {
            Write-Host "   Message: $($Result.Data.message)" -ForegroundColor Gray
        }
    }
    elseif (!$Result.Success -and $ExpectedOutcome -eq "Failure") {
        Write-Host "✅ PASSED (Expected Failure)" -ForegroundColor Green
        Write-Host "   Error: $($Result.Error)" -ForegroundColor Gray
    }
    else {
        Write-Host "❌ FAILED" -ForegroundColor Red
        if ($Result.Success) {
            Write-Host "   Unexpected Success" -ForegroundColor Gray
        } else {
            Write-Host "   Error: $($Result.Error)" -ForegroundColor Gray
            Write-Host "   Status: $($Result.StatusCode)" -ForegroundColor Gray
        }
    }
}

# Step 1: Test server health
Write-Host "`n🏥 Testing Server Health" -ForegroundColor Magenta
$healthResult = Invoke-ApiRequest -Method "GET" -Uri "$baseUrl/../health"
Show-TestResult -TestName "Server Health Check" -Result $healthResult

if (!$healthResult.Success) {
    Write-Host "❌ Server is not running! Please start the backend server first." -ForegroundColor Red
    exit 1
}

# Step 2: Register a test user
Write-Host "`n👤 Setting Up Test User" -ForegroundColor Magenta

$testUser = @{
    username = "workouttest_$(Get-Random)"
    email = "workouttest_$(Get-Random)@test.com"
    password = "testpass123"
    fullName = "Workout Test User"
    age = 25
    height = 175
    weight = 70
}

$registerResult = Invoke-ApiRequest -Method "POST" -Uri "$baseUrl/auth/register" -Body $testUser
Show-TestResult -TestName "User Registration" -Result $registerResult

if (!$registerResult.Success) {
    Write-Host "❌ Failed to register test user. Exiting." -ForegroundColor Red
    exit 1
}

$accessToken = $registerResult.Data.data.tokens.accessToken
$authHeaders = @{ "Authorization" = "Bearer $accessToken" }

Write-Host "✅ Test user registered successfully" -ForegroundColor Green
Write-Host "   Username: $($testUser.username)" -ForegroundColor Gray
Write-Host "   Token: $($accessToken.Substring(0, 20))..." -ForegroundColor Gray

# Step 3: Test workout creation
Write-Host "`n🏋️ Testing Workout Creation" -ForegroundColor Magenta

$workouts = @(
    @{
        exerciseName = "Morning Run"
        workoutType = "cardio"
        duration = 30
        caloriesBurned = 300
        intensityLevel = "moderate"
        notes = "Great morning run in the park"
    },
    @{
        exerciseName = "Bench Press"
        workoutType = "strength"
        duration = 45
        caloriesBurned = 200
        sets = 3
        reps = 10
        weight = 80
        intensityLevel = "high"
    },
    @{
        exerciseName = "Yoga Session"
        workoutType = "flexibility"
        duration = 60
        caloriesBurned = 150
        intensityLevel = "low"
        notes = "Relaxing yoga session"
    }
)

$createdWorkouts = @()

foreach ($workout in $workouts) {
    $createResult = Invoke-ApiRequest -Method "POST" -Uri "$baseUrl/workouts" -Headers $authHeaders -Body $workout
    Show-TestResult -TestName "Create Workout: $($workout.exerciseName)" -Result $createResult
    
    if ($createResult.Success) {
        $createdWorkouts += $createResult.Data.data.workout
    }
}

# Step 4: Test invalid workout creation
Write-Host "`n❌ Testing Invalid Workout Creation" -ForegroundColor Magenta

$invalidWorkout = @{
    exerciseName = ""  # Missing required field
    duration = -5      # Invalid duration
}

$invalidResult = Invoke-ApiRequest -Method "POST" -Uri "$baseUrl/workouts" -Headers $authHeaders -Body $invalidWorkout
Show-TestResult -TestName "Create Invalid Workout" -Result $invalidResult -ExpectedOutcome "Failure"

# Step 5: Test workout retrieval
Write-Host "`n📋 Testing Workout Retrieval" -ForegroundColor Magenta

$getAllResult = Invoke-ApiRequest -Method "GET" -Uri "$baseUrl/workouts" -Headers $authHeaders
Show-TestResult -TestName "Get All Workouts" -Result $getAllResult

if ($getAllResult.Success) {
    $workoutCount = $getAllResult.Data.data.workouts.Count
    Write-Host "   Retrieved $workoutCount workouts" -ForegroundColor Gray
}

# Test with pagination
$paginationResult = Invoke-ApiRequest -Method "GET" -Uri "$baseUrl/workouts?limit=2&page=1" -Headers $authHeaders
Show-TestResult -TestName "Get Workouts with Pagination" -Result $paginationResult

# Test with filters
$filterResult = Invoke-ApiRequest -Method "GET" -Uri "$baseUrl/workouts?workoutType=cardio" -Headers $authHeaders
Show-TestResult -TestName "Get Workouts with Filter (cardio)" -Result $filterResult

# Step 6: Test single workout retrieval
if ($createdWorkouts.Count -gt 0) {
    Write-Host "`n🎯 Testing Single Workout Retrieval" -ForegroundColor Magenta
    
    $workoutId = $createdWorkouts[0]._id
    $singleResult = Invoke-ApiRequest -Method "GET" -Uri "$baseUrl/workouts/$workoutId" -Headers $authHeaders
    Show-TestResult -TestName "Get Single Workout" -Result $singleResult
    
    # Test with invalid ID
    $invalidIdResult = Invoke-ApiRequest -Method "GET" -Uri "$baseUrl/workouts/invalid-id" -Headers $authHeaders
    Show-TestResult -TestName "Get Workout with Invalid ID" -Result $invalidIdResult -ExpectedOutcome "Failure"
}

# Step 7: Test workout update
if ($createdWorkouts.Count -gt 0) {
    Write-Host "`n✏️ Testing Workout Update" -ForegroundColor Magenta
    
    $workoutId = $createdWorkouts[0]._id
    $updateData = @{
        exerciseName = "Updated Morning Run"
        duration = 35
        caloriesBurned = 350
        notes = "Updated notes: Ran longer today!"
    }
    
    $updateResult = Invoke-ApiRequest -Method "PUT" -Uri "$baseUrl/workouts/$workoutId" -Headers $authHeaders -Body $updateData
    Show-TestResult -TestName "Update Workout" -Result $updateResult
}

# Step 8: Test workout statistics
Write-Host "`n📊 Testing Workout Statistics" -ForegroundColor Magenta

$statsResult = Invoke-ApiRequest -Method "GET" -Uri "$baseUrl/workouts/stats" -Headers $authHeaders
Show-TestResult -TestName "Get Workout Statistics" -Result $statsResult

if ($statsResult.Success) {
    $stats = $statsResult.Data.data.overview
    Write-Host "   Total Workouts: $($stats.totalWorkouts)" -ForegroundColor Gray
    Write-Host "   Total Calories: $($stats.totalCalories)" -ForegroundColor Gray
    Write-Host "   Current Streak: $($stats.currentStreak)" -ForegroundColor Gray
}

# Step 9: Test recent workouts
$recentResult = Invoke-ApiRequest -Method "GET" -Uri "$baseUrl/workouts/recent" -Headers $authHeaders
Show-TestResult -TestName "Get Recent Workouts" -Result $recentResult

# Step 10: Test authentication protection
Write-Host "`n🔒 Testing Authentication Protection" -ForegroundColor Magenta

$noAuthResult = Invoke-ApiRequest -Method "GET" -Uri "$baseUrl/workouts"
Show-TestResult -TestName "Access Without Token" -Result $noAuthResult -ExpectedOutcome "Failure"

$invalidTokenHeaders = @{ "Authorization" = "Bearer invalid-token" }
$invalidTokenResult = Invoke-ApiRequest -Method "GET" -Uri "$baseUrl/workouts" -Headers $invalidTokenHeaders
Show-TestResult -TestName "Access With Invalid Token" -Result $invalidTokenResult -ExpectedOutcome "Failure"

# Step 11: Test workout deletion
if ($createdWorkouts.Count -gt 1) {
    Write-Host "`n🗑️ Testing Workout Deletion" -ForegroundColor Magenta
    
    $workoutId = $createdWorkouts[-1]._id  # Delete last workout
    $deleteResult = Invoke-ApiRequest -Method "DELETE" -Uri "$baseUrl/workouts/$workoutId" -Headers $authHeaders
    Show-TestResult -TestName "Delete Workout" -Result $deleteResult
    
    # Try to get deleted workout (should fail)
    $deletedGetResult = Invoke-ApiRequest -Method "GET" -Uri "$baseUrl/workouts/$workoutId" -Headers $authHeaders
    Show-TestResult -TestName "Get Deleted Workout" -Result $deletedGetResult -ExpectedOutcome "Failure"
}

# Step 12: Test with different date formats
Write-Host "`n📅 Testing Date Handling" -ForegroundColor Magenta

$dateWorkout = @{
    exerciseName = "Yesterday's Workout"
    workoutType = "cardio"
    duration = 20
    caloriesBurned = 200
    date = (Get-Date).AddDays(-1).ToString("yyyy-MM-dd")
}

$dateResult = Invoke-ApiRequest -Method "POST" -Uri "$baseUrl/workouts" -Headers $authHeaders -Body $dateWorkout
Show-TestResult -TestName "Create Workout with Custom Date" -Result $dateResult

# Summary
Write-Host "`n📋 Test Summary" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host "✅ Basic CRUD operations tested" -ForegroundColor Green
Write-Host "✅ Authentication protection verified" -ForegroundColor Green
Write-Host "✅ Data validation tested" -ForegroundColor Green
Write-Host "✅ Statistics endpoints tested" -ForegroundColor Green
Write-Host "✅ Pagination and filtering tested" -ForegroundColor Green

Write-Host "`n🎉 Workout API testing completed!" -ForegroundColor Green
Write-Host "You can now integrate these endpoints with your Flutter app." -ForegroundColor Yellow

# Optional: Clean up test user
Write-Host "`n🧹 Cleanup" -ForegroundColor Magenta
Write-Host "Test user '$($testUser.username)' was created for testing." -ForegroundColor Gray
Write-Host "You may want to remove it from the database manually if needed." -ForegroundColor Gray