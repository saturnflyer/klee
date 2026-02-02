# frozen_string_literal: true

require_relative "test_helper"

class TestMcpServer < Minitest::Test
  def test_server_initializes_with_all_tools
    server = Klee::MCP::Server.new

    assert_instance_of Klee::MCP::Server, server
  end

  def test_server_has_expected_tools
    expected_tools = [
      Klee::MCP::Tools::DiscoverVocabulary,
      Klee::MCP::Tools::FindConceptClusters,
      Klee::MCP::Tools::ExploreConcept,
      Klee::MCP::Tools::FindCollaborators,
      Klee::MCP::Tools::CheckNamingConsistency,
      Klee::MCP::Tools::CodebaseSummary
    ]

    assert_equal expected_tools, Klee::MCP::Server::TOOLS
  end
end
