# PowerShell Script to Install Prism Launcher and Set Up a Local Minecraft Server
# https://prismlauncher.org/

# Set variables
$PrismInstaller = "PrismLauncher.exe"
$PrismURL = "https://github.com/PrismLauncher/PrismLauncher/releases/latest/download/PrismLauncher-Windows-MSVC.exe"
$ServerDir = "$env:USERPROFILE\MinecraftServer"
$ServerJar = "$ServerDir\server.jar"
$EULAFile = "$ServerDir\eula.txt"

# Function to check if Java is installed
function Check-Java {
    try {
        $javaVersion = java -version 2>&1
        if ($javaVersion -match "version") {
            Write-Output "Java is already installed."
            return $true
        }
    } catch {
        Write-Output "Java is not installed."
    }
    return $false
}

# Install Java if not installed
if (-not (Check-Java)) {
    Write-Output "Installing Java..."
    winget install EclipseAdoptium.Temurin.17.JDK -e
}

# Download and install Prism Launcher
Write-Output "Downloading Prism Launcher..."
Invoke-WebRequest -Uri $PrismURL -OutFile $PrismInstaller
Write-Output "Installing Prism Launcher..."
Start-Process -FilePath $PrismInstaller -ArgumentList "/S" -Wait
Remove-Item $PrismInstaller -Force

# Create Minecraft Server Directory
if (!(Test-Path $ServerDir)) {
    New-Item -ItemType Directory -Path $ServerDir
}

# Get the latest Minecraft server JAR URL
Write-Output "Fetching latest Minecraft server JAR..."
$ManifestURL = "https://launchermeta.mojang.com/mc/game/version_manifest.json"
$Manifest = Invoke-RestMethod -Uri $ManifestURL
$LatestVersion = $Manifest.latest.release
$VersionInfo = $Manifest.versions | Where-Object { $_.id -eq $LatestVersion }
$ServerDownloadURL = (Invoke-RestMethod -Uri $VersionInfo.url).downloads.server.url

# Download the latest Minecraft Server
Write-Output "Downloading Minecraft Server..."
Invoke-WebRequest -Uri $ServerDownloadURL -OutFile $ServerJar

Write-Output "Prism Launcher has been installed. You can now create an instance and add the server manually."
