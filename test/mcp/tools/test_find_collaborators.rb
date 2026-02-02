# frozen_string_literal: true

require_relative "../test_helper"

class TestFindCollaborators < Minitest::Test
  include McpTestFixtures

  def test_finds_collaborators
    response = Klee::MCP::Tools::FindCollaborators.call(
      patterns: fixture_patterns,
      object: "subscription",
      threshold: 1
    )

    assert_instance_of MCP::Tool::Response, response
    result = JSON.parse(response.content.first[:text])

    assert_equal "subscription", result["object"]
    assert_kind_of Array, result["collaborators"]
  end

  def test_collaborators_have_required_fields
    response = Klee::MCP::Tools::FindCollaborators.call(
      patterns: fixture_patterns,
      object: "subscription",
      threshold: 1
    )

    result = JSON.parse(response.content.first[:text])

    result["collaborators"].each do |collab|
      assert collab.key?("name"), "Collaborator missing 'name' key"
      assert collab.key?("co_occurrences"), "Collaborator missing 'co_occurrences' key"
      assert collab.key?("scope"), "Collaborator missing 'scope' key"
    end
  end

  def test_respects_scope_parameter
    file_response = Klee::MCP::Tools::FindCollaborators.call(
      patterns: fixture_patterns,
      object: "order",
      threshold: 1,
      scope: "file"
    )

    method_response = Klee::MCP::Tools::FindCollaborators.call(
      patterns: fixture_patterns,
      object: "order",
      threshold: 1,
      scope: "method"
    )

    file_result = JSON.parse(file_response.content.first[:text])
    method_result = JSON.parse(method_response.content.first[:text])

    file_result["collaborators"].each do |c|
      assert_equal "file", c["scope"]
    end

    method_result["collaborators"].each do |c|
      assert_equal "method", c["scope"]
    end
  end

  def test_collaborators_sorted_by_occurrences
    response = Klee::MCP::Tools::FindCollaborators.call(
      patterns: fixture_patterns,
      object: "subscription",
      threshold: 1
    )

    result = JSON.parse(response.content.first[:text])
    collabs = result["collaborators"]

    return if collabs.size < 2

    counts = collabs.map { |c| c["co_occurrences"] }
    assert_equal counts, counts.sort.reverse, "Collaborators should be sorted by co_occurrences descending"
  end
end
