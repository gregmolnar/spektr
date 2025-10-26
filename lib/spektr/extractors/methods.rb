module Spektr
  module Extractors
    class Methods < Prism::Visitor
      attr_accessor :result

      def initialize(visibility: :all)
        @visibility = visibility
        @current_visibility = :public
        @result = []
      end

      def call(ast)
        ast.value.accept(self)
        self
      end

      def visit_call_node(node)
        @current_visibility = node.name if %i[private protected public].include?(node.name)
        super
      end

      def visit_def_node(node)
        @result << node if @visibility == :all || @current_visibility == @visibility
        super
      end
    end
  end
end
