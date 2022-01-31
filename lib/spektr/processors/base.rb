require 'ast'
module Spektr::Processors
  class Base
    include AST::Processor::Mixin
    attr_accessor :name, :name_parts, :parent_name

    def initialize
      @name_parts = []
    end

    def name
      @name_parts.join("::")
    end

    def on_begin(node)
      process_all(node)
    end

    def on_module(node)
      extract_name_part(node)
      process_all(node)
    end

    def on_class(node)
      extract_name_part(node)
      process_all(node)
    end

    def extract_name_part(node)
      node.children.first.children.each do |child|
        if child.is_a?(Parser::AST::Node)
          @name_parts << child.children.last
        elsif child.is_a? Symbol
          @name_parts << child.to_s
        end
      end
      if node.children[1] && node.children[1].is_a?(Parser::AST::Node)
        parent_parts = []
        node.children[1].children.each do |child|
          if child.is_a?(Parser::AST::Node)
            parent_parts << child.children.last
          elsif child.is_a? Symbol
            parent_parts << child.to_s
          end
        end
        @parent_name = parent_parts.join("::")
      end
    end

    def on_const(node)
    end

    def handler_missing(node)
      # puts "handler missing for #{node.type}"
    end
  end
end
