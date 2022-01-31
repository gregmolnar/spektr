module Spektr
  module Targets
    class Controller < Base
      attr_accessor :actions

      def initialize(path, content)
        super
        find_actions
      end

      def concern?
        !name.match("Controller")
      end

      def find_actions
        @actions = find_methods(ast: @ast, type: :public ).map do |ast|
          Action.new(ast, self)
        end
      end

      def find_parent(controllers)
        parent_name = parent
        while true
          result = controllers.find{|c| c.name == parent_name }
          break if result
          split = parent_name.split("::")
          split.shift
          parent_name = split.join("::")
          break if parent_name.blank?
        end
        return nil if result&.name == name
        result
      end

      class Action < Spektr::Exp::Definition
        attr_accessor :controller, :template
        def initialize(ast, controller)
          super(ast)
          split = []
          if controller.parent
            split = controller.parent.split("::").map{|e| e.delete_suffix("Controller")}.map(&:downcase)
            if split.size > 1
              split.pop
              @template = "#{split.join("/")}/#{@template}"
            end
          end
          split = split.concat(controller.name.delete_suffix("Controller").split("::").map(&:downcase)).uniq
          split.delete("application")
          @template = File.join(*split, name.to_s)
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
