param(
 [string]$Blender='D:\Agent\frontline-visual-reset\tools\blender-4.5.9-windows-x64\blender.exe',
 [string]$Python='python',
 [string]$Godot='D:\godot\Godot_v4.7.1-stable_win64_console.exe',
 [string]$SourceDir=''
)
$ErrorActionPreference='Stop'
$repoRoot=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
if(-not $SourceDir){$SourceDir=Join-Path (Split-Path $repoRoot) 'source'}
$output=Join-Path $repoRoot 'assets/visual_slice/industrial_workshop'
& $Python (Join-Path $PSScriptRoot 'acquire_factory.py') --source-dir (Join-Path $SourceDir 'factory')
if($LASTEXITCODE -ne 0){throw 'Factory source checksum/download failed'}
& $Python (Join-Path $PSScriptRoot 'acquire_roof.py') (Join-Path $SourceDir 'roof')
if($LASTEXITCODE -ne 0){throw 'Roof source checksum/download failed'}
& $Blender -b --python (Join-Path $PSScriptRoot 'build_workshop.py') -- --source-dir $SourceDir --output-dir $output
if($LASTEXITCODE -ne 0){throw 'Blender build failed'}
& $Python (Join-Path $PSScriptRoot 'share_glb_textures.py') $output
if($LASTEXITCODE -ne 0){throw 'Texture packaging failed; Python requires Pillow'}
& $Python (Join-Path $PSScriptRoot 'sanitize_glb.py') $output
if($LASTEXITCODE -ne 0){throw 'Export sanitation failed; Python requires NumPy'}
& $Python (Join-Path $PSScriptRoot 'validate_geometry.py')
if($LASTEXITCODE -ne 0){throw 'Exported geometry validation failed'}
& $Python (Join-Path $PSScriptRoot 'validate_texel_density.py')
if($LASTEXITCODE -ne 0){throw 'Masonry UV scale validation failed'}
& $Python (Join-Path $PSScriptRoot 'audit_gltf.py')
if($LASTEXITCODE -ne 0){throw 'glTF audit failed'}
& $Godot --headless --path $repoRoot --editor --import --quit res://scenes/production/RiverTownWorkshopValidation.tscn
if($LASTEXITCODE -ne 0){throw 'Godot import failed'}
& $Godot --headless --path $repoRoot --script res://tools/industrial/verify_godot.gd
if($LASTEXITCODE -ne 0){throw 'Godot material/UV/LOD validation failed'}
