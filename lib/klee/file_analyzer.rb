# frozen_string_literal: true

require "prism"

module Klee
  class FileAnalyzer
    attr_reader :path, :class_names, :method_names, :collaborators, :method_collaborators

    def initialize(path)
      @path = path
      @class_names = []
      @method_names = []
      @collaborators = []
      @method_collaborators = Hash.new { |h, k| h[k] = [] }
      parse
    end

    private

    def parse
      result = Prism.parse_file(@path)
      visit(result.value, current_method: nil)
    end

    def visit(node, current_method:)
      case node
      when Prism::ClassNode, Prism::ModuleNode
        @class_names << node.name.to_s
      when Prism::DefNode
        @method_names << node.name.to_s
        current_method = node.name.to_s
      when Prism::CallNode
        name = extract_collaborator(node)
        if name
          @collaborators << name
          @method_collaborators[current_method] << name if current_method
        end
      end

      node.child_nodes.compact.each { |child| visit(child, current_method: current_method) }
    end

    def extract_collaborator(call_node)
      receiver = call_node.receiver
      case receiver
      when Prism::LocalVariableReadNode
        receiver.name.to_s
      when Prism::InstanceVariableReadNode
        receiver.name.to_s.delete_prefix("@")
      when Prism::CallNode
        # Chain like user.account.name - extract the root
        extract_collaborator(receiver)
      end
    end
  end
end
