require "test_helper"

class XssTest < Minitest::Test
  def setup
    @app = Spektr::App.new(root: RAILS_6_1_ROOT, checks: [Spektr::Checks::Xss])
  end

  def test_it_fails_with_unescaped_user_input
    @app.load
    @app.rails_version = Gem::Version.new "2.3.1"
    @app.scan!
    assert_equal 10, @app.warnings.size
  end
end
