[Console]::SetWindowSize(80, 25)
[Console]::Title = "URL Fuzzer"
[Console]::CursorVisible = $false
[Console]::BackgroundColor = "Black"
cls

function Test-Url {
    param ([string]$url)
    try {
        $response = Invoke-WebRequest -Uri $url -Method Head -UseBasicParsing -ErrorAction Stop
        return $response.StatusCode
    } catch {
        return $_.Exception.Response.StatusCode.Value__
    }
}

$baseUrl = Read-Host "Enter the website you want to fuzz "
$baseUrl = "$baseUrl/"
$uptest = Test-Url $baseUrl

if ($uptest -eq 200) {
    Write-Host "Site is up!" -ForegroundColor Green
    Start-Sleep -Seconds 1
} else {
    Write-Host "Site is down.. exiting" -ForegroundColor Red
    Pause
    Exit
}

$extensions = Get-Content "wordlist.txt"
$totalItems = $extensions.Count
$i = 0
$percentThreshold = 1
$lastPercent = -1
$currentPercent = [math]::Floor($i / $totalItems * 100)
cls
Write-Progress -Activity "Testing URLs $currentPercent" -Status "Progress" -PercentComplete $currentPercent
[Console]::SetWindowSize(80, 30)

foreach ($extension in $extensions) {
    $url = $baseUrl + $extension
    $statusCode = Test-Url $url
    if ($statusCode -eq 200) {
        $url | Out-File -FilePath "loot.txt" -Append
    }
    $i++
    $currentPercent = [math]::Floor($i / $totalItems * 100)
    if ($currentPercent -ne $lastPercent -and $currentPercent % $percentThreshold -eq 0) {
        cls
        Write-Progress -Activity "Testing URLs - Progress: $currentPercent% complete" -Status "Progress" -PercentComplete $currentPercent
        $lastPercent = $currentPercent
    }
}