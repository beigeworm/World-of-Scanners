<#=========================== Beigeworm's Pastebin Scanner ================================

SYNOPSIS
Searches random Pastebin links and tries to enumerate content from any finds. 

HOW IT WORKS
1. Generates a random extension to a possible pastebin URL
2. Tries to enumerate the URL
3. If successful URL's Contents are saved to a text file 

USAGE
1. Run the script for as long as you want.
2. Review the results in the log file.
#>

# Webhook Setup (Optional)
$hookurl = ""

# Console Setup
[Console]::SetWindowSize(120, 55)
[Console]::Title = " Pastebin Scanner"
[Console]::CursorVisible = $false
[Console]::BackgroundColor = "Black"
cls

# Other Setup
$ratelimit = 0
$found = 0
Write-Host "Starting Pastebin Scanner.." -ForegroundColor Yellow

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
=================================================================================================================
 __________                  __        __________.__           _________                                         
 \______   \_____    _______/  |_  ____\______   \__| ____    /   _____/ ____ _____    ____   ____   ___________ 
  |     ___/\__  \  /  ___/\   __\/ __ \|    |  _/  |/    \   \_____  \_/ ___\\__  \  /    \ /    \_/ __ \_  __ \
  |    |     / __ \_\___ \  |  | \  ___/|    |   \  |   |  \  /        \  \___ / __ \|   |  \   |  \  ___/|  | \/
  |____|    (____  /____  > |__|  \___  >______  /__|___|  / /_______  /\___  >____  /___|  /___|  /\___  >__|   
                 \/     \/            \/       \/        \/          \/     \/     \/     \/     \/     \/       
=================================================================================================================" -ForegroundColor Green
}

Function MakeDir {
    $folderpath = "Pastes/"
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


# Recover the Un-shortened URL 
Function TryURL{
    
        try{
        Write-Host "Trying URL: $newUrl" -ForegroundColor Gray
        $fullUrl = (irm $newUrl)
        if ($fullUrl.length -ne 0){
            $script:found++
            Write-Host "Paste Found!: $newUrl" -ForegroundColor Green
            $Content = "$fullUrl"
            $fileName = [System.IO.Path]::GetFileName($newUrl)
            $filetxt = $fileName + ".txt"
            $filePath = "Pastes/" + $fileName + ".txt"
            $Content | Out-File -FilePath $filePath -Force
            sleep 3
            if ($hookurl.Length -gt 0){
                Write-Host "Uploading $filetxt" -ForegroundColor Green
                curl.exe -F "file1=@Pastes/$filetxt" $hookurl
                sleep 10
            }
            sleep 1
        }
        else{
            Write-Host "Link not found..." -ForegroundColor Red
        }
    }
    catch{
    Write-Host "Link not found : $_" -ForegroundColor Red
    }
    

}


# Call Starting Functions
Header
MakeDir

# Main Loop
while ($true){

    # t.ly link checker
    $url = "https://pastebin.com/raw/"
    $ext = 8
    $randomString = Get-RandomExt
    $newUrl = $url + $randomString
    TryURL

    # Rate Limit Nerf
    if ($ratelimit -lt 20){
        $ratelimit++
    }
    else{
        Write-Host "Sleeping for 5 seconds..." -ForegroundColor yellow
        $ratelimit = 0
        Header
        Write-Host "Found URLs : $found`n" -ForegroundColor Yellow
    }

# Reset The Loop
$fullUrl = ""
}
