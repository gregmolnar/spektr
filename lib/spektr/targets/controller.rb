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
          if controller.parent
            split = controller.parent.split("::").map(&:downcase)
            if split.size > 1
              split.pop
              @template = "#{split.join("/")}/#{@template}"
            end
          end
          @body.each do |exp|
            if exp.send?
              if exp.name == :render && exp.arguments.any?
                if exp.arguments.first.type == :sym
                  @template = File.join(controller.name.delete_suffix("Controller").underscore, exp.arguments.first.name.to_s)
                elsif exp.arguments.first.type == :str
                  @template = exp.arguments.first.name
                end
              end
            end
          end
        end
      end
    end
  end
end
