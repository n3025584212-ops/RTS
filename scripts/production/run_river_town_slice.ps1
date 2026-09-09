param(
    [string]$Godot = 'D:\godot\Godot_v4.7.1-stable_win64_console.exe',
    [switch]$Interactive,
    [ValidateRange(1,180)][int]$CaptureFrame = 32,
    [ValidateSet('reference','hero','ground')][string]$View = 'reference',
    [ValidatePattern('^[A-Za-z0-9_-]+$')][string]$Label = 'local_high_fidelity',
    [switch]$GeometryProof
)
$ErrorActionPreference = 'Stop'
$sliceRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$sliceEvidence = Join-Path $sliceRoot 'artifacts\visual_reset'
$captureStarted = [DateTime]::UtcNow
New-Item -ItemType Directory -Path $sliceEvidence -Force | Out-Null
$engineVersion = (& $Godot --version | Out-String).Trim()
if ($engineVersion -notmatch '^4\.7\.1\.stable') { throw "This evidence requires Godot 4.7.1 stable. Found: $engineVersion" }
& $Godot --headless --path $sliceRoot --editor --import --quit --log-file (Join-Path $sliceEvidence 'import.log') res://scenes/production/RiverTownVisualSlice.tscn
if ($LASTEXITCODE -ne 0) { throw 'Godot import failed.' }
$sliceArgs = @('--path',$sliceRoot,'--rendering-method','forward_plus','--audio-driver','Dummy','--resolution','1920x1080','--log-file',(Join-Path $sliceEvidence 'runtime.log'),'res://scenes/production/RiverTownVisualSlice.tscn')
if (-not $Interactive) { $sliceArgs += @('--quit-after',([string]($CaptureFrame+4)),'--','--capture',"--capture-frame=$CaptureFrame","--capture-label=$Label","--view=$View") }
if ($Interactive) { $sliceArgs += @('--',"--view=$View") }
if ($GeometryProof) { $sliceArgs += '--geometry-proof' }
& $Godot @sliceArgs
if ($LASTEXITCODE -ne 0) { throw 'Godot runtime failed.' }
$captureArtifact = Join-Path (Join-Path $sliceEvidence $Label) 'river_town_actual_1920x1080.png'
if (-not $Interactive -and -not (Test-Path -LiteralPath $captureArtifact)) { throw 'No runtime screenshot was produced.' }
if (-not $Interactive -and (Get-Item -LiteralPath $captureArtifact).LastWriteTimeUtc -lt $captureStarted) { throw 'Runtime did not produce a fresh screenshot. Previous evidence was preserved.' }
if (-not $Interactive) {
    $metrics = Get-Content -LiteralPath (Join-Path (Split-Path $captureArtifact) 'runtime_metrics.json') -Raw | ConvertFrom-Json
    if ($metrics.renderer -ne 'forward_plus' -or $metrics.width -ne 1920 -or $metrics.height -ne 1080 -or $metrics.save_error -ne 0) { throw 'Capture did not meet the Forward+ / 1920x1080 evidence contract.' }
}
