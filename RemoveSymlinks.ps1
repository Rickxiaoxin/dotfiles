param(
    [switch]$DryRun
)

$mappingScript = Join-Path $PSScriptRoot 'WindowsMappings.ps1'
$mappings = & $mappingScript

foreach ($map in $mappings) {
    $dst = $map.Target

    if (!(Test-Path $dst)) {
        Write-Host "Target for $($map.Name) not found: $dst. Skipping." -ForegroundColor Yellow
        continue
    }

    $item = Get-Item -Path $dst -Force
    $isLink = ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0

    if ($isLink -and $item.LinkType -eq 'SymbolicLink') {
        if ($DryRun) {
            Write-Host "[DryRun] Would remove symlink: $dst -> $($item.Target)"
        } else {
            Remove-Item -Path $dst -Force
            Write-Host "Removed symlink: $dst" -ForegroundColor Green
        }
    } else {
        Write-Host "Target for $($map.Name) is not a symbolic link: $dst. Skipping." -ForegroundColor Yellow
    }
}
