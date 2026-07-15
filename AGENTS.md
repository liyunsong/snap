# AGENTS.md

## Cursor Cloud specific instructions

**This is a macOS-only application and cannot be built, run, or GUI-tested on the
Linux Cloud Agent environment.**

- `Snap` is a native macOS 13+ menu-bar screenshot app built with Swift Package
  Manager (`Package.swift`, executable target `SnapApp`).
- Every source file imports Apple-only frameworks — `SwiftUI`, `AppKit`,
  `ScreenCaptureKit`, `CoreImage`, `Combine` — and the sole external dependency
  (`KeyboardShortcuts`) is also macOS-only. These frameworks do **not** exist in
  the open-source Swift toolchain on Linux.
- Consequence on Linux: `swift package resolve` succeeds (deps download fine), but
  `swift build` fails almost immediately with `error: no such module 'SwiftUI'`
  (it fails inside the `KeyboardShortcuts` dependency before even reaching the app
  sources). There is no partial/headless target that compiles on Linux, so there
  is nothing useful to lint/test/build/run here.
- Requirements to actually develop this app (per `README.md` / `TESTING.md`):
  macOS 13.0+ (Ventura) with Xcode 15+ or the Swift 5.9+ toolchain, plus Screen
  Recording permission at runtime.

### Standard commands (run these on a macOS machine, not on the Linux Cloud Agent)
- Build (dev): `swift build` then `swift run` (see `build.sh`).
- Release build + packaging: `make release` (see `Makefile`; produces `.app`, ZIP, DMG).
- CI reference: `.github/workflows/release.yml` builds on `macos-13` with Xcode 15.
- Manual/functional test checklist: `TESTING.md`.

Because the runnable product requires macOS + Apple frameworks, do not attempt to
add a Linux build path or install the Swift-for-Linux toolchain in the update
script — it does not make the app buildable and only slows pod startup.
