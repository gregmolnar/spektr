module Spektr
  module Exp
    class Definition < Base
      attr_accessor :ast, :name, :arguments, :body, :location, :private, :protected

      def initialize(ast)
        super
        @name = ast.children.first
        @arguments = []
        @body = []
        process @ast.children
      end

      def process(ast)
        ast&.each do |ast|
          next unless Parser::AST::Node === ast
          case ast.type
          when :args
            ast.children.each do |argument|
              @arguments << argument.children.first
            end
          when :begin
            process(ast.children)
          when :lvasgn
            @body << Lvasign.new(ast)
          when :send
            @body << Call.new(ast)
          end
        end
      end
    end
  end
end
