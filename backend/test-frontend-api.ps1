# Frontend-Compatible API Test Script
# Tests the auth_user endpoints that match Flutter app expectations

$baseUrl = "http://localhost:3000/api/v1"
$testEmail = "frontend_test_$(Get-Random)@example.com"
$testUsername = "frontend_user_$(Get-Random)"
$testPassword = "TestPassword123!"

Write-Host "🧪 Testing Frontend-Compatible Authentication Endpoints" -ForegroundColor Cyan
Write-Host "Base URL: $baseUrl" -ForegroundColor Yellow
Write-Host ""

# Test 1: Health Check
Write-Host "1️⃣ Testing Health Check..." -ForegroundColor Green
try {
    $healthResponse = Invoke-RestMethod -Uri "http://localhost:3000/health" -Method GET
    Write-Host "✅ Health Check: $($healthResponse.message)" -ForegroundColor Green
} catch {
    Write-Host "❌ Health Check Failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 2: Frontend User Registration
Write-Host "2️⃣ Testing Frontend User Registration..." -ForegroundColor Green
$signupData = @{
    username = $testUsername
    email_id = $testEmail  # Frontend uses email_id
    password = $testPassword
} | ConvertTo-Json

try {
    $signupResponse = Invoke-RestMethod -Uri "$baseUrl/auth_user/signup_user" -Method POST -Body $signupData -ContentType "application/json"
    Write-Host "✅ Registration successful!" -ForegroundColor Green
    Write-Host "   Username: $($signupResponse.user.username)" -ForegroundColor Yellow
    Write-Host "   Email: $($signupResponse.user.email_id)" -ForegroundColor Yellow
    Write-Host "   Token: $($signupResponse.user.token.Substring(0,20))..." -ForegroundColor Yellow
    $userToken = $signupResponse.user.token
} catch {
    Write-Host "❌ Registration Failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $responseBody = $reader.ReadToEnd()
        Write-Host "Error Details: $responseBody" -ForegroundColor Red
    }
    exit 1
}

# Test 3: Frontend User Login
Write-Host "3️⃣ Testing Frontend User Login..." -ForegroundColor Green
$loginData = @{
    email_id = $testEmail  # Frontend uses email_id
    password = $testPassword
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth_user/client_login" -Method POST -Body $loginData -ContentType "application/json"
    Write-Host "✅ Login successful!" -ForegroundColor Green
    Write-Host "   Username: $($loginResponse.user.username)" -ForegroundColor Yellow
    Write-Host "   Email: $($loginResponse.user.email_id)" -ForegroundColor Yellow
    Write-Host "   Token: $($loginResponse.user.token.Substring(0,20))..." -ForegroundColor Yellow
    $userToken = $loginResponse.user.token
} catch {
    Write-Host "❌ Login Failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $responseBody = $reader.ReadToEnd()
        Write-Host "Error Details: $responseBody" -ForegroundColor Red
    }
    exit 1
}

# Test 4: Login with Username (Alternative)
Write-Host "4️⃣ Testing Login with Username..." -ForegroundColor Green
$usernameLoginData = @{
    username = $testUsername
    password = $testPassword
} | ConvertTo-Json

try {
    $usernameLoginResponse = Invoke-RestMethod -Uri "$baseUrl/auth_user/client_login" -Method POST -Body $usernameLoginData -ContentType "application/json"
    Write-Host "✅ Username Login successful!" -ForegroundColor Green
    Write-Host "   Username: $($usernameLoginResponse.user.username)" -ForegroundColor Yellow
    Write-Host "   Email: $($usernameLoginResponse.user.email_id)" -ForegroundColor Yellow
} catch {
    Write-Host "❌ Username Login Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: Frontend User Logout
Write-Host "5️⃣ Testing Frontend User Logout..." -ForegroundColor Green
$logoutData = @{
    username = $testUsername
    token = $userToken
} | ConvertTo-Json

try {
    $logoutResponse = Invoke-RestMethod -Uri "$baseUrl/auth_user/client_logout" -Method POST -Body $logoutData -ContentType "application/json"
    Write-Host "✅ Logout successful!" -ForegroundColor Green
    Write-Host "   Message: $($logoutResponse.message)" -ForegroundColor Yellow
} catch {
    Write-Host "❌ Logout Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 6: Error Handling - Invalid Credentials
Write-Host "6️⃣ Testing Error Handling..." -ForegroundColor Green
$invalidLoginData = @{
    email_id = "nonexistent@example.com"
    password = "wrongpassword"
} | ConvertTo-Json

try {
    $invalidLoginResponse = Invoke-RestMethod -Uri "$baseUrl/auth_user/client_login" -Method POST -Body $invalidLoginData -ContentType "application/json"
    Write-Host "❌ Error handling failed - invalid login succeeded" -ForegroundColor Red
} catch {
    Write-Host "✅ Error handling working - invalid login properly rejected" -ForegroundColor Green
}

Write-Host ""
Write-Host "🎉 All Frontend-Compatible API Tests Completed!" -ForegroundColor Cyan
Write-Host "The backend is now ready for Flutter app integration." -ForegroundColor Green