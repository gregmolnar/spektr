require "spektr/version"
require "bundler"
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

  def self.run(root = nil, output_format = "terminal")
    checks = Checks.load
    root = "./" if root.nil?
    @app = App.new(checks: checks, root: root)
    @app.load
    @app.scan!
    @app.report(output_format)
  end
end
