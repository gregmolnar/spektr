require 'ast'
module Spektr::Processors
  class Base
    include AST::Processor::Mixin

    def on_class(node)
      puts "on class: #{node.inspect}"
      ClassProcessor.new.process(node)
    end

    def handler_missing(node)
      puts "missing #{node.type}"
    end
  end
end
