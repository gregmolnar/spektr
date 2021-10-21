module Spektr
  module Exp
    class Xstr < Base
      def initialize(ast)
        super
        ast.children[1..].each do |child|
          @arguments << Argument.new(child)
        end
      end
    end
  end
end
