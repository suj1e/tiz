#!/usr/bin/env python3
"""Extract pypi-dependencies from pixi.toml to requirements.txt."""

import toml

with open('pixi.toml') as f:
    data = toml.load(f)

deps = data.get('pypi-dependencies', {})

with open('requirements.txt', 'w') as f:
    for pkg, spec in deps.items():
        if isinstance(spec, str):
            f.write(f'{pkg}{spec}\n')
        elif isinstance(spec, dict):
            extras = ','.join(spec.get('extras', []))
            version = spec.get('version', '')
            if extras:
                f.write(f'{pkg}[{extras}]{version}\n')
            else:
                f.write(f'{pkg}{version}\n')
