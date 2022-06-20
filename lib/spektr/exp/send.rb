module Spektr
  module Exp
    class Send < Base
      attr_accessor :receiver

      def initialize(ast)
        super
        @receiver = Receiver.new(ast.children[0]) if ast.children[0]
        @name = if ast.children.first.is_a?(Parser::AST::Node)
                  ast.children.first.children.last
                else
                  ast.children[1]
                end
        children = ast.children[2..]
        children.each do |child|
          next unless child.is_a?(Parser::AST::Node)

          case child.type
          when :hash
            if children.size == 1 || children.last == child
              child.children.each do |pair|
                @options[pair.children[0].children[0]] = Option.new(pair)
              end
            else
              @arguments << Argument.new(child)
            end
          else
            @arguments << Argument.new(child)
          end
        end
      end
    end

    class Argument < Base
      attr_accessor :name, :type, :ast, :children

      def initialize(ast)
        @name = nil
        process_ast(ast)
        ast = ast.children.first if ast.type == :begin
        @ast = ast
        argument = if %i[xstr hash].include? ast.type
                     ast
                   elsif ast.type != :dstr && ast.children.first.is_a?(Parser::AST::Node) && ast.children.first.children.first.is_a?(Parser::AST::Node)
                     ast.children.first.children.first
                   elsif ast.type != :dstr && ast.children.first.is_a?(Parser::AST::Node)
                     ast.children.first
                   else
                     ast
                   end
        @type = argument.type
        @children = argument.children
      end

      def process_ast(ast)
        process(ast)
      end

      def on_begin(node)
        process_all(node)
      end

      def on_send(node)
        if node.children.first.nil?
          @name ||= node.children[1]
        elsif node.is_a?(Parser::AST::Node)
          process_all(node)
        end
      end

      def on_const(node)
        @name ||= node.children[1] if node.children.first.nil?
      end

      def on_str(node)
        @name ||= node.children.first
      end

      alias on_sym on_str
      alias on_ivar on_str
    end

    class Option
      attr_accessor :name, :key, :value, :type, :value_name, :value_type

      def initialize(ast)
        @key = ast.children.first
        @name = ast.children.first.children.last
        @type = ast.type

        @value = ast.children.last
        @value_name = ast.children.last.children.last
        @value_type = ast.children.last.type
      end
    end

    class Receiver
      attr_accessor :name, :type, :ast, :expanded, :children

      def initialize(ast)
        @children = []
        set_attributes(ast)
      end

      def set_attributes(ast)
        if [:begin].include?(ast.type) && ast.children[0].is_a?(Parser::AST::Node)
          return set_attributes(ast.children[0])
        end

        @ast = ast
        if ast.type == :dstr
          @type = :dstr
          @name = ast.children[0].children.first
          ast.children[1..].each do |ch|
            @children << Receiver.new(ch)
          end
        else
          @expanded = expand!(ast)
          @ast = ast.type == :send && ast.children[0].is_a?(Parser::AST::Node) ? ast.children[0] : ast
          @type = @ast.type
          @name = @ast.children.last
        end
      end

      def expand!(ast, tree = [])
        if ast.is_a?(Parser::AST::Node) && ast.children.any?
          tree << ast.children.last
          expand!(ast.children.first, tree)
        else
          tree.reverse.join('.')
        end
      end
    end
  end
end
