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
          Action.new(ast, self)
        end
      end

      class Action < Spektr::Exp::Definition
        attr_accessor :controller, :template
        def initialize(ast, controller)
          super(ast)
          @template = File.join(controller.name.delete_suffix("Controller").underscore, name.to_s)
          @body.each do |exp|
            if exp.call?
              if exp.name == :render
                if exp.arguments.first[1] == :sym
                  @template = File.join(controller.name.delete_suffix("Controller").underscore, exp.arguments.first[0].to_s)
                elsif
                  if exp.arguments.first[1] == :str
                    @template = exp.arguments.first[0]
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
