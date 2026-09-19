# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [1.0.1] - Unreleased

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
