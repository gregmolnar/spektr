require "spektr/version"
require "bundler"
require "ruby_parser"
require "parser"
require "parser/current"
require "unparser"
require "erb"
require "active_support/core_ext/string/inflections"

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.collapse("#{__dir__}/processors")
loader.setup # ready!
loader.eager_load

module Spektr
  class Error < StandardError; end

  def self.run
    checks = Checks.load
    root = ARGV[0].nil? ? "./" : ARGV[0]
    @app = App.new(checks: checks, root: root)
    @app.load
  end
end
