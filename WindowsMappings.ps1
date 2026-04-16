# Define the configuration file mappings to synchronize.
# This script is meant to be executed directly and returns a collection of mapping objects.

$repoRoot = $PSScriptRoot

$mappings = @(
    [PSCustomObject]@{
        Name = 'WindowsTerminal'
        Source = Join-Path $repoRoot 'WindowsTerminal\settings.json'
        Target = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    }
    [PSCustomObject]@{
        Name = 'Starship'
        Source = Join-Path $repoRoot '.config\starship.toml'
        Target = Join-Path $env:USERPROFILE '.config\starship.toml'
    }
)

$mappings
