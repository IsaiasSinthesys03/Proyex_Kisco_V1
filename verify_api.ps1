$response = Invoke-WebRequest -Uri "http://localhost:5260/health" -Method Get -ErrorAction SilentlyContinue
if ($response.StatusCode -eq 200) {
    Write-Host "✅ API is running and healthy!"
    $content = $response.Content | ConvertFrom-Json
    Write-Host "Database Status: $($content.Status)"
    Write-Host "Connected Database: $($content.Database)"
    Write-Host "Collections Found: $($content.Collections -join ', ')"
}
else {
    Write-Host "❌ API is not responding correctly. Status Code: $($response.StatusCode)"
    Write-Host "Response: $($response)"
}
