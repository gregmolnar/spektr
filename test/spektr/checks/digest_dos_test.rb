require "test_helper"

class DigestDosTest < Minitest::Test
  def setup
    @code = <<-CODE
      class ApplicationController
        authenticate_or_request_with_http_digest
      end
    CODE
    @app = Spektr::App.new(checks: [Spektr::Checks::DigestDos])
    @app.rails_version = Gem::Version.new "3.0.1"
    @controller = Spektr::Targets::Controller.new("application_controller.rb", @code)
    @check = Spektr::Checks::DigestDos.new(@app, @controller)
  end

  def test_it_fails_with_affected_version
    @check.run
    assert_equal 1, @app.warnings.size
  end
end
