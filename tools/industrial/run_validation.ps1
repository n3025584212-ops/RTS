param(
 [string]$Godot='D:\godot\Godot_v4.7.1-stable_win64_console.exe',
 [ValidateSet('workshop','rear','detail','overview','reference')][string]$View='workshop',
 [ValidateRange(-1,2)][int]$Lod=-1,
 [ValidatePattern('^[A-Za-z0-9_-]+$')][string]$Label='workshop_review',
 [switch]$Interactive,
 [switch]$SkipImport
)
$ErrorActionPreference='Stop'
$repoRoot=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$out=Join-Path $repoRoot ('artifacts/visual_reset/'+$Label)
New-Item -ItemType Directory -Path $out -Force | Out-Null
$version=(& $Godot --version | Out-String).Trim()
if($version -notmatch '^4\.7\.1\.stable'){throw "Required Godot 4.7.1; found $version"}
if(-not $SkipImport){
 & $Godot --headless --path $repoRoot --editor --import --quit --log-file (Join-Path $out 'import.log') res://scenes/production/RiverTownWorkshopValidation.tscn
 if($LASTEXITCODE -ne 0){throw 'Import failed'}
}
$arguments=@('--path',$repoRoot,'--rendering-method','forward_plus','--audio-driver','Dummy','--resolution','1920x1080','--log-file',(Join-Path $out 'runtime.log'),'res://scenes/production/RiverTownWorkshopValidation.tscn','--',"--asset-view=$View","--asset-lod=$Lod","--capture-label=$Label")
if(-not $Interactive){$arguments+=@('--capture','--capture-frame=32')}
$started=[DateTime]::UtcNow
& $Godot @arguments
if($LASTEXITCODE -ne 0){throw 'Runtime failed'}
if(-not $Interactive){
 $file=Get-Item -LiteralPath (Join-Path $out 'river_town_actual_1920x1080.png')
 if($file.LastWriteTimeUtc -lt $started){throw 'Fresh capture missing'}
 $metrics=Get-Content -Raw (Join-Path $out 'runtime_metrics.json') | ConvertFrom-Json
 if($metrics.engine.string -notmatch '^4.7.1' -or $metrics.renderer -ne 'forward_plus' -or $metrics.width -ne 1920 -or $metrics.height -ne 1080 -or $metrics.save_error -ne 0){throw 'Invalid runtime evidence'}
}
