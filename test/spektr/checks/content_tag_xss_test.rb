require "test_helper"

class ContentTagXssTest < Minitest::Test

  def setup
    @app = Spektr::App.new(root: RAILS_6_1_ROOT, checks: [Spektr::Checks::ContentTagXss])
  end

  def test_it_fails_with_rails_2
    @app.load
    @app.rails_version = Gem::Version.new "2.3.1"
    @app.scan!
    assert_equal 4, @app.warnings.size
  end

  def test_it_fails_for_cve_2016_6316
    @app.load
    @app.rails_version = Gem::Version.new "3.0.0"
    @app.scan!
    assert_equal 2, @app.warnings.size
  end

  def test_it_fails_for_unsafe_hash_attribute
    @app.load
    @app.scan!
    assert_equal 1, @app.warnings.size
  end
end
