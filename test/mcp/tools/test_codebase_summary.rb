# frozen_string_literal: true

require_relative "../test_helper"

class TestCodebaseSummary < Minitest::Test
  include McpTestFixtures

  def test_returns_codebase_summary
    response = Klee::MCP::Tools::CodebaseSummary.call(
      patterns: fixture_patterns,
      threshold: 1
    )

    assert_instance_of MCP::Tool::Response, response
    result = JSON.parse(response.content.first[:text])

    assert result.key?("top_concepts")
    assert result.key?("concept_clusters")
    assert result.key?("total_classes")
    assert result.key?("total_methods")
    assert result.key?("vocabulary_richness")
    assert result.key?("cluster_preview")
  end

  def test_top_concepts_includes_expected_words
    response = Klee::MCP::Tools::CodebaseSummary.call(
      patterns: fixture_patterns,
      threshold: 1
    )

    result = JSON.parse(response.content.first[:text])
    top = result["top_concepts"]

    assert_kind_of Array, top
    assert top.size <= 15
  end

  def test_counts_classes_and_methods
    response = Klee::MCP::Tools::CodebaseSummary.call(
      patterns: fixture_patterns,
      threshold: 1
    )

    result = JSON.parse(response.content.first[:text])

    assert_kind_of Integer, result["total_classes"]
    assert_kind_of Integer, result["total_methods"]
    assert result["total_classes"] > 0
    assert result["total_methods"] > 0
  end

  def test_calculates_vocabulary_richness
    response = Klee::MCP::Tools::CodebaseSummary.call(
      patterns: fixture_patterns,
      threshold: 1
    )

    result = JSON.parse(response.content.first[:text])

    richness = result["vocabulary_richness"]
    assert_kind_of Float, richness
    assert richness >= 0
    assert richness <= 1
  end

  def test_includes_cluster_preview
    response = Klee::MCP::Tools::CodebaseSummary.call(
      patterns: fixture_patterns,
      threshold: 1
    )

    result = JSON.parse(response.content.first[:text])

    preview = result["cluster_preview"]
    assert_kind_of Array, preview
    assert preview.size <= 3
  end
end
