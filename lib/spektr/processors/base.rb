require 'ast'
module Spektr::Processors
  class Base
    include AST::Processor::Mixin
    attr_accessor :name, :name_parts, :parent_parts, :parent_modules, :parent_name, :parent_name_with_modules

    def initialize
      @modules = []
      @name_parts = []
      @parent_parts = []
      @parent_modules = []
    end

    def name
      @name_parts.join('::')
    end

    def parent_name
      parent_parts.join('::')
    end

    def parent_parts
      result = @parent_parts.dup
      result.pop if part_matches_self?(result.last.to_s)
      result
    end

    def part_matches_self?(part)
      (part == name || part_with_module(part) == name)
    end

    def part_with_module(part)
      (@parent_modules | [part]).join('::')
    end

    def parent_name_with_modules
      parts = @parent_modules | parent_parts
      parts.join('::')
    end

    def on_begin(node)
      process_all(node)
    end

    def on_module(node)
      parts = extract_name_part(node)
      @modules.concat(parts)
      @name_parts.concat(parts)
      @parent_modules << node.children.first.children.last
      process_all(node)
    end

    def extract_parent_parts(node)
      return unless node.is_a?(Parser::AST::Node) && %i[ module class const send].include?(node.type)
      @parent_parts.prepend(node.children.last) if node.type == :const
      if node.children.any?
        node.children.each do |child|
          extract_parent_parts(child)
        end
      end
    end

    def on_class(node)
      extract_parent_parts(node)
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

    def on_const(node); end

    def handler_missing(node)
      # puts "handler missing for #{node.type}"
    end
  end
end
