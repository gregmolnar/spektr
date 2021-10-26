require "test_helper"

class FileAccessTest < Minitest::Test
  def setup
    @code = <<-CODE
      class ApplicationController
        def index
          File.open(params[:directory])
        end
      end
    CODE
    @app = Spektr::App.new(checks: [Spektr::Checks::FileAccess])
    @controller = Spektr::Targets::Controller.new("application_controller.rb", @code)
    @check = Spektr::Checks::FileAccess.new(@app, @controller)
  end

  def test_it_fails_with_user_supplied_value
    @check.run
    assert_equal 1, @app.warnings.size
  end
end
