# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.5]
### Changed
- Now `require 'twisty_puzzles'` also requires the native extensions.

## [0.0.4]
### Fixed
Fixed path in extconf.

## [0.0.3]
### Fixed
Added extension source files to gem files.

## [0.0.2]
### Changed
- Now a simple `require 'twisty_puzzles'` is enough, users don't need to require files separately.

### Fixed
- Syntax error in file that wasn't included in tests previously.
- Rubocop fixes across the codebase.

## [0.0.1]
### Added
- Split off core twisty puzzles functionality from cube_trainer repo into a Gem.
