module Spektr
  module Exp
    class Call < Base
      def initialize(ast)
        super
        @name = ast.children[1]
        ast.children[2..].each do |child|
          case child.type
          when :hash
            child.children.each do |pair|
              @options[pair.children[0].children[0]] = pair.children[1]
            end
          else
            @arguments[child.children.last] = child.type
          end
        end
      end
    end
  end
end
