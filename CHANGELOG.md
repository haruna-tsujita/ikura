# Changelog

## [0.1.3] - 2026-04-21

### Added

- Auto-open browser when the server starts

## [0.1.2] - 2026-04-21

### Changed

- Rename `COORDS`/`coord` to `IKURA_POINTS`/`ikura_point` for clarity
- Adjust `IKURA_POINTS` coordinates and randomization range for better placement

### Fixed

- Remove `pointer-events` from gunkan/gunkan-top styles so clicks register correctly

## [0.1.1] - 2026-04-04

### Added

- MIT license
- Clickable URL in server output for quick access to the local server

### Changed

- Clean up gemspec and update gem description/metadata for RubyGems release

## [0.1.0] - 2026-04-02

### Added

- Initial release
- Interactive gunkan-maki sushi toy server
- Click on the sushi to place ikura (salmon roe) via Ruby running in WebAssembly
- Turbo Stream-based DOM updates without a frontend framework
