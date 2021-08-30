require "test_helper"

class CreateWithTest < Minitest::Test
  def test_it_fails_with_affected_versions
    code = <<-CODE
       user.blog_posts.create_with(params[:blog_post]).create
    CODE
    app = Spektr::App.new(checks: [Spektr::Checks::CreateWith])
    app.rails_version = Gem::Version.new "4.0.0"
    initializer = Spektr::Targets::Base.new("posts_controller.rb", code)
    check = Spektr::Checks::CreateWith.new(app, initializer)
    check.run
    assert_equal 1, app.warnings.size
  end

  def test_it_does_not_fail_with_non_user_input
    code = <<-CODE
       user.blog_posts.create_with({title: "test"}).create
    CODE
    app = Spektr::App.new(checks: [Spektr::Checks::CreateWith])
    app.rails_version = Gem::Version.new "4.0.0"
    initializer = Spektr::Targets::Base.new("posts_controller.rb", code)
    check = Spektr::Checks::CreateWith.new(app, initializer)
    check.run
    assert_equal 0, app.warnings.size
  end

  def test_it_does_not_fail_with_permitted_params
    code = <<-CODE
       user.blog_posts.create_with(params[:blog_post].permit(:title)).create
    CODE
    app = Spektr::App.new(checks: [Spektr::Checks::CreateWith])
    app.rails_version = Gem::Version.new "4.0.0"
    initializer = Spektr::Targets::Base.new("posts_controller.rb", code)
    check = Spektr::Checks::CreateWith.new(app, initializer)
    check.run
    assert_equal 0, app.warnings.size
  end
end
