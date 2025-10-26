module Spektr
  module Targets
    class Controller < Base

      def initialize(path, content)
        super
      end

      def concern?
        !name.match('Controller')
      end

      def actions
        @actions ||= public_methods.map do |node|
          Action.new(node, self)
        end
      end

      def find_action(action)
        @actions.find{|a| a.name == action }
      end

      def find_parent(controllers)
        result = find_in_set(@parent, controllers)
        # result ||= find_in_set(processor.parent_name_with_modules, controllers)
        return nil if result&.name == name

        result
      end

      def find_in_set(name, set)
        while true
          result = set.find { |c| c.name == name }
          break if result

          split = name.split('::')
          split.shift
          name = split.join('::')
          break if name.blank?
        end
        result
      end

      class Action
        attr_accessor :node, :name, :controller, :template

        def initialize(node, controller)
          @node = node
          @name = node.name
          @template = nil
          @controller = controller
          split = []
          if controller.parent && controller.parent != 'ApplicationController'
            split = controller.parent.split('::').map { |e| e.delete_suffix('Controller') }.map(&:downcase)
            if split.size > 1
              split.pop
              @template = "#{split.join('/')}/#{@template}"
            end
          end

          split = split.concat(controller.name.split('::').map do |n|
            n.delete_suffix('Controller')
          end.map(&:downcase)).uniq
          split.delete('application')
          @template = File.join(*split, name.to_s)
          # TODO: set template from render
          # @body.each do |exp|
          #   if exp.send? && exp.name == :render && exp.arguments.any?
          #     if exp.arguments.first.type == :sym
          #       @template = File.join(controller.name.delete_suffix('Controller').underscore,
          #                             exp.arguments.first.name.to_s)
          #     elsif exp.arguments.first.type == :str
          #       @template = exp.arguments.first.name
          #     end
          #   end
          # end
        end

        def body
          @node.body.respond_to?(:body) ? @node.body.body : @node.body
        end
      end
    end
  end
end
