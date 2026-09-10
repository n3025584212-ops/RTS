param(
 [string]$Godot='D:\godot\Godot_v4.7.1-stable_win64_console.exe',
 [ValidatePattern('^[A-Za-z0-9_-]+$')][string]$Label='hero_v2_01',
 [switch]$Interactive
)
$ErrorActionPreference='Stop'
$shotRoot=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$shotOut=Join-Path $shotRoot ('artifacts\visual_reset\'+$Label)
New-Item -ItemType Directory -Path $shotOut -Force | Out-Null
$version=(& $Godot --version | Out-String).Trim()
if ($version -notmatch '^4\.7\.1\.stable') {throw "Godot 4.7.1 stable required; found $version"}
& $Godot --headless --path $shotRoot --editor --import --quit res://scenes/production/RiverTownHeroShotV2.tscn
if ($LASTEXITCODE -ne 0){throw 'Import failed'}
$shotArgs=@('--path',$shotRoot,'--rendering-method','forward_plus','--audio-driver','Dummy','--resolution','1920x1080','--log-file',(Join-Path $shotOut 'runtime.log'),'res://scenes/production/RiverTownHeroShotV2.tscn','--','--view=hero_v2',"--capture-label=$Label")
if (-not $Interactive){$shotArgs+=@('--capture','--capture-frame=32')}
$started=[DateTime]::UtcNow
& $Godot @shotArgs
if ($LASTEXITCODE -ne 0){throw 'Runtime failed'}
if (-not $Interactive){
 $shotImage=Get-Item -LiteralPath (Join-Path $shotOut 'river_town_actual_1920x1080.png')
 if($shotImage.LastWriteTimeUtc -lt $started){throw 'No fresh capture'}
 $m=Get-Content -Raw -LiteralPath (Join-Path $shotOut 'runtime_metrics.json') | ConvertFrom-Json
 if($m.renderer -ne 'forward_plus' -or $m.width -ne 1920 -or $m.height -ne 1080 -or $m.save_error -ne 0){throw 'Invalid viewport evidence'}
}
