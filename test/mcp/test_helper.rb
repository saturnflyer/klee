# frozen_string_literal: true

require "test_helper"
require "klee/mcp"

module McpTestFixtures
  FIXTURES_DIR = File.expand_path("fixtures", __dir__)

  def fixture_patterns
    [File.join(FIXTURES_DIR, "**/*.rb")]
  end
end
