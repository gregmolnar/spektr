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
          (w.location.nil? || w.location&.line == location&.line) &&
          w.message == message
      end
    end

    def version_affected; end

    def user_input?(type, name, ast = nil, object = nil)
      case type
      when :ivar, :lvar
        # TODO: handle helpers here too
        return false unless @target.instance_of?(Spektr::Targets::View)

        actions = []
        @app.controllers.each do |controller|
          actions = actions.concat controller.actions.select { |action|
            action.template == @target.view_path
          }
        end
        actions.each do |action|
          action.body.each do |exp|
            return exp.user_input? if exp.is_a?(Exp::Ivasign) && exp.name == name
          end
        end
        false
      when :send
        if ast.children.first&.type == :send
          child = ast.children.first
          return user_input?(child.type, child.children.last, child)
        end
        return true if %i[params cookies request].include? name
      when :xstr, :begin
        ast.children.each do |child|
          next unless child.is_a?(Parser::AST::Node)
          return true if user_input?(child.type, child.children.last, child)
        end
      when :dstr
        object&.children&.each do |child|
          if child.is_a?(Parser::AST::Node)
            name = nil
            ast = child
          else
            name = child.name
            ast = child.ast
          end
          return true if user_input?(child.type, name, ast)
        end
      when :lvasgn
        ast.children.each do |child|
          next unless child.is_a?(Parser::AST::Node)
          return true if user_input?(child.type, child.children.last, child)
        end
      when :block, :pair, :hash, :array, :if, :or
        ast.children.each do |child|
          next unless child.is_a?(Parser::AST::Node)
          return true if user_input?(child.type, child.children.last, child)
        end
      when :sym, :str, :const, :int, :cbase, :true, :self, :args, :nil, :yield
        # do nothing
      else
        raise "Unknown argument type #{type} #{name} #{ast.inspect}"
      end
    end

    # TODO: this doesn't work properly
    def model_attribute?(item)
      model_names = @app.models.collect(&:name)
      case item.type
      when :ivar, :lvar
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
              return exp.user_input? if exp.is_a?(Exp::Ivasign) && exp.name == item.name
            end
          end
        end
      when :send
        ast = item.is_a?(Parser::AST::Node) ? item : item.ast
        _send = Exp::Send.new(ast)
        return true if _send.receiver && model_names.include?(_send.receiver.name)
      when :const
        return true if model_names.include? item.name
      when :block, :pair, :hash, :array, :if, :or
        item.children.each do |child|
          next unless child.is_a?(Parser::AST::Node)
          return true if model_attribute?(child)
        end
      when :dstr
        # TODO: implement this
      when :sym, :str, :nil, :yield
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
