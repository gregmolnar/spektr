module Spektr
  module Exp
    class Lvasign < Base
      attr_accessor :ast, :name, :arguments, :body, :location, :private, :protected

      def initialize(ast)
        @ast = ast
        @name = ast.children.first
        @location = ast.location
        @arguments = []
      end
    end
  end
end
