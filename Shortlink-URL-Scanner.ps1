<#=========================== Beigeworm's URL Scanner ================================

SYNOPSIS
Searches random shortener links and tries to enumerate any parent URLs. 

HOW IT WORKS
1. Generates a random extension to each shortener
2. Tries to enumerate the parent URL
3. If successful URL is saved to URLs.log file 

USAGE
1. Run the script for as long as you want.
2. Review the results in the log file.
#>

# Console Setup
[Console]::SetWindowSize(98, 50)
[Console]::Title = " Shortlink Scanner"
[Console]::CursorVisible = $false
[Console]::BackgroundColor = "Black"
cls

# Other Setup
$filePath = "URLs.log"
$ratelimit = 0
$found = 0
Write-Host "Starting URL Scanner.." -ForegroundColor Yellow

# Header for console
Function Header{
Cls
Write-Host "
================================================================================================
     ____ _____________.____                _________                                         
    |    |   \______   \    |              /   _____/ ____ _____    ____   ____   ___________ 
    |    |   /|       _/    |      ______  \_____  \_/ ___\\__  \  /    \ /    \_/ __ \_  __ \
    |    |  / |    |   \    |___  /_____/  /        \  \___ / __ \|   |  \   |  \  ___/|  | \/
    |______/  |____|_  /_______ \         /_______  /\___  >____  /___|  /___|  /\___  >__|   
                     \/        \/                 \/     \/     \/     \/     \/     \/       
================================================================================================" -ForegroundColor Green
}

# Test Log file location
Function TestFile {
    if (!(Test-Path $filePath)){
        "FOUND URLS :" | Out-File -FilePath $filePath -Force
        Write-Host "Log file created." -ForegroundColor Green
    }
    else{
        Write-Host "Log file already created.." -ForegroundColor Gray
    }
    Write-Host "Loading Scanner.." -ForegroundColor yellow
    Sleep 1
}

# Random Character Generator
function Get-RandomExt {
    $characters = @('a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','x','y','z','A','B','C','D','E','F','G','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','_','1','2','3','4','5','6','7','8','9','0')
    $randomString = -join (Get-Random -InputObject $characters -Count $ext)
    return $randomString
}

# Short URL Enumerator
function Get-UnshortenedUrl {
    param ([string]$Url)

    $request = [System.Net.HttpWebRequest]::Create($Url)
    $request.AllowAutoRedirect = $false
    try {
        $response = $request.GetResponse()
        $unshortenedUrl = $response.Headers['Location']
        $response.Close()
        return $unshortenedUrl
    } 
    catch {
        return $null
    }
}

# Recover the Un-shortened URL 
Function TryURL{

    Write-Host "Trying Shortened URL: $newUrl" -ForegroundColor Gray
    $fullUrl = Get-UnshortenedUrl -Url $newUrl
    if ($fullUrl.length -ne 0){
        $script:found++
        Write-Host "Link Found!: $fullUrl" -ForegroundColor Green
        $Content = "==================  URL FOUND!  ====================`nFull URL :$fullUrl `nShortened URL: $newurl`n====================================================`n" 
        $Content | Out-File -FilePath $filePath -Append -Force
        sleep 1
    }
    else{
        Write-Host "Link not found..." -ForegroundColor Red
    }

}


# Call Starting Functions
Header
TestFile

# Main Loop
while ($true){

    # t.ly link checker
    $url = "https://t.ly/"
    $ext = 5
    $randomString = Get-RandomExt
    $newUrl = $url + $randomString
    TryURL

    # bit.ly link checker
    $url = "https://bit.ly/"
    $ext = 7
    $randomString = Get-RandomExt
    $newUrl = $url + $randomString
    TryURL

    # cutt.ly link checker
    $url = "https://cutt.ly/"
    $ext = 8
    $randomString = Get-RandomExt
    $newUrl = $url + $randomString
    TryURL

    # tinyurl.com link checker
    $url = "http://tinyurl.com/"
    $ext = 8
    $randomString = Get-RandomExt
    $newUrl = $url + $randomString
    TryURL

    # Rate Limit Nerf
    if ($ratelimit -lt 20){
        $ratelimit++
    }
    else{
        Write-Host "Sleeping for 15 seconds..." -ForegroundColor yellow
        Write-Host "Found URLs : $found`n" -ForegroundColor Yellow
        $ratelimit = 0
        sleep 15
        Header
        Write-Host "Found URLs : $found`n" -ForegroundColor Yellow
    }

# Reset The Loop
$fullUrl = ""
sleep 1
}