module Spektr
  module Exp
    class Send < Base
      attr_accessor :receiver

      def initialize(ast)
        super
        @receiver = ast.children[0]
        if @receiver && @receiver.type == :send
          @receiver = expand_receiver(@receiver)
        end
        @name = ast.children[1]
        ast.children[2..].each do |child|
          case child.type
          when :hash
            child.children.each do |pair|
              @options[pair.children[0].children[0]] = Option.new(pair)
            end
          else
            @arguments << Argument.new(child)
          end
        end
      end

      def expand_receiver(ast, tree = [])
        if ast && ast.children.any?
          tree << ast.children.last
          expand_receiver(ast.children.first, tree)
        else
          tree.reverse.join(".")
        end
      end
    end

    class Argument
      attr_accessor :name, :type, :ast
      def initialize(ast)
        @ast = ast
        argument = if ast.children.first.is_a?(Parser::AST::Node) && ast.children.first.children.first
          ast.children.first.children.first
        elsif ast.children.first.is_a?(Parser::AST::Node)
          ast.children.first
        else
          ast
        end
        @name = argument.children.last
        @type = argument.type
      end
    end

    class Option
      attr_accessor :name, :key, :value, :type
      def initialize(ast)
        @name = ast.children.first.children.last
        @key = ast.children.first
        @value = ast.children.last
        @type = ast.children.last.type
      end
    end
  end
end
