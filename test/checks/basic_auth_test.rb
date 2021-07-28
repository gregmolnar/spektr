require "test_helper"

class BasicAuthTest < Minitest::Test

  def setup
  end

  def test_it_fails_with_plaintext_password
    code = <<-CODE
      class ApplicationController
        http_basic_authenticate_with name: "dhh", password: "secret", except: :index
      end
    CODE
    app = Spektr::App.new(checks: [Spektr::Checks::BasicAuth])
    controller = Spektr::Targets::Controller.new("application_controller.rb", code)
    check = Spektr::Checks::BasicAuth.new(app, controller)
    check.run
    assert_equal 1, app.warnings.size
  end
end
