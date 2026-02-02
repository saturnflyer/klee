# frozen_string_literal: true

require_relative "../test_helper"

class TestCheckNamingConsistency < Minitest::Test
  include McpTestFixtures

  def test_checks_naming_consistency
    response = Klee::MCP::Tools::CheckNamingConsistency.call(
      patterns: fixture_patterns,
      conventions: {
        prefixes: ["find_", "create_"],
        suffixes: ["?", "!"]
      }
    )

    assert_instance_of MCP::Tool::Response, response
    result = JSON.parse(response.content.first[:text])

    assert result.key?("conforming")
    assert result.key?("unusual")
  end

  def test_groups_conforming_methods_by_pattern
    response = Klee::MCP::Tools::CheckNamingConsistency.call(
      patterns: fixture_patterns,
      conventions: {
        prefixes: ["find_", "create_"],
        suffixes: ["?"]
      }
    )

    result = JSON.parse(response.content.first[:text])
    conforming = result["conforming"]

    assert_kind_of Hash, conforming
  end

  def test_identifies_unusual_methods
    response = Klee::MCP::Tools::CheckNamingConsistency.call(
      patterns: fixture_patterns,
      conventions: {
        prefixes: ["find_", "create_"]
      }
    )

    result = JSON.parse(response.content.first[:text])
    unusual = result["unusual"]

    assert_kind_of Array, unusual

    unusual_methods = unusual.map { |u| u["method"] }
    assert_includes unusual_methods, "get_total"
  end

  def test_suggests_similar_conforming_methods
    response = Klee::MCP::Tools::CheckNamingConsistency.call(
      patterns: fixture_patterns,
      conventions: {
        prefixes: ["find_", "create_"]
      },
      threshold: 10
    )

    result = JSON.parse(response.content.first[:text])

    with_suggestions = result["unusual"].select { |u| u["suggestion"] }
    assert_kind_of Array, with_suggestions
  end

  def test_works_without_conventions
    response = Klee::MCP::Tools::CheckNamingConsistency.call(
      patterns: fixture_patterns
    )

    result = JSON.parse(response.content.first[:text])

    assert result.key?("conforming")
    assert result.key?("unusual")
  end
end
