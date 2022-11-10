module Spektr
  module Processors
    class ClassProcessor < Base
      include AST::Processor::Mixin

      attr_accessor :data

      def on_begin(node)
      end

      def on_def(node)
        puts "on def: #{node.inspect}"
      end

      def on_require(node)
        puts "on require: #{node.inspect}"
      end

      def on_class(node)
        puts "on class2: #{node.inspect}"
      end
    end
  end
end
