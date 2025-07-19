param(
    [string]$OutputPath = ".",
    [switch]$Compare,
    [string]$CompareWith
)

$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$baseFilename = "env_snapshot_$timestamp"

# Function to get all environment variables
function Get-AllEnvironmentVariables {
    $result = @{
        Process = [System.Environment]::GetEnvironmentVariables()
        User = [System.Environment]::GetEnvironmentVariables([System.EnvironmentVariableTarget]::User)
        Machine = [System.Environment]::GetEnvironmentVariables([System.EnvironmentVariableTarget]::Machine)
    }
    return $result
}

# Function to save environment snapshot
function Save-EnvironmentSnapshot {
    param([string]$Path)
    
    $env = Get-AllEnvironmentVariables
    
    # Save as JSON
    $jsonPath = Join-Path $Path "$baseFilename.json"
    $env | ConvertTo-Json -Depth 10 | Out-File -FilePath $jsonPath -Encoding UTF8
    Write-Host "Environment snapshot saved to: $jsonPath" -ForegroundColor Green
    
    # Save human-readable format
    $txtPath = Join-Path $Path "$baseFilename.txt"
    $output = @()
    $output += "Environment Variables Snapshot - $timestamp"
    $output += "=" * 60
    
    foreach ($scope in @("Process", "User", "Machine")) {
        $output += "`n[$scope Variables]"
        $output += "-" * 40
        foreach ($key in ($env[$scope].Keys | Sort-Object)) {
            $value = $env[$scope][$key]
            if ($value.Length -gt 100) {
                $value = $value.Substring(0, 97) + "..."
            }
            $output += "${key}: $value"
        }
    }
    
    $output | Out-File -FilePath $txtPath -Encoding UTF8
    Write-Host "Human-readable snapshot saved to: $txtPath" -ForegroundColor Green
    
    return $jsonPath
}

# Function to compare two snapshots
function Compare-EnvironmentSnapshots {
    param(
        [string]$Path1,
        [string]$Path2
    )
    
    $env1 = Get-Content $Path1 | ConvertFrom-Json
    $env2 = Get-Content $Path2 | ConvertFrom-Json
    
    Write-Host "`nEnvironment Variable Comparison" -ForegroundColor Yellow
    Write-Host "Before: $Path1"
    Write-Host "After: $Path2"
    Write-Host "=" * 60
    
    foreach ($scope in @("Process", "User", "Machine")) {
        Write-Host "`n[$scope Variables]" -ForegroundColor Cyan
        
        # Get all keys from both snapshots
        $keys1 = $env1.$scope.PSObject.Properties.Name
        $keys2 = $env2.$scope.PSObject.Properties.Name
        $allKeys = ($keys1 + $keys2) | Select-Object -Unique | Sort-Object
        
        foreach ($key in $allKeys) {
            $val1 = $env1.$scope.$key
            $val2 = $env2.$scope.$key
            
            if (-not $val1 -and $val2) {
                Write-Host "+ $key : $val2" -ForegroundColor Green
            }
            elseif ($val1 -and -not $val2) {
                Write-Host "- $key : $val1" -ForegroundColor Red
            }
            elseif ($val1 -ne $val2) {
                Write-Host "~ $key" -ForegroundColor Yellow
                Write-Host "  Before: $val1" -ForegroundColor DarkGray
                Write-Host "  After:  $val2" -ForegroundColor Gray
            }
        }
    }
}

# Main logic
if ($Compare -and $CompareWith) {
    if (Test-Path $CompareWith) {
        $currentSnapshot = Save-EnvironmentSnapshot -Path $OutputPath
        Compare-EnvironmentSnapshots -Path1 $CompareWith -Path2 $currentSnapshot
    }
    else {
        Write-Host "Error: Comparison file not found: $CompareWith" -ForegroundColor Red
    }
}
else {
    Save-EnvironmentSnapshot -Path $OutputPath
}
