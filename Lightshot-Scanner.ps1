<#=========================== Beigeworm's Image URL Scanner ================================

SYNOPSIS
Searches random Lightshot Screenshot links and tries to enumerate images. 

HOW IT WORKS
1. Generates a random extension to a possible Lightshot URL
2. Tries to enumerate the URL
3. If successful image is saved to a text file and/or uploaded to discord 

USAGE
1. Run the script for as long as you want.
2. Review the results in the log file.
#>

# Webhook Setup
$hookurl = "YOUR_WEBHOOK_HERE"

# Console Setup
[Console]::SetWindowSize(125, 55)
[Console]::Title = " Lightshot Scanner"
[Console]::CursorVisible = $false
[Console]::BackgroundColor = "Black"
cls

# shortened URL Detection
if ($hookurl.Ln -ne 121){
    $hookurl = (irm $hookurl).url
    Write-Host "Full Webhook : $hookurl" -ForegroundColor DarkGray
    sleep 1
}

# Other Setup
$ratelimit = 0
$found = 0
$download = 0 # Download found images (1=on 0=off) 
Write-Host "Starting Image URL Scanner.." -ForegroundColor Yellow

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

function Get-RandomSc {
    $characters = @('a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','x','y','z')
    $randomString = -join (Get-Random -InputObject $characters -Count $ext)
    return $randomString
}

Function WebhookSendMessage {

# Define the body of the message and convert it to JSON
$body = @{"username" = "Lightshot-BOT" ;"content" = "Found an Image : $newUrl`nDownload Link : $imageUrl"} | ConvertTo-Json

# Use 'Invoke-RestMethod' command to send the message to Discord
IRM -Uri $hookurl -Method Post -ContentType "application/json" -Body $body

$script:found++
}

# Call Starting Functions
Header
MakeDir

While($true){

# prnt.sc link checker
$url = "https://prnt.sc/"
$ext = 6
$randomString = Get-RandomSc
$newUrl = $url + $randomString
$html = Invoke-WebRequest -Uri $newUrl
$htmlContent = $html.Content

# Use regex to find the image URL in the HTML content
$imageUrlMatch = [regex]::Match($htmlContent, 'https://image\.prntscr\.com/image/[^\s"]+')

    if ($imageUrlMatch.Success) {
        $imageUrl = $imageUrlMatch.Value
        try{
            $response = Invoke-WebRequest -Uri $imageUrl -Method Head
            $contentLength = $response.Headers['Content-Length']
                Write-Host "Found image URL: $imageUrl" -ForegroundColor Green
                $fileName = [System.IO.Path]::GetFileName($newUrl + ".png")
                $destinationPath = "Images/" + $fileName
                if ($download -eq 1){
                    Invoke-WebRequest -Uri $imageUrl -OutFile $destinationPath 
                    Write-Host "Image downloaded to: $destinationPath" -ForegroundColor Green
                }
                if ($hookurl.Length -gt 0){
                    Write-Host "Uploading $destinationPath" -ForegroundColor Green
                    WebhookSendMessage
                    sleep 1
                }
            
        }
        catch{
            Write-Host "Fail" -ForegroundColor Red
        }
    } 
    else {
        Write-Host "Image URL not found in HTML content." -ForegroundColor Red
    }

    # Rate Limit Nerf
    if ($ratelimit -lt 20){
        $ratelimit++
    }
    else{
        Write-Host "Sleeping for 60 seconds..." -ForegroundColor yellow
        sleep 60
        $ratelimit = 0
        Header
        Write-Host "Found Images : $found`n" -ForegroundColor Yellow
        sleep 1
    }


}