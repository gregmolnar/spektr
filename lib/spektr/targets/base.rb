module Spektr
  module Targets
    class Base
      attr_accessor :path, :name, :options, :ast

      def initialize(path, content)
        @ast = Parser::CurrentRuby.parse(content)
        @path = path
        return unless @ast
        @name = @ast.children.first.children.last.to_s
        @current_method_type = :public
      end

      def find_calls(name)
        find(:send, name, @ast).map{ |ast| Exp::Send.new(ast) }
      end

      def find(type, name, ast, result = [])
        return result unless Parser::AST::Node === ast
        if ast.type == type && ast.children[1] == name
            result << ast
        elsif ast.children.any?
          ast.children.each do |child|
            result = find(type, name, child, result)
          end
        end
        result
      end


      def find_methods(ast:, result: [], type: :all)
        return result unless Parser::AST::Node === ast
        if ast.type == :send && [:private, :public, :protected].include?(ast.children.last)
          @current_method_type = ast.children.last
        end
        if ast.type == :def && (type == :all || type == @current_method_type)
            result << ast
        elsif ast.children.any?
          ast.children.map do |child|
            result = find_methods(ast: child, result: result, type: type)
          end
        end
        result
      end
    end
  end
end
