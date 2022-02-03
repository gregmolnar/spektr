module Spektr
  module Exp
    class Base
      attr_accessor :ast, :name, :type, :options, :arguments, :body, :location

      def initialize(ast)
        @ast = ast
        @type = ast.type
        @location = ast.location
        @name = ast.children.first
        @options = {}
        @arguments = []
        @body = []
      end

      def send?
        is_a? Send
      end

      include AST::Processor::Mixin

      def process(ast)
        return unless ast.respond_to?(:to_ast)
        super
      end

      def handler_missing(node)
        # puts "handler missing for #{node.type}"
      end
    end
  end
end
