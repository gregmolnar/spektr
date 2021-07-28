module Spektr
  class Checks::Base

    def initialize(app, target)
      @app = app
      @target = target
    end

    def run
    end

    def warn!(target, check, location, message)
      @app.warnings << Warning.new(target, check, location, message)
    end
  end
end
