param(
    [string]$Godot = 'D:\godot\Godot_v4.7.1-stable_win64_console.exe',
    [switch]$Interactive
)
$ErrorActionPreference = 'Stop'
$sliceRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$sliceEvidence = Join-Path $sliceRoot 'artifacts\visual_reset'
New-Item -ItemType Directory -Path $sliceEvidence -Force | Out-Null
$engineVersion = (& $Godot --version | Out-String).Trim()
if ($engineVersion -notmatch '^4\.7\.1\.stable') { throw "This evidence requires Godot 4.7.1 stable. Found: $engineVersion" }
& $Godot --headless --path $sliceRoot --editor --import --quit --log-file (Join-Path $sliceEvidence 'import.log')
if ($LASTEXITCODE -ne 0) { throw 'Godot import failed.' }
$sliceArgs = @('--path',$sliceRoot,'--rendering-method','forward_plus','--audio-driver','Dummy','--resolution','1920x1080','--log-file',(Join-Path $sliceEvidence 'runtime.log'),'res://scenes/production/RiverTownVisualSlice.tscn')
if (-not $Interactive) { $sliceArgs += @('--','--capture') }
& $Godot @sliceArgs
if ($LASTEXITCODE -ne 0) { throw 'Godot runtime failed.' }
if (-not $Interactive -and -not (Test-Path -LiteralPath (Join-Path $sliceEvidence 'river_town_actual_1920x1080.png'))) { throw 'No runtime screenshot was produced.' }
