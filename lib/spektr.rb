require "spektr/version"
require "bundler"
require "parser"
require "parser/current"
require "unparser"
require "erb"
require "haml"
require "active_support/core_ext/string/inflections"
require "logger"

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.collapse("#{__dir__}/processors")
loader.setup # ready!
loader.eager_load



module Spektr
  class Error < StandardError; end

  def self.run(root = nil, output_format = "terminal", debug = false, checks = [])
    @log_level = debug ? Logger::DEBUG : Logger::WARN
    checks = Checks.load(checks)
    root = "./" if root.nil?
    @app = App.new(checks: checks, root: root)
    @app.load
    @app.scan!
    @app.report(output_format)
  end

  def self.logger
    @logger ||= begin
      logger = Logger.new(STDOUT)
      logger.level = @log_level || Logger::WARN
      logger
    end
  end
end
