module RailsScan
  class Controller
    attr_accessor :name, :options, :ast

    def initialize(content)
      @ast = Parser::CurrentRuby.parse(content)
      @name = @ast.children.first.children.last.to_s
    end

    def find_calls(name)
      find(:send, name, @ast, [])
    end

    def find(type, name, ast, result)
      return result unless Parser::AST::Node === ast
      if ast.type == type && ast.children[1] == name
        result << Call.new(ast)
      elsif ast.children.any?
        ast.children.map do |child|
          result = find(type, name, child, result)
        end
      end
      result
    end
  end
end
