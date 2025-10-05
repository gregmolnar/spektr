module Spektr
  module Extractors
    class Calls < Prism::Visitor
      attr_accessor :result

      def initialize(name:)
        @name = name
        @result = []
      end

      def call(ast)
        ast.value.accept(self)
        self
      end

      def visit_call_node(node)
        @result << node if node.name == @name
        super
      end
    end
  end
end
