param(
    [switch]$DryRun
)

$mappingScript = Join-Path $PSScriptRoot 'WindowsMappings.ps1'
$mappings = & $mappingScript

foreach ($map in $mappings) {
    $src = $map.Source
    $dst = $map.Target

    if (!(Test-Path $src)) {
        Write-Host "Source for $($map.Name) not found: $src. Skipping." -ForegroundColor Yellow
        continue
    }

    Write-Host "Processing $($map.Name):`n  Source: $src`n  Target: $dst"

    $targetDir = Split-Path $dst -Parent
    if (!(Test-Path $targetDir)) {
        if ($DryRun) {
            Write-Host "[DryRun] Would create directory: $targetDir"
        } else {
            New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
            Write-Host "Created directory: $targetDir"
        }
    } else {
        Write-Host "Target directory exists: $targetDir"
    }

    if (Test-Path $dst) {
        if ($DryRun) {
            Write-Host "[DryRun] Would backup existing file: $dst -> $dst.bak"
        } else {
            Write-Host "Backing up existing target: $dst"
            Move-Item -Path $dst -Destination "$dst.bak" -Force
        }
    }

    if ($DryRun) {
        Write-Host "[DryRun] Would create symlink: $dst -> $src"
        continue
    }

    $symlinkCmd = "New-Item -ItemType SymbolicLink -Path `"$dst`" -Value `"$src`" -Force"
    $psArgs = "-NoProfile -Command `$ErrorActionPreference='Stop'; $symlinkCmd"
    $process = Start-Process powershell -ArgumentList $psArgs -Verb RunAs -Wait -PassThru

    if ($process.ExitCode -eq 0) {
        Write-Host "Symlink created: $dst -> $src" -ForegroundColor Green
    } else {
        Write-Host "Failed to create symlink for $($map.Name). Exit code: $($process.ExitCode)" -ForegroundColor Red
    }
}
