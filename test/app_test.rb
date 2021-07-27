require "test_helper"

class AppTest < Minitest::Test

  def test_it_loads_controllers
    app = RailsScan::App.new(RailsScan::Checks.load)
    app.root = "./test/apps/rails6.1"
    app.load
    assert_equal 1, app.controllers.size
  end
end
