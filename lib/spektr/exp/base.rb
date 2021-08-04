module Spektr
  module Exp
    class Base
      attr_accessor :ast, :name, :options, :arguments, :location

      def initialize(ast)
        @ast = ast
        @location = ast.location
        @options = {}
        @arguments = {}
      end
    end
  end
end
