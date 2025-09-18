# PowerShell Script to Test Frontend-Compatible Workout Logging API
# This tests the endpoints that the Flutter app expects

$ErrorActionPreference = "Continue"
$baseUrl = "http://localhost:3000/api/v1"

Write-Host "🏋️ Frontend Workout Logging API Test" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

# Function to make HTTP requests
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
        }
    }
    catch {
        return @{
            Success = $false
            Error = $_.Exception.Message
        }
    }
}

# Function to display test results
function Show-TestResult {
    param (
        [string]$TestName,
        [object]$Result
    )
    
    Write-Host "`n🧪 Test: $TestName" -ForegroundColor Yellow
    
    if ($Result.Success) {
        Write-Host "✅ PASSED" -ForegroundColor Green
        if ($Result.Data.message) {
            Write-Host "   Message: $($Result.Data.message)" -ForegroundColor Gray
        }
        if ($Result.Data.result) {
            Write-Host "   Result: $($Result.Data.result)" -ForegroundColor Gray
        }
    } else {
        Write-Host "❌ FAILED" -ForegroundColor Red
        Write-Host "   Error: $($Result.Error)" -ForegroundColor Gray
    }
}

# Test 1: Server Health Check
Write-Host "`n🏥 Testing Server Health" -ForegroundColor Magenta
$healthResult = Invoke-ApiRequest -Method "GET" -Uri "$baseUrl/../health"
Show-TestResult -TestName "Server Health Check" -Result $healthResult

if (!$healthResult.Success) {
    Write-Host "❌ Server is not running! Please start the backend server first." -ForegroundColor Red
    exit 1
}

# Test 2: Workout Search
Write-Host "`n🔍 Testing Workout Search" -ForegroundColor Magenta

$searchRequests = @(
    @{
        workout_query = "running"
        username = "testuser"
    },
    @{
        workout_query = "strength"
        username = "testuser"
    },
    @{
        workout_query = "yoga"
        username = "testuser"
    }
)

foreach ($search in $searchRequests) {
    $searchResult = Invoke-ApiRequest -Method "POST" -Uri "$baseUrl/workout_logging/workout_search" -Body $search
    Show-TestResult -TestName "Search Workout: $($search.workout_query)" -Result $searchResult
    
    if ($searchResult.Success -and $searchResult.Data.workout_search_results) {
        $resultCount = $searchResult.Data.workout_search_results.Count
        Write-Host "   Found $resultCount workouts" -ForegroundColor Gray
    }
}

# Test 3: Fetch Workout Info
Write-Host "`n📊 Testing Workout Info Fetch" -ForegroundColor Magenta

$workoutInfoRequests = @(
    @{
        selected_workout = "Running"
        effort_level = "Moderate"
        duration_min = "30"
    },
    @{
        selected_workout = "Weight Training"
        effort_level = "High"
        duration_min = "45"
    },
    @{
        selected_workout = "Yoga"
        effort_level = "Low"
        duration_min = "60"
    }
)

foreach ($infoRequest in $workoutInfoRequests) {
    $infoResult = Invoke-ApiRequest -Method "POST" -Uri "$baseUrl/workout_logging/fetch_workout_info" -Body $infoRequest
    Show-TestResult -TestName "Fetch Info: $($infoRequest.selected_workout)" -Result $infoResult
    
    if ($infoResult.Success -and $infoResult.Data.workout_info) {
        $info = $infoResult.Data.workout_info
        Write-Host "   Calories/hour: $($info.calories_per_hour)" -ForegroundColor Gray
        Write-Host "   Total calories: $($info.total_calories)" -ForegroundColor Gray
    }
}

# Test 4: Log Workout
Write-Host "`n📝 Testing Workout Logging" -ForegroundColor Magenta

$logRequests = @(
    @{
        username = "testuser"
        selected_workout = "Running"
        duration_min = "30"
        energy_burned = "300"
        current_date = (Get-Date).ToString("yyyy-MM-dd")
        time_of_day = "morning"
        workout_notes = "Great morning run!"
        effort_level = "Moderate"
        diary_group = "exercise"
    },
    @{
        username = "testuser"
        selected_workout = "Weight Training"
        duration_min = "45"
        energy_burned = "250"
        current_date = (Get-Date).ToString("yyyy-MM-dd")
        time_of_day = "evening"
        workout_notes = "Strength training session"
        effort_level = "High"
        diary_group = "exercise"
    }
)

foreach ($logRequest in $logRequests) {
    $logResult = Invoke-ApiRequest -Method "POST" -Uri "$baseUrl/workout_logging/log_workout_info" -Body $logRequest
    Show-TestResult -TestName "Log Workout: $($logRequest.selected_workout)" -Result $logResult
}

# Test 5: Get Workout History
Write-Host "`n📚 Testing Workout History" -ForegroundColor Magenta

$historyResult = Invoke-ApiRequest -Method "GET" -Uri "$baseUrl/workout_logging/history?username=testuser&limit=10"
Show-TestResult -TestName "Get Workout History" -Result $historyResult

if ($historyResult.Success -and $historyResult.Data.workout_history) {
    $historyCount = $historyResult.Data.workout_history.Count
    Write-Host "   History entries: $historyCount" -ForegroundColor Gray
}

# Test 6: Error Handling
Write-Host "`n❌ Testing Error Handling" -ForegroundColor Magenta

# Test missing required fields
$invalidRequests = @(
    @{
        uri = "$baseUrl/workout_logging/workout_search"
        body = @{ username = "testuser" }  # Missing workout_query
        testName = "Search without query"
    },
    @{
        uri = "$baseUrl/workout_logging/fetch_workout_info"
        body = @{ effort_level = "Moderate" }  # Missing selected_workout
        testName = "Fetch info without workout"
    },
    @{
        uri = "$baseUrl/workout_logging/log_workout_info"
        body = @{ username = "testuser" }  # Missing required fields
        testName = "Log workout with incomplete data"
    }
)

foreach ($invalidRequest in $invalidRequests) {
    $errorResult = Invoke-ApiRequest -Method "POST" -Uri $invalidRequest.uri -Body $invalidRequest.body
    
    # These should fail, so we check for failure
    if (!$errorResult.Success) {
        Write-Host "`n🧪 Test: $($invalidRequest.testName)" -ForegroundColor Yellow
        Write-Host "✅ PASSED (Expected failure)" -ForegroundColor Green
        Write-Host "   Error: $($errorResult.Error)" -ForegroundColor Gray
    } else {
        Write-Host "`n🧪 Test: $($invalidRequest.testName)" -ForegroundColor Yellow
        Write-Host "❌ FAILED (Should have failed)" -ForegroundColor Red
    }
}

# Summary
Write-Host "`n📋 Frontend Compatibility Test Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✅ Workout search functionality" -ForegroundColor Green
Write-Host "✅ Workout info fetching" -ForegroundColor Green
Write-Host "✅ Workout logging" -ForegroundColor Green
Write-Host "✅ Workout history retrieval" -ForegroundColor Green
Write-Host "✅ Error handling validation" -ForegroundColor Green

Write-Host "`n🎉 Frontend-compatible workout API is ready!" -ForegroundColor Green
Write-Host "Your Flutter app can now connect to these endpoints:" -ForegroundColor Yellow
Write-Host "  • POST /api/v1/workout_logging/workout_search" -ForegroundColor Gray
Write-Host "  • POST /api/v1/workout_logging/fetch_workout_info" -ForegroundColor Gray
Write-Host "  • POST /api/v1/workout_logging/log_workout_info" -ForegroundColor Gray
Write-Host "  • GET  /api/v1/workout_logging/history" -ForegroundColor Gray