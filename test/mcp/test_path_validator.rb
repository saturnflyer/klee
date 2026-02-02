# frozen_string_literal: true

require_relative "test_helper"

class TestPathValidator < Minitest::Test
  def test_allows_patterns_within_current_directory
    validator = Klee::MCP::PathValidator.new(allowed_roots: [Dir.pwd])

    validator.validate!(["lib/**/*.rb"])
    validator.validate!(["./test/**/*.rb"])
    validator.validate!(["app/models/*.rb"])
    pass
  end

  def test_rejects_patterns_outside_allowed_roots
    validator = Klee::MCP::PathValidator.new(allowed_roots: ["/safe/path"])

    error = assert_raises(SecurityError) do
      validator.validate!(["/etc/passwd"])
    end

    assert_match(/outside allowed roots/, error.message)
  end

  def test_rejects_parent_directory_traversal
    validator = Klee::MCP::PathValidator.new(allowed_roots: ["/safe/path/project"])

    error = assert_raises(SecurityError) do
      validator.validate!(["../../../etc/passwd"])
    end

    assert_match(/outside allowed roots/, error.message)
  end

  def test_allows_multiple_roots
    validator = Klee::MCP::PathValidator.new(allowed_roots: ["/path/one", "/path/two"])

    validator.validate!(["/path/one/lib/*.rb"])
    validator.validate!(["/path/two/app/*.rb"])
    pass
  end
end
