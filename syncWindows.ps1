# 自动卸载软链接函数
function Unlink-DotfilesFromRepo {
    param(
        [switch]$DryRun
    )

    $mappings = @(
        @{ Name = 'WindowsTerminal'; Target = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" },
        @{ Name = 'Starship'; Target = Join-Path $env:USERPROFILE '.config\starship.toml' }
    )

    foreach ($map in $mappings) {
        $dst = $map.Target
        if (!(Test-Path $dst)) {
            Write-Host "Target for $($map.Name) not found: $dst. Skipping." -ForegroundColor Yellow
            continue
        }
        $item = Get-Item $dst -Force
        $isLink = ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0
        if ($isLink -and $item.LinkType -eq 'SymbolicLink') {
            if ($DryRun) {
                Write-Host "[DryRun] Would remove symlink: $dst -> $($item.Target)"
            } else {
                Remove-Item $dst -Force
                Write-Host "Removed symlink: $dst" -ForegroundColor Green
            }
        } else {
            Write-Host "Target for $($map.Name) is not a symbolic link: $dst. Skipping." -ForegroundColor Yellow
        }
    }
}

function Sync-WindowsDotfile {
    param(
        [Parameter(Mandatory=$true)]
        [string]$SourcePath,
        [Parameter(Mandatory=$true)]
        [string]$TargetPath,
        [switch]$DryRun
    )

    $targetDir = Split-Path $TargetPath -Parent
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

    if (Test-Path $TargetPath) {
        if ($DryRun) {
            Write-Host "[DryRun] Would backup existing file: $TargetPath -> $TargetPath.bak"
        } else {
            Write-Host "Backing up existing $(Split-Path $TargetPath -Leaf)..."
            Move-Item $TargetPath "$TargetPath.bak" -Force
        }
    }

    # 创建软链接（需要管理员权限）
    if ($DryRun) {
        Write-Host "[DryRun] Would create symlink: $TargetPath -> $SourcePath"
    } else {
        $symlinkCmd = "New-Item -ItemType SymbolicLink -Path `"$TargetPath`" -Value `"$SourcePath`" -Force"
        $psArgs = "-NoProfile -Command `$ErrorActionPreference='Stop'; $symlinkCmd"
        $process = Start-Process powershell -ArgumentList $psArgs -Verb RunAs -Wait -PassThru
        if ($process.ExitCode -eq 0) {
            Write-Host "Symlink created: $TargetPath -> $SourcePath" -ForegroundColor Green
        } else {
            Write-Host "Failed to create symlink. Exit code: $($process.ExitCode)" -ForegroundColor Red
        }
    }
}

function Sync-DotfilesFromRepo {
    param(
        [switch]$DryRun
    )

    # 使用脚本所在目录作为仓库根
    $repoRoot = $PSScriptRoot

    $mappings = @(
        @{ Name = 'WindowsTerminal'; Source = Join-Path $repoRoot 'WindowsTerminal\settings.json'; Target = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" },
        @{ Name = 'Starship'; Source = Join-Path $repoRoot '.config\starship.toml'; Target = Join-Path $env:USERPROFILE '.config\starship.toml' }
    )

    foreach ($map in $mappings) {
        $src = $map.Source
        $dst = $map.Target
        if (!(Test-Path $src)) {
            Write-Host "Source for $($map.Name) not found: $src. Skipping." -ForegroundColor Yellow
            continue
        }

        Write-Host "Processing $($map.Name):`n  Source: $src`n  Target: $dst"
        if ($DryRun) {
            Sync-WindowsDotfile -SourcePath $src -TargetPath $dst -DryRun
        } else {
            Sync-WindowsDotfile -SourcePath $src -TargetPath $dst
        }
    }
}


# ================== 示例调用 ==================
# 批量同步：
#   Sync-DotfilesFromRepo
# 批量 DryRun：
#   Sync-DotfilesFromRepo -DryRun
# 卸载软链接：
#   Unlink-DotfilesFromRepo
# 卸载软链接 DryRun：
#   Unlink-DotfilesFromRepo -DryRun

# 创建测试源文件
# 'this is a test file' | Set-Content -Encoding UTF8 $testSource

# 调用函数进行软链接测试
# Sync-WindowsDotfile -SourcePath $testSource -TargetPath $testSymlink

# Write-Host "测试完成，请手动检查："
# Write-Host "源文件：$testSource"
# Write-Host "软链接：$testSymlink"
