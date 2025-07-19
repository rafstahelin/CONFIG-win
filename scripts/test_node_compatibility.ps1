param(
    [string]$NodeName,
    [string]$TestPythonPath = "python_embeded_testing"
)

Write-Host "Testing $NodeName compatibility..." -ForegroundColor Yellow

# Check numpy version
$numpyVersion = & "$TestPythonPath\python.exe" -c "import numpy; print(numpy.__version__)"
Write-Host "Numpy version: $numpyVersion"

# Test imports
try {
    & "$TestPythonPath\python.exe" -c "import nunchaku; print('Nunchaku OK')"
} catch {
    Write-Host "Nunchaku import failed!" -ForegroundColor Red
}

# List potentially conflicting packages
Write-Host "`nPotentially conflicting packages:" -ForegroundColor Yellow
& "$TestPythonPath\python.exe" -m pip list | Select-String -Pattern "numpy|torch|triton|sage"
