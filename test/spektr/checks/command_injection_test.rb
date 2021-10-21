require "test_helper"

class CommandInjectionTest < Minitest::Test
  def setup
    @code = <<-CODE
      class ApplicationController
        def index
          `ls \#{params[:directory]}`
          Kernel.open(params[:directory])
        end
      end
    CODE
    @app = Spektr::App.new(checks: [Spektr::Checks::CommandInjection])
    @controller = Spektr::Targets::Controller.new("application_controller.rb", @code)
    @check = Spektr::Checks::CommandInjection.new(@app, @controller)
  end

  def test_it_fails_with_user_supplied_value
    @check.run
    assert_equal 2, @app.warnings.size
  end
end
