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
      @app.warnings << Warning.new(target, check, location, message)
    end

    def version_affected
    end
  end
end
