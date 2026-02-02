# frozen_string_literal: true

require "mcp"
require_relative "tools/discover_vocabulary"
require_relative "tools/find_concept_clusters"
require_relative "tools/explore_concept"
require_relative "tools/find_collaborators"
require_relative "tools/check_naming_consistency"
require_relative "tools/codebase_summary"

module Klee
  module MCP
    class Server
      TOOLS = [
        Tools::DiscoverVocabulary,
        Tools::FindConceptClusters,
        Tools::ExploreConcept,
        Tools::FindCollaborators,
        Tools::CheckNamingConsistency,
        Tools::CodebaseSummary
      ].freeze

      def initialize
        @server = ::MCP::Server.new(
          name: "klee",
          version: Klee::MCP::VERSION,
          tools: TOOLS
        )
      end

      def run
        transport = ::MCP::Server::Transports::StdioTransport.new(@server)
        transport.open
      end
    end
  end
end
