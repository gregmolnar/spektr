require "test_helper"

class CsrfSettingTest < Minitest::Test

  def test_it_does_not_fail_when_parent_enables_protection
    application_controller = <<-CODE
      class ApplicationController
        protect_from_forgery
      end
    CODE
    code = <<-CODE
     class PostsController < ApplicationController
     end
    CODE
    app = Spektr::App.new(checks: [Spektr::Checks::CsrfSetting])
    app.rails_version = Gem::Version.new("4.0.0")
    app.controllers = [Spektr::Targets::Controller.new("application_controller.rb", application_controller)]
    controller = Spektr::Targets::Base.new("posts_controller.rb", code)
    check = Spektr::Checks::CsrfSetting.new(app, controller)
    check.run
    assert_equal 0, app.warnings.size
  end

  def test_it_does_not_fail_when_parent_does_not_enable_protection
    application_controller = <<-CODE
      class ApplicationController
      end
    CODE
    code = <<-CODE
     class PostsController < ApplicationController
     end
    CODE
    app = Spektr::App.new(checks: [Spektr::Checks::CsrfSetting])
    app.rails_version = Gem::Version.new("4.0.0")
    app.controllers = [Spektr::Targets::Controller.new("application_controller.rb", application_controller)]
    controller = Spektr::Targets::Base.new("posts_controller.rb", code)
    check = Spektr::Checks::CsrfSetting.new(app, controller)
    check.run
    assert_equal 1, app.warnings.size
  end

  def test_it__fails_when_skips_protection
    application_controller = <<-CODE
      class ApplicationController
        protect_from_forgery
      end
    CODE
    code = <<-CODE
     class PostsController < ApplicationController
       skip_forgery_protection
     end
    CODE
    app = Spektr::App.new(checks: [Spektr::Checks::CsrfSetting])
    app.rails_version = Gem::Version.new("4.0.0")
    app.controllers = [Spektr::Targets::Controller.new("application_controller.rb", application_controller)]
    controller = Spektr::Targets::Base.new("posts_controller.rb", code)
    check = Spektr::Checks::CsrfSetting.new(app, controller)
    check.run
    assert_equal 1, app.warnings.size
  end

end
