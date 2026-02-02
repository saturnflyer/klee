# frozen_string_literal: true

require_relative "lib/klee/version"

Gem::Specification.new do |spec|
  spec.name = "klee"
  spec.version = Klee::VERSION
  spec.authors = ["Jim Gay"]
  spec.email = ["jim@saturnflyer.com"]

  spec.summary = "Evaluate the similarities and differences in your objects"
  spec.description = "Evaluate the similarities and differences in your objects. Art does not reflect what is seen, rather it makes the hidden visible."
  spec.homepage = "https://github.com/saturnflyer/klee"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.4.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/saturnflyer/klee"
  spec.metadata["changelog_uri"] = "https://github.com/saturnflyer/klee/blob/main/CHANGELOG.md"

  spec.files = File.read("Manifest.txt").split
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "prism"

  spec.post_install_message = <<~MSG
    klee installed successfully!

    For MCP server support (Claude Code integration), also install:
      gem install mcp

    Then run: klee-mcp
  MSG
end
