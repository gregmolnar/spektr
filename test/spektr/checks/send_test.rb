require "test_helper"

class SendTest < Minitest::Test
  def setup
    @app = Spektr::App.new(checks: [Spektr::Checks::Send])
  end

  def test_it_fails_with_user_controller_value
    code = <<-CODE
      @content.send(params[:field])
    CODE
    controller = Spektr::Targets::Controller.new("blog_controller.rb", code)
    check = Spektr::Checks::Send.new(@app, controller)
    check.run
    assert_equal 1, @app.warnings.size
  end
end
