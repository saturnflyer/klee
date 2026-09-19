# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [1.0.0] - 2026-09-19

### Added

- Shared Words tokenizer with acronym splitting and predicate stripping (acff7d2)
- Nested class names, attr_* methods, and constant collaborators (18d27de)
- Klee.scan(profile: :rails) for models/lib globs and English stopwords (801fab2)
- ConceptIndex#catalog, #gaps, and #units (801fab2)

### Changed

- Concepts#[] returns a Hash of concept words to method names (acff7d2)
- FileAnalyzer records each message receiver, not only locals and ivars (18d27de)
- Klee::Collaborators wraps FileAnalyzer instead of lexing the file (18d27de)

### Fixed

- Klee.concepts now forwards the modifiers: keyword (acff7d2)
- Operator messages, block params, and conversion chains are ignored (18d27de)

## [0.1.2] - 2026-02-01

### Added

- MCP server support via klee-mcp executable (requires gem install mcp) (08c2294)
- discover_vocabulary tool for extracting domain language (08c2294)
- find_concept_clusters tool for identifying related concepts (08c2294)
- explore_concept tool for deep-diving into specific concepts (08c2294)
- find_collaborators tool for finding co-occurring objects (08c2294)
- check_naming_consistency tool for detecting naming deviations (08c2294)
- codebase_summary tool for high-level vocabulary overview (08c2294)

### Changed

- README now includes MCP server setup and available tools (f84bdc5)
