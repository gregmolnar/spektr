require "test_helper"

class DynamicFindersTest < Minitest::Test
  def setup
    @code = <<-CODE
      class ApplicationController
        def index
          Post.find_by_title(params[:q])
          Post.find_by_title("test")
        end
      end
    CODE
    @app = Spektr::App.new(checks: [Spektr::Checks::DynamicFinders])
    @app.gem_specs = [Bundler::LazySpecification.new("mysql", 1, "linux")]
    @app.rails_version = Gem::Version.new "5.0.1"
    @controller = Spektr::Targets::Controller.new("application_controller.rb", @code)
    @check = Spektr::Checks::DynamicFinders.new(@app, @controller)
  end

  def test_it_does_not_fail_with_rails_5
    @check.run
    assert_equal 0, @app.warnings.size
  end

  def test_it_fails_with_rails_4
    @app.rails_version = Gem::Version.new "4.0.1"
    @check.run
    assert_equal 1, @app.warnings.size
  end
end
