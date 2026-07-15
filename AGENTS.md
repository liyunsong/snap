# AGENTS.md

## Cursor Cloud specific instructions

**This is a macOS-only application and cannot be built, run, or GUI-tested on the
Linux Cloud Agent environment.**

- `Snap` is a native **macOS 15+** menu-bar screenshot app built with Swift Package
  Manager (`Package.swift`, executable target `SnapApp`). The minimum is macOS 15
  (Sequoia) and is optimized for **Apple Silicon only** (arm64). Screenshot capture
  uses `SCScreenshotManager` (ScreenCaptureKit, 13+) and SwiftUI features.
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
  macOS 14.0+ (Sonoma) with Xcode 15+ or the Swift 5.9+ toolchain, plus Screen
  Recording permission at runtime.

### How to build/package (cloud, since local Linux cannot build)
- **Preferred: GitHub Actions on macOS.** `.github/workflows/ci.yml` builds & packages
  on `macos-14` (universal `.app` + ZIP + DMG, uploaded as artifacts) on every PR /
  push to `main` / manual dispatch. `.github/workflows/release.yml` builds on
  `macos-14` and publishes a GitHub Release when a `v*.*.*` tag is pushed.
  Note: macOS runners need a public repo or an enabled Actions spending limit
  (macOS minutes bill at 10x); otherwise runs stay `queued`.
- On a macOS machine: `swift build` then `swift run` (see `build.sh`); or
  `make release` (see `Makefile`) to produce `.app`, ZIP, DMG.
- Manual/functional test checklist: `TESTING.md`.

Because the runnable product requires macOS + Apple frameworks, do not attempt to
add a Linux build path or install the Swift-for-Linux toolchain in the update
script — it does not make the app buildable and only slows pod startup.
