# frozen_string_literal: true

require "prism"

module Klee
  class FileAnalyzer
    ATTR_METHODS = %i[attr attr_reader attr_writer attr_accessor].freeze
    INDEX_OPERATORS = Set[:[], :[]=].freeze
    OPERATORS = Set.new(
      %i[! != !~ + +@ - -@ * / % ** << >> & | ^ ~ <=> > >= < <= == === =~] +
      INDEX_OPERATORS.to_a
    ).freeze
    CHAIN_NOISE = %w[
      to_s to_str to_i to_int to_a to_ary to_h to_hash to_f to_sym to_proc
      intern itself dup clone freeze tap new
      where includes joins order limit offset eager_load preload
      unscope merge distinct group having lock reselect reorder
      first last take count map select collect compact flatten uniq
      sort sort_by reverse each
      Hash Array Set Rails Data Logger Kernel Object
    ].to_set.freeze

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
      visit(result.value, current_method: nil, namespace: [], block_params: Set.new)
    end

    def visit(node, current_method:, namespace:, block_params:)
      case node
      when Prism::ClassNode, Prism::ModuleNode
        full_name = qualified_name(node, namespace)
        @class_names << full_name
        nested = full_name.split("::")
        node.child_nodes.compact.each do |child|
          visit(child, current_method: current_method, namespace: nested, block_params: block_params)
        end
        return
      when Prism::DefNode
        @method_names << node.name.to_s
        current_method = node.name.to_s
      when Prism::BlockNode, Prism::LambdaNode
        nested_params = block_params | Array(node.locals).map(&:to_s)
        node.child_nodes.compact.each do |child|
          visit(child, current_method: current_method, namespace: namespace, block_params: nested_params)
        end
        return
      when Prism::CallNode
        # Walk the receiver first so `user.account` records left-to-right.
        if (receiver = node.receiver)
          visit(receiver, current_method: current_method, namespace: namespace, block_params: block_params)
        end
        record_call(node, current_method, block_params)
        node.child_nodes.compact.each do |child|
          next if child.equal?(receiver)

          visit(child, current_method: current_method, namespace: namespace, block_params: block_params)
        end
        return
      end

      node.child_nodes.compact.each do |child|
        visit(child, current_method: current_method, namespace: namespace, block_params: block_params)
      end
    end

    def record_call(node, current_method, block_params)
      if attr_call?(node)
        @method_names.concat(attr_names(node))
        return
      end

      return if skip_operator_call?(node)

      name = extract_collaborator(node)
      return if skip_collaborator?(name, block_params)

      @collaborators << name
      @method_collaborators[current_method] << name if current_method
    end

    def skip_operator_call?(node)
      OPERATORS.include?(node.name) && !INDEX_OPERATORS.include?(node.name)
    end

    def skip_collaborator?(name, block_params)
      return true if name.nil? || block_params.include?(name)

      key = name.to_sym
      OPERATORS.include?(key) || CHAIN_NOISE.include?(name)
    end

    def attr_call?(node)
      node.receiver.nil? && ATTR_METHODS.include?(node.name)
    end

    def attr_names(node)
      args = node.arguments&.arguments || []
      args.filter_map { |arg| attr_name_from(arg) }.map do |name|
        (node.name == :attr_writer) ? "#{name}=" : name
      end
    end

    def attr_name_from(arg)
      case arg
      when Prism::SymbolNode, Prism::StringNode
        arg.unescaped
      end
    end

    # A collaborator is the immediate receiver of a non-operator message.
    def extract_collaborator(call_node)
      case (receiver = call_node.receiver)
      when Prism::LocalVariableReadNode
        receiver.name.to_s
      when Prism::InstanceVariableReadNode
        receiver.name.to_s.delete_prefix("@")
      when Prism::CallNode
        receiver.name.to_s
      when Prism::ConstantReadNode, Prism::ConstantPathNode
        constant_name(receiver)
      end
    end

    def qualified_name(node, namespace)
      path = constant_name(node.constant_path)
      return path if node.constant_path.is_a?(Prism::ConstantPathNode)

      [*namespace, path].join("::")
    end

    def constant_name(node)
      node.slice.delete_prefix("::")
    end
  end
end
