<# ========================== Minecraft Server Scanning and Enumeration in Powershell =================================

SYNOPSIS
Minecraft Server Scanning and Enumeration in Powershell.
You can:
1. Receive details on a Minecraft Server using an IP and Port.
2. Download and run masscan.exe to find server ip addresses and add them to a file
3. Use a file from masscan to retrieve Server info for many servers at once.

Info displayed: IP Address, Port, Version, Server Software, MOTD, Players Online, Player Names.

USAGE
1. Run script
2. follow the instructions

(Using Option 3 will download masscan.exe from here - https://github.com/Arryboom/MasscanForWindows)
You may need to allow 'Potentially Unwanted App Found' for Microsoft Defender.

masscan example IP ranges:
start of the range : 135.148.0.0 ,end 135.148.255.255 (will take 60 secoonds)
start of the range : 10.0.0.0 ,end 255.255.255.255 (will take DAYS and scan the entire internet)
#>


# Setup for the console
$Host.UI.RawUI.BackgroundColor = "Black"
Clear-Host
$width = 88
$height = 30
[Console]::SetWindowSize($width, $height)
$windowTitle = "Minecraft Server Information"
[Console]::Title = $windowTitle

# Define the menu options
$menu = @(
    "Download masscan.exe and scan for IP addresses",
    "Enumerate server details using an IP and Port",
    "Enumerate results from a masscan xml file",
    "Exit"
)

function Remove-MostRecentLine {
    $cursorPosition = $Host.UI.RawUI.CursorPosition
    $lineNumber = $cursorPosition.Y - 1
    $cursorPosition.Y = $lineNumber
    $Host.UI.RawUI.CursorPosition = $cursorPosition
    Write-Host (" " * $Host.UI.RawUI.WindowSize.Width)
    $Host.UI.RawUI.CursorPosition = $cursorPosition
}

Function Logo{
Write-Output "========================================================"
Write-Output "=   __  __   ___  ___                                  ="
Write-Output "=  |  \/  | / __|/ __| __  __ _  _ _   _ _   ___  _ _  ="
Write-Output "=  | |\/| || (__ \__ \/ _|/ _--|| ' \ | ' \ / -_)| '_| ="
Write-Output "=  |_|  |_| \___||___/\__|\__/_||_||_||_||_|\___||_|   ="
Write-Output "========================================================"
}

# Display the menu
do {
    Clear-Host
    Logo
    Write-Host "Beigeworm's Minecraft Server Info `n`nPlease select from one of the options below`n"
    for ($i = 0; $i -lt $menu.Count; $i++) {
        Write-Host "$($i + 1). $($menu[$i])"
    }
    
    # Get user input
    $choice = Read-Host "`nSelect an Option "
    Clear-Host
    Logo
    # Use a switch statement to perform actions based on user input
    switch ($choice) {
      1 {
            # Download masscan64.exe 
            iwr -uri https://github.com/Arryboom/MasscanForWindows/blob/master/masscan64.exe?raw=true -OutFile masscan64.exe
            Write-Host "masscan.exe download complete."
            $answer = Read-Host "Do you want to run a masscan now? (y/n) "
            Remove-MostRecentLine
            Remove-MostRecentLine
            if ($answer -eq "y"){
                # Define user inputs
                $startip = Read-Host "Enter Start of IP Range (eg. 10.10.0.0)"
                Remove-MostRecentLine
                $endip = Read-Host "Enter End of IP Range (eg. 100.100.255.255)"
                Remove-MostRecentLine
                $outxml = Read-Host "Enter Output File Name (.xml) "
                Remove-MostRecentLine
                # Run masscan
                $answer2 = Read-Host "Do you want to run masscan at full speed? (can be hard on your router!) (y/n) "
                Remove-MostRecentLine
                if ($answer2 -eq "y"){./masscan64.exe -p25565 $startip-$endip --exclude 255.255.255.255 --rate=100000 -oX $outxml}
                else{./masscan64.exe -p25565 $startip-$endip --exclude 255.255.255.255 --rate=1000 -oX $outxml}
                }
        }
        2 {

            $Ip = Read-Host "Input an IP Address "
            $Port = Read-Host "Input a Port Number "
            
            if ($Port.Length -eq 0){$port = 25565}

            # Make the web request and convert the JSON response
            $response = Invoke-WebRequest -Uri "https://api.mcstatus.io/v2/status/java/$Ip`:$Port"
            $data = $response.Content | ConvertFrom-Json
            
            # Display the formatted output
            Write-Host "Server Information:"
            Write-Host "-------------------"
            Write-Host "IP Address: $($ip)"
            Write-Host "Port: $($data.port)"
            Write-Host "Version: $($data.version)"
            Write-Host "Server Software: $($data.software)"
            Write-Host "MOTD: $($data.motd.clean)"
            Write-Host "Players Online: $($data.players.online)/$($data.players.max)"
            Write-Host "Player List: $($data.players.list.name_clean)"
        
        }        
        3 {
            $outfile = Read-Host "Enter a name for the output file (.txt) "
            Remove-MostRecentLine
            New-Item -Path $outfile -Force | Out-Null
            # Read the XML file and get the host elements
            $xmlFile = Read-Host "Path to your input file (.xml) "
            Remove-MostRecentLine
            $xmlContent = Get-Content -Path $xmlFile -Raw

            # Load the XML content
            [xml]$xml = $xmlContent
            
            # Select all <address> and <port> elements
            $addresses = $xml.SelectNodes("//address")
            $ports = $xml.SelectNodes("//port")
            $n = 1
            # Loop through each <host> element and extract IP and port
            for ($i = 0; $i -lt $addresses.Count; $i++) {
                $ip = $addresses[$i].GetAttribute("addr")
                $port = $ports[$i].GetAttribute("portid")
                        
                    # Make the web request and convert the JSON response
                    $response = Invoke-WebRequest -Uri "https://api.mcstatus.io/v2/status/java/$Ip`:$Port"
                    $data = $response.Content | ConvertFrom-Json
                    $outdata = "
                    Server Information:
                    -------------------
                    IP Address: $($ip)
                    Port: $($port)
                    Version: $($data.version.name_clean)
                    Server Software: $($data.software)
                    MOTD: $($data.motd.clean)
                    Players Online: $($data.players.online)/$($data.players.max)
                    Player List: $($data.players.list.name_clean)`n"
            
                    if($data.online -match "true"){
                        $outdata | Out-File -FilePath $outfile -Append -Force
                        if ($n -ne 1){Remove-MostRecentLine}
                        Write-Output "Server $n Details Saved to $outfile."
                        $n++
                        }
                }
            
        }
        4 {
            # Exit the loop and the script
            Write-Host "Exiting..."
            exit
        }
        default {
            Write-Host "Invalid choice. Please select a valid option."
        }
    }
    Read-Host "`nPress Enter to Return to the Main Menu.."
} while ($choice -ne 4)

