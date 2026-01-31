module Spektr
  class Checks::Base
    attr_accessor :name

    def initialize(app, target)
      @app = app
      @target = target
      @targets = []
    end

    def run
      ::Spektr.logger.debug "Running #{self.class.name} on #{@target.path}"
      target_affected? && should_run?
    end

    def target_affected?
      @targets.include?(@target.class.name)
    end

    def should_run?
      if version_affected && @app.rails_version
        version_affected > @app.rails_version
      else
        true
      end
    end

    def warn!(target, check, location, message, confidence = :high)
      full_path = target.is_a?(String) ? target : target.path
      path = full_path.gsub(@app.root, "")
      return if dupe?(path, location, message)

      @app.warnings << Warning.new(path, full_path, check, location, message, confidence)
    end

    def dupe?(path, location, message)
      @app.warnings.find do |w|
        w.path == path &&
          (w.location.nil? || w.location&.start_line == location&.start_line) &&
          w.message == message
      end
    end

    def version_affected; end

    def user_input?(node)
      return false if node.nil?
      case node.type
      when :call_node
        return true if %i[params cookies request].include? node.name
        return true if node.receiver && user_input?(node.receiver)
        if node.arguments
          node.arguments.arguments.each do |argument|
            return true if user_input?(argument)
          end
        end
      when :embedded_statements_node, :if_node, :else_node
        node.statements.body.each do |item|
          return true if user_input? item
        end
      when :interpolated_string_node, :interpolated_x_string_node, :interpolated_symbol_node
        node.parts.each do |part|
          return true if user_input?(part)
        end
      when :keyword_hash_node, :hash_node
        node.elements.each do |element|
          return true if user_input?(element.key)
          return true if user_input?(element.value)
        end
      when :array_node
        node.elements.each do |element|
          return true if user_input?(element)
        end
      # TODO: make this better. ivars can be overridden in the view as well and
      # can be set in non controller targets too
      when :instance_variable_read_node
        return false unless @target.respond_to?(:view_path)
        actions = []
        @app.controllers.each do |controller|
          actions = actions.concat controller.actions.select { |action|
            action.template == @target.view_path
          }
        end
        actions.each do |action|
          next unless action.body
          action.body.each do |exp|
            return true if exp.name == node.name && user_input?(exp)
          end
        end
      when :local_variable_read_node
        return user_input?(@target.lvars.find{|n| n.name == node.name })
      when :local_variable_or_write_node
        return user_input?(node.value)
      when :and_node, :or_node
        return user_input?(node.left)
        return user_input?(node.right)
      when :instance_variable_write_node, :local_variable_write_node
        return user_input? node.value
      when :splat_node
        return user_input? node.expression
      when :parentheses_node
        node.body.body.each do |item|
          return user_input? item
        end
      when :string_node, :symbol_node, :constant_read_node, :integer_node, :true_node, :constant_path_node, :nil_node, :true_node, :false_node, :self_node
        # do nothing
      else
        raise "Unknown argument type #{node.type.inspect} #{node.inspect}"
      end
      false
    end

    # TODO: this doesn't work properly
    def model_attribute?(node)
      model_names = @app.models.collect(&:name)
      case node.type
      when :local_variable_read_node, :instance_variable_read_node
        # TODO: handle helpers here too
        if ["Spektr::Targets::Controller", "Spektr::Targets::View"].include?(@target.class.name)
          actions = []
          @app.controllers.each do |controller|
            actions = actions.concat controller.actions.select { |action|
              action.template == @target.view_path if @target.respond_to? :view_path
            }
          end
          actions.each do |action|
            action.body.each do |exp|
              next unless node.respond_to?(:name)
              return model_attribute?(exp.value) if exp.is_a?(Prism::InstanceVariableWriteNode) && exp.name == node.name
            end
          end
        end
      when :local_variable_or_write_node
        return model_attribute?(node.value)
      when :and_node, :or_node
        return model_attribute?(node.left)
        return model_attribute?(node.right)
      when :call_node
        return model_attribute?(node.receiver) if node.receiver
        if node.arguments
          node.arguments.arguments.each do |argument|
            return true if model_attribute?(argument)
          end
        end
      when :keyword_hash_node, :hash_node
        node.elements.each do |element|
          return true if model_attribute?(element.key)
          return true if model_attribute?(element.value)
        end
      when :array_node
        node.elements.each do |element|
          return true if model_attribute?(element)
        end
      when :parentheses_node
        node.body.body.each do |item|
          return model_attribute? item
        end
      when :interpolated_string_node, :interpolated_x_string_node, :interpolated_symbol_node
        node.parts.each do |part|
          return true if model_attribute?(part)
        end
      when :embedded_statements_node, :if_node, :else_node
        node.statements.body.each do |item|
          return true if model_attribute? item
        end
      when :instance_variable_write_node, :local_variable_write_node
        return model_attribute? node.value
      when :constant_read_node
        return true if model_names.include? node.name.to_s
      when :interpolated_string_node
        node.parts.each do |item|
          return model_attribute? item
        end
      when :splat_node
        return model_attribute? node.expression
      when :string_node, :symbol_node, :integer_node, :constant_path_node, :nil_node, :true_node, :false_node, :self_node
        # do nothing
      else
        raise "Unknown argument type #{node.type}"
      end
    end

    def app_version_between?(a, b)
      version_between?(a, b, @app.rails_version)
    end

    def version_between?(a, b, version)
      version = Gem::Version.new(version) unless version.is_a? Gem::Version
      version >= Gem::Version.new(a) && version <= Gem::Version.new(b)
    end

    def receivers_for(node)
      receivers = []
      receiver = node.receiver
      while receiver
        receivers <<  receiver.name
        receiver = receiver.respond_to?(:receiver) ? receiver.receiver : false
      end
      receivers
    end

    def full_receiver(node)
      parents = []
      parent = node.receiver.parent if node.receiver.respond_to?(:parent)
      while parent
        parents <<  parent.name
        parent = parent.respond_to?(:parent) ? parent.parent : false
      end
      parents.reverse.concat(receivers_for(node).reverse).join(".")
    end
  end
end
