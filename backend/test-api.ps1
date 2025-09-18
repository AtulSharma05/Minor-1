# Backend API Test Script
# Use this PowerShell script to test your backend API endpoints

# Health Check
Write-Host "Testing Health Endpoint..." -ForegroundColor Green
try {
    $healthResponse = Invoke-RestMethod -Uri "http://localhost:3000/health" -Method GET
    Write-Host "✅ Health Check Response:" -ForegroundColor Green
    $healthResponse | ConvertTo-Json -Depth 3
} catch {
    Write-Host "❌ Health Check Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n" + "="*50 + "`n"

# Test User Registration
Write-Host "Testing User Registration..." -ForegroundColor Green
$registerData = @{
    username = "testuser"
    email = "test@example.com"
    password = "password123"
    fullName = "Test User"
    age = 25
    height = 175
    weight = 70
} | ConvertTo-Json

try {
    $registerResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/v1/auth/register" -Method POST -Body $registerData -ContentType "application/json"
    Write-Host "✅ Registration Response:" -ForegroundColor Green
    $registerResponse | ConvertTo-Json -Depth 3
    
    # Store tokens for further tests
    $accessToken = $registerResponse.data.tokens.accessToken
    $refreshToken = $registerResponse.data.tokens.refreshToken
    
} catch {
    Write-Host "❌ Registration Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n" + "="*50 + "`n"

# Test User Login
Write-Host "Testing User Login..." -ForegroundColor Green
$loginData = @{
    email = "test@example.com"
    password = "password123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/v1/auth/login" -Method POST -Body $loginData -ContentType "application/json"
    Write-Host "✅ Login Response:" -ForegroundColor Green
    $loginResponse | ConvertTo-Json -Depth 3
    
    # Update tokens from login
    $accessToken = $loginResponse.data.tokens.accessToken
    $refreshToken = $loginResponse.data.tokens.refreshToken
    
} catch {
    Write-Host "❌ Login Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n" + "="*50 + "`n"

# Test Get User Profile (Protected Route)
if ($accessToken) {
    Write-Host "Testing Get User Profile..." -ForegroundColor Green
    $headers = @{
        "Authorization" = "Bearer $accessToken"
    }
    
    try {
        $profileResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/v1/auth/me" -Method GET -Headers $headers
        Write-Host "✅ Profile Response:" -ForegroundColor Green
        $profileResponse | ConvertTo-Json -Depth 3
    } catch {
        Write-Host "❌ Get Profile Failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host "`n" + "="*50 + "`n"
}

# Test Token Refresh
if ($refreshToken) {
    Write-Host "Testing Token Refresh..." -ForegroundColor Green
    $refreshData = @{
        refreshToken = $refreshToken
    } | ConvertTo-Json
    
    try {
        $refreshResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/v1/auth/refresh" -Method POST -Body $refreshData -ContentType "application/json"
        Write-Host "✅ Token Refresh Response:" -ForegroundColor Green
        $refreshResponse | ConvertTo-Json -Depth 3
    } catch {
        Write-Host "❌ Token Refresh Failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host "`n" + "="*50 + "`n"
}

# Test Logout
if ($refreshToken) {
    Write-Host "Testing User Logout..." -ForegroundColor Green
    $logoutData = @{
        refreshToken = $refreshToken
    } | ConvertTo-Json
    
    try {
        $logoutResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/v1/auth/logout" -Method POST -Body $logoutData -ContentType "application/json"
        Write-Host "✅ Logout Response:" -ForegroundColor Green
        $logoutResponse | ConvertTo-Json -Depth 3
    } catch {
        Write-Host "❌ Logout Failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n" + "="*50 + "`n"
Write-Host "🎉 API Testing Complete!" -ForegroundColor Cyan
Write-Host "Backend is running at: http://localhost:3000" -ForegroundColor Yellow
Write-Host "API Documentation available in README.md" -ForegroundColor Yellow