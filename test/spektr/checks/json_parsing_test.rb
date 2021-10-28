require "test_helper"

class JsonParsingTest < Minitest::Test

  def test_fails_with_json_gem_backend
    code = <<-CODE
     ActiveSupport::JSON.backend = JSONGem
    CODE
    app = Spektr::App.new(checks: [Spektr::Checks::JsonParsing])
    config = Spektr::Targets::Base.new("production.rb", code)
    check = Spektr::Checks::JsonParsing.new(app, config)
    check.run
    assert_equal 1, app.warnings.size

  end

  def test_it_fails_with_yajl_gem
    code = ""
    app = Spektr::App.new(checks: [Spektr::Checks::JsonParsing])
    app.gem_specs = [Bundler::LazySpecification.new("yajl", 1, "linux")]
    config = Spektr::Targets::Base.new("production.rb", code)
    check = Spektr::Checks::JsonParsing.new(app, config)
    check.run
    assert_equal 1, app.warnings.size
  end

  def test_it_fails_with_json_and_json_pure
    app = Spektr::App.new(checks: [Spektr::Checks::JsonParsing])
    app.gem_specs = [Bundler::LazySpecification.new("json", "1.7.2", "linux")]
    config = Spektr::Targets::Base.new("production.rb", "")
    check = Spektr::Checks::JsonParsing.new(app, config)
    check.run
    assert_equal 1, app.warnings.size
  end
end
