require "rails_scan/version"
require "ruby_parser"
require "parser"
require 'parser/current'
require 'unparser'

# require "rails_scan/processors/base_processor"

# require "rails_scan/controller"

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.collapse("#{__dir__}/processors")
loader.setup # ready!
loader.eager_load

module RailsScan
  class Error < StandardError; end

  def run
    @app = App.new
    @app.load
    @checks = Checks.load
  end
end
