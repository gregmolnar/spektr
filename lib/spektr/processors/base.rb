require 'ast'
module Spektr::Processors
  class Base
    include AST::Processor::Mixin
    attr_accessor :name, :name_parts, :parent_parts, :parent_name

    def initialize
      @modules = []
      @name_parts = []
      @parent_parts = []
    end

    def name
      @name_parts.join("::")
    end

    def parent_name
      @modules.concat(@parent_parts).join("::")
    end

    def on_begin(node)
      process_all(node)
    end

    def on_module(node)
      parts = extract_name_part(node)
      @modules.concat(parts)
      @name_parts.concat(parts)
      process_all(node)
    end

    def on_class(node)
      if node.children[1] && node.children[1].is_a?(Parser::AST::Node)
        node.children[1].children.each do |child|
          if child.is_a?(Parser::AST::Node)
            @parent_parts << child.children.last
          elsif child.is_a? Symbol
            @parent_parts << child.to_s
          end
        end
      end
      @name_parts.concat(extract_name_part(node))
      process_all(node)
    end

    def extract_name_part(node)
      parts = []
      node.children.first.children.each do |child|
        if child.is_a?(Parser::AST::Node)
          parts << child.children.last
        elsif child.is_a? Symbol
          parts << child.to_s
        end
      end
      parts
    end

    def on_const(node)
    end

    def handler_missing(node)
      # puts "handler missing for #{node.type}"
    end
  end
end
