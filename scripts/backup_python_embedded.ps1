param(
    [string]$ComfyUIPath = $env:COMFYUI_PATH
)

if (-not $ComfyUIPath) {
    $ComfyUIPath = "E:\ComfyUI_windows_portable"
}

$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
$backupPath = Join-Path $ComfyUIPath "python_embeded_backup_$timestamp"

Write-Host "Creating backup of python_embeded..." -ForegroundColor Yellow
Copy-Item -Path (Join-Path $ComfyUIPath "python_embeded") -Destination $backupPath -Recurse
Write-Host "Backup created at: $backupPath" -ForegroundColor Green

# Also save package list
$packagesFile = Join-Path $ComfyUIPath "packages_$timestamp.txt"
& "$ComfyUIPath\python_embeded\python.exe" -m pip list > $packagesFile
Write-Host "Package list saved to: $packagesFile" -ForegroundColor Green
