# Quick Test: ComfyUI-Distributed Compatibility
# Run this script to test if Distributed really conflicts with Nunchaku

param(
    [string]$ComfyUIPath = "E:\ComfyUI_windows_portable",
    [string]$TestPath = "E:\ComfyUI_test_distributed"
)

Write-Host "=== ComfyUI-Distributed Compatibility Test ===" -ForegroundColor Cyan
Write-Host "Testing if Distributed really breaks Nunchaku..." -ForegroundColor Yellow

# Step 1: Verify Nunchaku works in source
Write-Host ""
Write-Host "1. Testing Nunchaku in source installation..." -ForegroundColor Green
$nunchakuTest = & "$ComfyUIPath\python_embeded\python.exe" -c "import nunchaku; print('Nunchaku ' + nunchaku.__version__ + ' OK')" 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Nunchaku working: $nunchakuTest" -ForegroundColor Green
} else {
    Write-Host "✗ Nunchaku already broken in source!" -ForegroundColor Red
    exit 1
}

# Step 2: Check numpy version
Write-Host ""
Write-Host "2. Checking numpy version..." -ForegroundColor Green
$numpyVersion = & "$ComfyUIPath\python_embeded\python.exe" -c "import numpy; print(numpy.__version__)"
Write-Host "Current numpy: $numpyVersion" -ForegroundColor Cyan

# Step 3: Create test copy WITH SYMLINK PRESERVATION
Write-Host ""
Write-Host "3. Creating test copy (preserving symlinks)..." -ForegroundColor Green
if (Test-Path $TestPath) {
    Write-Host "Test path exists. Remove it first? (Y/N)" -ForegroundColor Yellow
    $response = Read-Host
    if ($response -eq 'Y') {
        Remove-Item -Path $TestPath -Recurse -Force
    } else {
        exit
    }
}

Write-Host "Copying ComfyUI with robocopy to preserve symlinks..." -ForegroundColor Yellow
Write-Host "This will NOT copy model files, only the symlink references" -ForegroundColor Cyan

# Use robocopy with /SL to preserve symlinks
$robocopyResult = robocopy "$ComfyUIPath" "$TestPath" /E /SL /MT:16 /NFL /NDL /NJH /NJS /nc /ns /np
if ($LASTEXITCODE -ge 8) {
    Write-Host "✗ Copy failed! Error code: $LASTEXITCODE" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Copy complete (symlinks preserved)" -ForegroundColor Green

# Step 4: List packages before
Write-Host ""
Write-Host "4. Saving package list before installation..." -ForegroundColor Green
& "$TestPath\python_embeded\python.exe" -m pip list > "$TestPath\packages_before.txt"

Write-Host ""
Write-Host "=== READY FOR MANUAL TESTING ===" -ForegroundColor Cyan
Write-Host "1. Run ComfyUI from: $TestPath\run_nvidia_gpu.bat" -ForegroundColor White
Write-Host "2. Open ComfyUI Manager" -ForegroundColor White
Write-Host "3. Search for 'ComfyUI-Distributed'" -ForegroundColor White
Write-Host "4. Install it via Manager" -ForegroundColor White
Write-Host "5. Watch console for any pip activity" -ForegroundColor White
Write-Host "6. After installation, press any key to continue testing..." -ForegroundColor Yellow
Read-Host

# Step 5: Test after installation
Write-Host ""
Write-Host "5. Testing after Distributed installation..." -ForegroundColor Green

# Check numpy version again
$numpyVersionAfter = & "$TestPath\python_embeded\python.exe" -c "import numpy; print(numpy.__version__)" 2>&1
Write-Host "Numpy after: $numpyVersionAfter" -ForegroundColor Cyan

# Test Nunchaku
$nunchakuTestAfter = & "$TestPath\python_embeded\python.exe" -c "import nunchaku; print('Nunchaku ' + nunchaku.__version__ + ' OK')" 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Nunchaku still working: $nunchakuTestAfter" -ForegroundColor Green
    Write-Host ""
    Write-Host "=== RESULT: NO CONFLICT DETECTED ===" -ForegroundColor Green
} else {
    Write-Host "✗ Nunchaku broken!" -ForegroundColor Red
    Write-Host "Error: $nunchakuTestAfter" -ForegroundColor Red
    Write-Host ""
    Write-Host "=== RESULT: CONFLICT CONFIRMED ===" -ForegroundColor Red
}

# Save package list after
& "$TestPath\python_embeded\python.exe" -m pip list > "$TestPath\packages_after.txt"

# Compare packages
Write-Host ""
Write-Host "6. Package differences:" -ForegroundColor Green
$before = Get-Content "$TestPath\packages_before.txt"
$after = Get-Content "$TestPath\packages_after.txt"
Compare-Object $before $after | Where-Object { $_.SideIndicator -eq '=>' } | ForEach-Object {
    Write-Host "Added/Changed: $($_.InputObject)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Test complete. Test installation at: $TestPath" -ForegroundColor Cyan
