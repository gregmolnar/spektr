module Spektr
  module Exp
    class Send < Base
      attr_accessor :receiver

      def initialize(ast)
        super
        @receiver = Receiver.new(ast.children[0]) if ast.children[0]
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
    end

    class Argument
      attr_accessor :name, :type, :ast
      def initialize(ast)
        if ast.type == :begin
          ast = ast.children.first
        end
        @ast = ast
        argument = if ast.type == :xstr
          ast
        elsif ast.children.first.is_a?(Parser::AST::Node) && ast.children.first.children.first.is_a?(Parser::AST::Node)
          ast.children.first.children.first
        elsif ast.children.first.is_a?(Parser::AST::Node)
          ast.children.first
        else
          ast
        end
        @type = argument.type
        @name = argument.children.last
      end
    end

    class Option
      attr_accessor :name, :key, :value, :type, :value_type
      def initialize(ast)
        @name = ast.children.first.children.last
        @key = ast.children.first
        @value = ast.children.last.children.last
        @value_type = ast.children.last.type
        @type = ast.children.last.type
      end
    end

    class Receiver
      attr_accessor :name, :type, :ast, :expanded
      def initialize(ast)
        @expanded = expand!(ast)
        (ast.type == :send && ast.children[0].is_a?(Parser::AST::Node)) ? @ast = ast.children[0] : @ast = ast
        @type = @ast.type
        @name = @ast.children.last
      end

      def expand!(ast, tree = [])
        if ast.is_a?(Parser::AST::Node) && ast.children.any?
          tree << ast.children.last
          expand!(ast.children.first, tree)
        else
          tree.reverse.join(".")
        end
      end
    end
  end
end
