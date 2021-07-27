require "spektr/version"
require "ruby_parser"
require "parser"
require 'parser/current'
require 'unparser'

# require "spektr/processors/base_processor"

# require "spektr/controller"

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.collapse("#{__dir__}/processors")
loader.setup # ready!
loader.eager_load

module Spektr
  class Error < StandardError; end

  def run
    @app = App.new
    @app.load
    @checks = Checks.load
  end
end
