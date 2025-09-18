# Backend API Full Testing Script
# Tests all authentication endpoints with real data

Write-Host "🧪 Starting Full Backend API Testing..." -ForegroundColor Green
Write-Host "=" * 60

$baseUrl = "http://localhost:3000"
$apiUrl = "$baseUrl/api/v1"

# Test 1: Health Check
Write-Host "`n1️⃣ Testing Health Endpoint..." -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "$baseUrl/health" -Method GET
    Write-Host "✅ Health Check: $($health.status)" -ForegroundColor Green
    Write-Host "   Message: $($health.message)" -ForegroundColor Gray
    Write-Host "   Timestamp: $($health.timestamp)" -ForegroundColor Gray
} catch {
    Write-Host "❌ Health Check Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: User Registration
Write-Host "`n2️⃣ Testing User Registration..." -ForegroundColor Yellow
$ts = [int][double]::Parse((Get-Date -UFormat %s))
$uniqueUser = "testuser_$ts"
$uniqueEmail = "test_$ts@example.com"

$userData = @{
    username = $uniqueUser
    email = $uniqueEmail
    password = "password123"
    fullName = "Test User"
    age = 25
    height = 175
    weight = 70
} | ConvertTo-Json

try {
    $registerResponse = Invoke-RestMethod -Uri "$apiUrl/auth/register" -Method POST -Body $userData -ContentType "application/json"
    Write-Host "✅ Registration Successful!" -ForegroundColor Green
    Write-Host "   User ID: $($registerResponse.data.user.id)" -ForegroundColor Gray
    Write-Host "   Username: $($registerResponse.data.user.username)" -ForegroundColor Gray
    Write-Host "   Email: $($registerResponse.data.user.email)" -ForegroundColor Gray
    Write-Host "   BMI: $($registerResponse.data.user.bmi)" -ForegroundColor Gray
    
    # Store tokens for further testing
    $accessToken = $registerResponse.data.tokens.accessToken
    $refreshToken = $registerResponse.data.tokens.refreshToken
    
    Write-Host "   Access Token: $($accessToken.Substring(0, 20))..." -ForegroundColor Gray
} catch {
    Write-Host "❌ Registration Failed: $($_.Exception.Message)" -ForegroundColor Red
    
    # Try login instead (user might already exist)
    Write-Host "`n🔄 Trying login instead..." -ForegroundColor Yellow
    $loginData = @{
        email = $uniqueEmail
        password = "password123"
    } | ConvertTo-Json
    
    try {
        $loginResponse = Invoke-RestMethod -Uri "$apiUrl/auth/login" -Method POST -Body $loginData -ContentType "application/json"
        Write-Host "✅ Login Successful!" -ForegroundColor Green
        $accessToken = $loginResponse.data.tokens.accessToken
        $refreshToken = $loginResponse.data.tokens.refreshToken
    } catch {
        Write-Host "❌ Login Also Failed: $($_.Exception.Message)" -ForegroundColor Red
        return
    }
}

# Test 3: Get User Profile (Protected Route)
Write-Host "`n3️⃣ Testing Protected Route (Get User Profile)..." -ForegroundColor Yellow
try {
    $headers = @{
        "Authorization" = "Bearer $accessToken"
        "Content-Type" = "application/json"
    }
    
    $profileResponse = Invoke-RestMethod -Uri "$apiUrl/auth/me" -Method GET -Headers $headers
    Write-Host "✅ Profile Retrieved Successfully!" -ForegroundColor Green
    Write-Host "   Username: $($profileResponse.data.user.username)" -ForegroundColor Gray
    Write-Host "   Email: $($profileResponse.data.user.email)" -ForegroundColor Gray
    Write-Host "   Full Name: $($profileResponse.data.user.fullName)" -ForegroundColor Gray
    Write-Host "   BMI: $($profileResponse.data.user.bmi) ($($profileResponse.data.user.bmiCategory))" -ForegroundColor Gray
} catch {
    Write-Host "❌ Profile Retrieval Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Token Refresh
Write-Host "`n4️⃣ Testing Token Refresh..." -ForegroundColor Yellow
$refreshData = @{
    refreshToken = $refreshToken
} | ConvertTo-Json

try {
    $refreshResponse = Invoke-RestMethod -Uri "$apiUrl/auth/refresh" -Method POST -Body $refreshData -ContentType "application/json"
    Write-Host "✅ Token Refresh Successful!" -ForegroundColor Green
    Write-Host "   New Access Token: $($refreshResponse.data.accessToken.Substring(0, 20))..." -ForegroundColor Gray
    
    # Update access token
    $accessToken = $refreshResponse.data.accessToken
} catch {
    Write-Host "❌ Token Refresh Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: Test API Endpoints
Write-Host "`n5️⃣ Testing API Endpoints..." -ForegroundColor Yellow

# Test welcome endpoint
try {
    $welcomeResponse = Invoke-RestMethod -Uri "$apiUrl/" -Method GET
    Write-Host "✅ Welcome Endpoint: $($welcomeResponse.message)" -ForegroundColor Green
} catch {
    Write-Host "❌ Welcome Endpoint Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 6: Logout
Write-Host "`n6️⃣ Testing Logout..." -ForegroundColor Yellow
$logoutData = @{
    refreshToken = $refreshToken
} | ConvertTo-Json

try {
    $logoutResponse = Invoke-RestMethod -Uri "$apiUrl/auth/logout" -Method POST -Body $logoutData -ContentType "application/json"
    Write-Host "✅ Logout Successful!" -ForegroundColor Green
    Write-Host "   Message: $($logoutResponse.message)" -ForegroundColor Gray
} catch {
    Write-Host "❌ Logout Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 7: Test Invalid Token (After Logout)
Write-Host "`n7️⃣ Testing Security (Invalid Token after Logout)..." -ForegroundColor Yellow
try {
    $headers = @{
        "Authorization" = "Bearer $refreshToken"
        "Content-Type" = "application/json"
    }
    
    $profileResponse = Invoke-RestMethod -Uri "$apiUrl/auth/me" -Method GET -Headers $headers
    Write-Host "❌ Security Issue: Should have failed but didn't!" -ForegroundColor Red
} catch {
    Write-Host "✅ Security Working: Invalid token properly rejected" -ForegroundColor Green
}

# Final Summary
Write-Host "`n" + "=" * 60 -ForegroundColor Green
Write-Host "🎉 Backend API Testing Complete!" -ForegroundColor Green
Write-Host "🔗 Backend URL: $baseUrl" -ForegroundColor Cyan
Write-Host "📚 API Base: $apiUrl" -ForegroundColor Cyan
Write-Host "🏥 Health Check: $baseUrl/health" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Green