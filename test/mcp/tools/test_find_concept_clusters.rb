# frozen_string_literal: true

require_relative "../test_helper"

class TestFindConceptClusters < Minitest::Test
  include McpTestFixtures

  def test_finds_concept_clusters
    response = Klee::MCP::Tools::FindConceptClusters.call(
      patterns: fixture_patterns,
      threshold: 1
    )

    assert_instance_of MCP::Tool::Response, response
    result = JSON.parse(response.content.first[:text])

    clusters = result["clusters"]
    assert_kind_of Array, clusters
  end

  def test_clusters_have_required_fields
    response = Klee::MCP::Tools::FindConceptClusters.call(
      patterns: fixture_patterns,
      threshold: 1
    )

    result = JSON.parse(response.content.first[:text])

    result["clusters"].each do |cluster|
      assert cluster.key?("concepts"), "Cluster missing 'concepts' key"
      assert cluster.key?("size"), "Cluster missing 'size' key"
      assert_kind_of Array, cluster["concepts"]
      assert_kind_of Integer, cluster["size"]
    end
  end

  def test_clusters_are_sorted_by_size
    response = Klee::MCP::Tools::FindConceptClusters.call(
      patterns: fixture_patterns,
      threshold: 1
    )

    result = JSON.parse(response.content.first[:text])
    clusters = result["clusters"]

    return if clusters.size < 2

    sizes = clusters.map { |c| c["size"] }
    assert_equal sizes, sizes.sort.reverse, "Clusters should be sorted by size descending"
  end
end
