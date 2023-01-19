module Spektr
  module Targets
    class Base
      attr_accessor :path, :name, :options, :ast, :parent, :processor

      def initialize(path, content)
        Spektr.logger.debug "loading #{path}"
        @ast = Spektr::App.parser.parse(content)
        @path = path
        return unless @ast

        @processor = Spektr::Processors::Base.new
        @processor.process(@ast)
        @name = @processor.name
        @name = @path.split('/').last if @name.blank?

        @current_method_type = :public
        @parent = @processor.parent_name
      end

      def find_calls(name, receiver = nil)
        calls = find(:send, name, @ast).map { |ast| Exp::Send.new(ast) }
        if receiver
          calls.select! { |call| call.receiver&.expanded == receiver }
        elsif receiver == false
          calls.select! { |call| call.receiver.nil? }
        end
        calls
      end

      def find_calls_with_block(name, _receiver = nil)
        blocks = find(:block, nil, @ast)
        blocks.each_with_object([]) do |block, memo|
          if block.children.first.children[1] == name
            result = find(:send, name, block).map { |ast| Exp::Send.new(ast) }
            memo << result.first
          end
        end
      end

      def find_method(name)
        find(:def, name, @ast).last
      end

      def find_xstr
        find(:xstr, nil, @ast).map { |ast| Exp::Xstr.new(ast) }
      end

      def find(type, name, ast, result = [])
        return result unless ast.is_a? Parser::AST::Node

        name_index = case type
                     when :def
                       0
                     else
                       1
                     end
        if node_matches?(ast.type, ast.children[name_index], type, name)
          result << ast
        elsif ast.children.any?
          ast.children.each do |child|
            result = find(type, name, child, result)
          end
        end
        result
      end

      def node_matches?(node_type, node_name, type, name)
        if node_type == type
          if name.is_a? Regexp
            return node_name =~ name
          elsif name.nil?
            return true
          else
            return node_name == name
          end
        end
        false
      end

      def find_methods(ast:, result: [], type: :all)
        return result unless ast.is_a?(Parser::AST::Node)

        if ast.type == :send && %i[private public protected].include?(ast.children.last)
          @current_method_type = ast.children.last
        end
        if ast.type == :def && [:all, @current_method_type].include?(type)
          result << ast
        elsif ast.children.any?
          ast.children.map do |child|
            result = find_methods(ast: child, result: result, type: type)
          end
        end
        result
      end

      def ast_to_exp(ast)
        case ast.type
        when :send
          Exp::Send.new(ast)
        when :def
          Exp::Definition.new(ast)
        when :ivasgn, :ivar
          Exp::Ivasgin.new(ast)
        when :lvasign, :lvar
          Exp::Lvasign.new(ast)
        when :const
          Exp::Const.new(ast)
        when :xstr
          Exp::Xstr.new(ast)
        when :sym, :int, :str
          Exp::Base.new(ast)
        else
          raise "Unknown type #{ast.type} #{ast.inspect}"
        end
      end
    end
  end
end
