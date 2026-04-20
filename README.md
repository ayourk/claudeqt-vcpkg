# claudeqt-vcpkg

[![Build Ports](https://github.com/ayourk/claudeqt-vcpkg/actions/workflows/build-ports.yml/badge.svg)](https://github.com/ayourk/claudeqt-vcpkg/actions/workflows/build-ports.yml)

vcpkg overlay registry for [ClaudeQt](https://github.com/ayourk/claudeqt) —
ports that aren't in vcpkg's main registry. Used by ClaudeQt's Windows
release builds.

## Packages

| Port | Version | License | Description |
|---|---|---|---|
| `extra-cmake-modules` | 5.115.0 | BSD-3-Clause | KDE Frameworks CMake helpers (arch-independent) |
| `kf5-syntax-highlighting` | 5.115.0 | Mixed ¹ | Syntax highlighting engine, built with `BUILD_WITH_QT6=ON` |

¹ KSH is a REUSE-compliant multi-licensed package: MIT for library
source plus GPL-2+/3+, LGPL-2.1+, Apache-2.0, BSD-3-Clause, CC0, WTFPL,
and a KDEeV variant across the bundled syntax-definition XML files.
The full license set is installed under
`share/kf5-syntax-highlighting/LICENSES/` — redistributors should
review those for compliance.

## Why these versions

Linux uses Qt 6.4.2 (Noble's stock `qt6-base-dev`) and KF5
SyntaxHighlighting 5.115.0 (the `kf5syntaxhighlighting-qt6` backport in
`ppa:ayourk/claudeqt`, not Noble stock). The 5.115 pin tracks Noble's
stock `extra-cmake-modules` (5.115.0) — the Debian `.deb` build-depends
on the system ECM, and KDE's release process ships each framework
aligned with a matching ECM release, so we stay on the matched tuple.

We pin the same versions on Windows so the built binaries exercise
identical library code across platforms.

## How ClaudeQt uses this registry

The main repo's `vcpkg-configuration.json` points here:

```json
{
  "default-registry": { "kind": "builtin", "baseline": "<pinned>" },
  "registries": [
    {
      "kind": "git",
      "repository": "https://github.com/ayourk/claudeqt-vcpkg",
      "baseline": "<pinned>",
      "packages": ["extra-cmake-modules", "kf5-syntax-highlighting"]
    }
  ]
}
```

## License

The port recipes here are MIT (see `LICENSE`) — small build scripts
that are most useful when unencumbered. The upstream libraries they
package retain their own licenses (see the Packages table above).
