"""Fetch the exact CC0 modular building source used by Hero Shot V2.

Only needed to rebuild the derivative. The game uses committed exported assets.
Usage: python fetch_hero_v2_sources.py <cache-directory>
"""
import argparse
import hashlib
import json
from pathlib import Path
from urllib.request import urlopen

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('cache_directory', type=Path)
args = parser.parse_args()
root = Path(__file__).resolve().parents[2]
manifest = json.loads((root / 'assets/visual_slice/hero_v2/urban_source_manifest.json').read_text(encoding='utf-8'))
destination = args.cache_directory.resolve()
for entry in manifest:
    target = (destination / entry['path']).resolve()
    if not target.is_relative_to(destination):
        raise ValueError('Source path escapes the cache directory')
    if target.exists() and hashlib.md5(target.read_bytes()).hexdigest() == entry['md5']:
        print('Verified', entry['path'])
        continue
    with urlopen(entry['url'], timeout=120) as response:
        data = response.read()
    if len(data) != entry['bytes'] or hashlib.md5(data).hexdigest() != entry['md5']:
        raise ValueError('Source checksum mismatch: ' + entry['path'])
    target.parent.mkdir(parents=True, exist_ok=True)
    temporary = target.with_name(target.name + '.download')
    temporary.write_bytes(data)
    temporary.replace(target)
    print('Downloaded', entry['path'])
