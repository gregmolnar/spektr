module Spektr
  module Exp
    class Base
      attr_accessor :ast, :name, :options, :arguments, :body, :location

      def initialize(ast)
        @ast = ast
        @location = ast.location
        @name = ast.children.first
        @options = {}
        @arguments = []
        @body = []
      end

      def send?
        is_a? Send
      end
    end
  end
end
