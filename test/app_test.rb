require "test_helper"

class AppTest < Minitest::Test

  def test_it_loads_controllers
    app = Spektr::App.new(checks: Spektr::Checks.load, root: "./test/apps/rails6.1")
    app.load
    assert_equal 1, app.controllers.size
    assert_equal 1, app.models.size
    assert_equal 7, app.lib_files.size
  end
end
