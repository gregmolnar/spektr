module Spektr
  module Exp
    class Definition < Base
      attr_accessor :ast, :name, :arguments, :body, :location, :private, :protected

      def initialize(ast)
        super
        @name = ast.children.first
        @arguments = []
        @body = []
        @ast.children[1].children.each do |argument|
          @arguments << argument.children.first
        end
        @ast.children[2]&.children&.each do |ast|
          case ast.type
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
