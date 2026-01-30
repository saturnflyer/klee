# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [0.1.2] - Unreleased

## [0.1.1] - 2026-01-29

### Changed

- Switch to supporting ruby 3.4 and up. (84fdd9c)
- Require ruby 3.4 and above (067ec87)

### Added

- Reissue for version and release support. (885fe28)
- SimpleCov for coverage reporting (889d169)
- Coverage comment from PRs (067ec87)
- Klee.scan() method for codebase-wide analysis with glob patterns (3e509a1)
- ConceptIndex for aggregating domain concepts across files (3e509a1)
- CollaboratorIndex for pairwise co-occurrence and clustering (3e509a1)
- FileAnalyzer using Prism AST to extract classes, methods, and collaborators (3e509a1)
- Configurable threshold and ignore list for filtering noise (3e509a1)
- Method-level scope option for tighter coupling analysis (3e509a1)
