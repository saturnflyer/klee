# frozen_string_literal: true

require_relative "../test_helper"

class TestDiscoverVocabulary < Minitest::Test
  include McpTestFixtures

  def test_discovers_vocabulary_from_codebase
    response = Klee::MCP::Tools::DiscoverVocabulary.call(
      patterns: fixture_patterns,
      threshold: 1,
      limit: 20
    )

    assert_instance_of MCP::Tool::Response, response
    result = JSON.parse(response.content.first[:text])

    vocabulary = result["vocabulary"]
    assert_kind_of Array, vocabulary

    words = vocabulary.map { |v| v["word"] }
    assert_includes words, "subscription"
    assert_includes words, "order"
    assert_includes words, "invoice"
  end

  def test_respects_threshold
    response = Klee::MCP::Tools::DiscoverVocabulary.call(
      patterns: fixture_patterns,
      threshold: 5,
      limit: 20
    )

    result = JSON.parse(response.content.first[:text])
    vocabulary = result["vocabulary"]

    vocabulary.each do |v|
      assert v["frequency"] >= 5, "#{v["word"]} has frequency #{v["frequency"]} but threshold is 5"
    end
  end

  def test_respects_limit
    response = Klee::MCP::Tools::DiscoverVocabulary.call(
      patterns: fixture_patterns,
      threshold: 1,
      limit: 3
    )

    result = JSON.parse(response.content.first[:text])
    assert result["vocabulary"].size <= 3
  end

  def test_includes_class_and_method_locations
    response = Klee::MCP::Tools::DiscoverVocabulary.call(
      patterns: fixture_patterns,
      threshold: 1,
      limit: 30
    )

    result = JSON.parse(response.content.first[:text])
    subscription = result["vocabulary"].find { |v| v["word"] == "subscription" }

    assert subscription
    assert_kind_of Array, subscription["in_classes"]
    assert_kind_of Array, subscription["in_methods"]
  end
end
