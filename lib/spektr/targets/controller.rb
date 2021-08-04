module Spektr
  module Targets
    class Controller < Base
      attr_accessor :actions

      def initialize(path, content)
        super
        find_actions
      end

      def find_actions
        @actions = find_methods(ast: @ast, type: :public ).map do |ast|
          Exp::Definition.new(ast)
        end
      end
    end
  end
end
