# Editable Blender source

The completed local delivery includes `repair_workshop_source.blend` (packed
images, 203,872,240 bytes). This file exceeds GitHub's regular 100 MiB per-file
limit, so it is not committed as an ordinary Git blob.

The repository instead contains the fully reconstructible source required for this
asset: `tools/industrial/build_workshop.py`, the original CC0 factory geometry in
`tools/industrial/source_geometry/`, immutable source URL/MD5/SHA256 locks, and the
complete material, LOD, GLB packaging and sanitation tools. `rebuild.ps1` recreates
this packed Blender file as well as the runtime assets. See the delivery document.

`.gdignore` prevents Godot from implicitly importing authoring files. The three
runtime GLBs live one directory above and share its `textures/` directory.
