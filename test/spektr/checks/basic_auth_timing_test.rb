require "test_helper"

class BasicAuthTimingTest < Minitest::Test

  def setup
    @code = <<-CODE
      class ApplicationController
        http_basic_authenticate_with name: "dhh", password: "secret", except: :index
      end
    CODE
    @app = Spektr::App.new(checks: [Spektr::Checks::BasicAuthTiming])
    @controller = Spektr::Targets::Controller.new("application_controller.rb", @code)
    @check = Spektr::Checks::BasicAuthTiming.new(@app, @controller)
  end

  def test_it_fails_with_no_rails_version
    @check.run
    assert_equal 1, @app.warnings.size
  end

  def test_it_does_not_fail_with_non_affected_version
    @app.rails_version = Gem::Version.new "6.0.1"
    @check.run
    assert_equal 0, @app.warnings.size
  end
end
