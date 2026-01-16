module Spektr
  module Targets
    class Base < Prism::Visitor
      attr_accessor :path, :name, :options, :ast, :parent, :parent_modules, :methods, :calls, :interpolated_xstrings, :lvars

      def initialize(path, content)
        Spektr.logger.debug "loading #{path}"
        @ast = Prism.parse(content)
        @path = path
        return unless @ast
        @parent = ""
        @parent_modules = []
        @methods = []
        @lvars = []
        @ivars = []
        @calls = []
        @interpolated_xstrings = []
        @ast.value.accept(self)
        @name = @path.split('/').last if @name&.blank?
        @name = @name.prepend("#{@parent_modules.map(&:name).join('::')}::") if @name && @parent_modules.any?
      end

      def method_definitions
        @method_definitions ||= find_methods(node: @ast)
      end

      def public_methods
        @public_methods ||= find_methods(node: @ast, visibility: :public)
      end

      def find_calls(name, receiver = nil)
        if name.is_a? Regexp
          operator = :=~
        else
          operator = :==
        end
        @calls.select do |node|
          if receiver.nil?
            node.name.send(operator, name)
          elsif receiver == false
            node.name.send(operator, name) && node.receiver.nil?
          else
            node_receiver = node.receiver.name if node.receiver.respond_to?(:name)
            if node.receiver.respond_to?(:parent) && node.receiver.parent
              node_receiver = node_receiver.to_s.prepend("#{node.receiver.parent.name}::").to_sym
            end
            node.name.send(operator, name) && node.receiver && receiver == node_receiver
          end
        end
      end

      def find_calls_with_block(name, _receiver = nil)
        find_calls(name).select do |call|
          call.block
        end
      end

      def find_method(name)
        @methods.find{|method| method.name == name }
      end

      def find_methods(node:, visibility: :all)
        Spektr::Extractors::Methods.new(visibility:).call(node).result
      end


      def visit_call_node(node)
        @calls << node
        super
      end

      def visit_class_node(node)
        @name = node.name.to_s
        case node.superclass
        when Prism::CallNode
          @parent = node.superclass.receiver.name.to_s
        when Prism::ConstantPathNode, Prism::ConstantReadNode
          @parent = node.superclass.name.to_s
          @parent.prepend("#{node.superclass.parent.name}::") if node.superclass.respond_to?(:parent)
          if node.superclass.respond_to?(:parent) && node.superclass.parent.respond_to?(:parent)
            @parent.prepend("#{node.superclass.parent.parent.name}::")
          end
        end
        if node.is_a?(Prism::ClassNode) && node.constant_path && node.constant_path.respond_to?(:parent)
          @parent = node.constant_path.parent.name.to_s
        end
        @parent = @parent.prepend("#{@parent_modules.map(&:name).join('::')}::") if @parent_modules.any?
        super
      end

      def visit_module_node(node)
        @parent_modules << node.constant_path.parent.name if node.constant_path && node.constant_path.respond_to?(:parent)
        @parent_modules << node
        super
      end

      def visit_def_node(node)
        @methods << node
        super
      end

      def visit_interpolated_x_string_node(node)
        @interpolated_xstrings << node
        super
      end

      def visit_local_variable_write_node(node)
        @lvars << node
        super
      end

      def visit_instance_variable_write_node(node)
        @ivars << node
        super
      end
    end
  end
end
