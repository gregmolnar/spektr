module Spektr
  module Exp
    class Definition < Base
      attr_accessor :private, :protected

      def initialize(ast)
        super
        process @ast.children
      end

      def process(ast)
        ast&.each do |node|
          next unless Parser::AST::Node === node
          case node.type
          when :args
            node.children.each do |argument|
              @arguments << argument.children.first
            end
          when :begin
            process(node.children)
          when :lvasgn
            @body << Lvasign.new(node)
          when :ivasgn
            @body << Ivasign.new(node)
          when :send
            @body << Send.new(node)
          end
        end
      end
    end
  end
end
