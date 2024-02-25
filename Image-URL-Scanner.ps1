<#=========================== Beigeworm's Image URL Scanner ================================

SYNOPSIS
Searches random Imgur links and tries to enumerate images. 

HOW IT WORKS
1. Generates a random extension to a possible Imgur URL
2. Tries to enumerate the URL
3. If successful image is saved to a text file 

USAGE
1. Run the script for as long as you want.
2. Review the results in the log file.
#>

# Webhook Setup (Optional)
$hookurl = ""

# Console Setup
[Console]::SetWindowSize(125, 55)
[Console]::Title = " Imgur Scanner"
[Console]::CursorVisible = $false
[Console]::BackgroundColor = "Black"
cls

# Other Setup
$ratelimit = 0
$found = 0
Write-Host "Starting Image URL Scanner.." -ForegroundColor Yellow

# shortened URL Detection
if ($hookurl.Ln -ne 121){
    $hookurl = (irm $hookurl).url
    Write-Host "Full Webhook : $hookurl" -ForegroundColor DarkGray
    sleep 1
}

# Header for console
Function Header{
Cls
Write-Host "
======================================================================================================================
.___                                 ____ _____________.____        _________                                         
|   | _____ _____     ____   ____   |    |   \______   \    |      /   _____/ ____ _____    ____   ____   ___________ 
|   |/     \\__  \   / ___\_/ __ \  |    |   /|       _/    |      \_____  \_/ ___\\__  \  /    \ /    \_/ __ \_  __ \
|   |  Y Y  \/ __ \_/ /_/  >  ___/  |    |  / |    |   \    |___   /        \  \___ / __ \|   |  \   |  \  ___/|  | \/
|___|__|_|  (____  /\___  / \___  > |______/  |____|_  /_______ \ /_______  /\___  >____  /___|  /___|  /\___  >__|   
          \/     \//_____/      \/                   \/        \/         \/     \/     \/     \/     \/     \/       
======================================================================================================================" -ForegroundColor Green
}

Function MakeDir {
    $folderpath = "Images/"
    if (!(Test-Path $folderpath)){
        New-Item -ItemType Directory -Path $folderpath
    }
}

# Random Character Generator
function Get-RandomExt {
    $characters = @('a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','x','y','z','A','B','C','D','E','F','G','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','_','1','2','3','4','5','6','7','8','9','0')
    $randomString = -join (Get-Random -InputObject $characters -Count $ext)
    return $randomString
}

Function TryURL {
    param([string]$extension)

    Write-Host "Trying Image URL: $newUrl.$extension" -ForegroundColor Gray
    
    try {
        $TryURL = "$newUrl.$extension"
        $fileName = [System.IO.Path]::GetFileName($TryURL)
        $destinationPath = "Images/" + $fileName
        $response = Invoke-WebRequest -Uri $TryURL -Method Head
        $contentLength = $response.Headers['Content-Length']

        if ([int]$contentLength -gt 2048) {
            Write-Host "File Found! downloading. $destinationPath" -ForegroundColor Green
            IWR -Uri $TryURL -OutFile $destinationPath
            sleep 3
            if ($hookurl.Length -gt 0){
                Write-Host "Uploading $destinationPath" -ForegroundColor Green
                curl.exe -F "file1=@Images/$fileName" $hookurl
                sleep 10
            }
            $script:found++
        } 
        else {
            Write-Host "File size of $fileName is less than 2KB. Skipping download." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "Link not found or error: $_" -ForegroundColor Red
    }
}

# Call Starting Functions
Header
MakeDir

# Main Loop
while ($true){

    # t.ly link checker
    $url = "https://i.imgur.com/"
    $ext = 7
    $randomString = Get-RandomExt
    $newUrl = $url + $randomString
    TryURL -extension "png"

    # Rate Limit Nerf
    if ($ratelimit -lt 20){
        $ratelimit++
    }
    else{
        Write-Host "Sleeping for 5 seconds..." -ForegroundColor yellow
        $ratelimit = 0
        Header
        Write-Host "Found Images : $found`n" -ForegroundColor Yellow
        sleep 1
    }

# Reset The Loop
$fullUrl = ""
}
