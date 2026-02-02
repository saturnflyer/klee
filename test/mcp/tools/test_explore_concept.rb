# frozen_string_literal: true

require_relative "../test_helper"

class TestExploreConcept < Minitest::Test
  include McpTestFixtures

  def test_explores_concept
    response = Klee::MCP::Tools::ExploreConcept.call(
      patterns: fixture_patterns,
      concept: "subscription",
      threshold: 1
    )

    assert_instance_of MCP::Tool::Response, response
    result = JSON.parse(response.content.first[:text])

    assert_equal "subscription", result["concept"]
    assert result.key?("appears_in")
    assert result.key?("co_occurs_with")
    assert result.key?("naming_patterns")
  end

  def test_finds_classes_and_methods
    response = Klee::MCP::Tools::ExploreConcept.call(
      patterns: fixture_patterns,
      concept: "subscription",
      threshold: 1
    )

    result = JSON.parse(response.content.first[:text])

    assert_includes result["appears_in"]["classes"], "Subscription"
    assert_kind_of Array, result["appears_in"]["methods"]
  end

  def test_identifies_naming_patterns
    response = Klee::MCP::Tools::ExploreConcept.call(
      patterns: fixture_patterns,
      concept: "subscription",
      threshold: 1
    )

    result = JSON.parse(response.content.first[:text])

    patterns = result["naming_patterns"]
    assert_kind_of Hash, patterns
  end

  def test_handles_missing_concept
    response = Klee::MCP::Tools::ExploreConcept.call(
      patterns: fixture_patterns,
      concept: "nonexistent_concept_xyz",
      threshold: 1
    )

    result = JSON.parse(response.content.first[:text])

    assert_equal "nonexistent_concept_xyz", result["concept"]
    assert_empty result["appears_in"]["classes"]
    assert_empty result["appears_in"]["methods"]
  end
end
