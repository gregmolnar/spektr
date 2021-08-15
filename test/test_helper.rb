$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "spektr"

require "byebug"
require "minitest/pride"
require "minitest/autorun"

RAILS_6_1_ROOT = File.join(__dir__, "apps", "rails6.1")
