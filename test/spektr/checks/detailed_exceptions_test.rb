require "test_helper"

class DetailedExceptionsTest < Minitest::Test

  def test_it_fails_with_insecure_config
    code = <<-CODE
     Rails.application.configure do
      config.consider_all_requests_local = true
     end
    CODE
    app = Spektr::App.new(checks: [Spektr::Checks::DetailedExceptions])
    config = Spektr::Targets::Controller.new("production.rb", code)
    check = Spektr::Checks::DetailedExceptions.new(app, config)
    check.run
    assert_equal 1, app.warnings.size
  end

  def test_it_fails_with_insecure_controller
    code = <<-CODE
      class ApplicationController
        def show_detailed_exceptions?
          admin?
        end
      end
    CODE
    app = Spektr::App.new(checks: [Spektr::Checks::DetailedExceptions])
    config = Spektr::Targets::Controller.new("production.rb", code)
    check = Spektr::Checks::DetailedExceptions.new(app, config)
    check.run
    assert_equal 1, app.warnings.size
  end
end
