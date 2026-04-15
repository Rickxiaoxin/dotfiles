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


# ================== 测试代码 ==================
# 仅操作 $env:TEMP 下的测试文件，便于手动检查软链接功能
# $testSource = "$env:TEMP\test_source.txt"
# $testSymlink = "$env:TEMP\test_symlink.txt"

# 创建测试源文件
# 'this is a test file' | Set-Content -Encoding UTF8 $testSource

# 调用函数进行软链接测试
# Sync-WindowsDotfile -SourcePath $testSource -TargetPath $testSymlink

# Write-Host "测试完成，请手动检查："
# Write-Host "源文件：$testSource"
# Write-Host "软链接：$testSymlink"
