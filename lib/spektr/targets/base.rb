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

      def find_calls(name, receiver = nil)
        calls = find(:send, name, @ast).map{ |ast| Exp::Send.new(ast) }
        if receiver
          calls.select!{ |call| call.receiver.expanded == receiver }
        end
        calls
      end

      def find_method(name)
        find(:def, name, @ast).last
      end

      def find_xstr
        find(:xstr, nil, @ast).map{ |ast| Exp::Xstr.new(ast) }
      end

      def find(type, name, ast, result = [])
        return result unless ast.is_a? Parser::AST::Node
        case type
        when :def
          name_index = 0
        else
          name_index = 1
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
