require "test_helper"

class DefaultRoutesTest < Minitest::Test

  def setup
    @app = Spektr::App.new(root: RAILS_6_1_ROOT, checks: [Spektr::Checks::DefaultRoutes])
  end

  def test_match_all_actions_with_rails_3
    @app.rails_version = Gem::Version.new "3.0.1"
    code = <<-CODE
      Rails3::Application.routes.draw do
        match ':controller(/:action(/:id(.:format)))'
        match ':controller/:action'
        match 'posts/:action', controller: 'posts'
        match 'posts/*action', controller: 'posts'
      end
    CODE
    routes = Spektr::Targets::Routes.new("routes.rb", code)
    check = Spektr::Checks::DefaultRoutes.new(@app, routes)
    check.run
    assert_equal 5, @app.warnings.size
  end

  def test_verb_all_actions_with_rails_3
    @app.rails_version = Gem::Version.new "3.0.1"
    code = <<-CODE
      Rails3::Application.routes.draw do
        get ":controller/:action"
        get "/posts/:action"
        post "/posts/:action"
      end
    CODE
    routes = Spektr::Targets::Routes.new("routes.rb", code)
    check = Spektr::Checks::DefaultRoutes.new(@app, routes)
    check.run
    assert_equal 4, @app.warnings.size
  end
end
