module Spektr
  class Checks::Base

    def initialize(app, target)
      @app = app
      @target = target
    end

    def run
      return unless should_run?
    end

    def should_run?
      if version_affected && @app.rails_version
        version_affected > @app.rails_version
      else
        true
      end
    end

    def warn!(target, check, location, message)
      path = target.is_a?(String) ? target : target.path
      return if @app.warnings.find{ |w| w.path == path && w.location&.line == location&.line && w.message == message }
      @app.warnings << Warning.new(path, check, location, message)
    end

    def version_affected
    end

    def user_input?(type, name, ast = nil)
      case type
      when :ivar, :lvar
        actions = []
        @app.controllers.each do |controller|
          actions = actions.concat controller.actions.select{ |action|
            action.template == @target.view_path
          }
        end
        actions.each do |action|
          action.body.each do |exp|
            if exp.is_a?(Exp::Ivasign) && exp.name == name
              return exp.user_input?
            end
          end
        end
      when :send
        return true if [:params, :cookies, :request].include? name
      when :xstr, :begin
        ast.children.each do |child|
          return true if user_input?(child.type, child.children.last, child)
        end
      when :sym, :str
        # do nothing
      else
        raise "Unknown argument type #{type}"
      end
    end

    def model_attribute?(item)
      model_names = @app.models.collect(&:name)
      case item.type
      when :ivar, :lvar
        actions = []
        @app.controllers.each do |controller|
          actions = actions.concat controller.actions.select{ |action|
            action.template == @target.view_path
          }
        end
        actions.each do |action|
          action.body.each do |exp|
            if exp.is_a?(Exp::Ivasign) && exp.name == item.name
              return exp.user_input?
            end
          end
        end
      when :send
        _send = Exp::Send.new(item.ast)
        return true if _send.receiver && model_names.include?(_send.receiver.name)
      when :const
        return true if model_names.include? item.name
      when :sym
        # do nothing
      else
        raise "Unknown argument type #{item.type}"
      end
    end

    def app_version_between?(a, b)
      version_between?(a, b, @app.rails_version)
    end

    def version_between?(a, b, version)
      version = Gem::Version.new(version) unless version.is_a? Gem::Version
      version >= Gem::Version.new(a) && version <= Gem::Version.new(b)
    end
  end
end
