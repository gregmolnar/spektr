require "test_helper"

class EvaluationTest < Minitest::Test
  def setup
    @code = <<-CODE
      class ApplicationController
        def index
          eval("whoami")
          eval(`ls \#{params[:directory]}`)
          instance_eval params[:code]
        end
      end
    CODE
    @app = Spektr::App.new(checks: [Spektr::Checks::Evaluation])
    @app.rails_version = Gem::Version.new "5.0.1"
    @controller = Spektr::Targets::Controller.new("application_controller.rb", @code)
    @check = Spektr::Checks::Evaluation.new(@app, @controller)
  end

  def test_it_fails_with_user_supplied_value
    @check.run
    assert_equal 2, @app.warnings.size
  end
end
