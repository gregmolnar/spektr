module Spektr
  module Exp
    class Send < Base
      attr_accessor :receiver

      def initialize(ast)
        super
        @receiver = ast.children[0]
        @name = ast.children[1]
        ast.children[2..].each do |child|
          case child.type
          when :hash
            child.children.each do |pair|
              @options[pair.children[0].children[0]] = pair.children[1]
            end
          else
            @arguments << Argument.new(child)
          end
        end
      end
    end

    class Argument
      attr_accessor :name, :type
      def initialize(ast)
        @name = ast.children.last
        @type = ast.type
      end
    end
  end
end
