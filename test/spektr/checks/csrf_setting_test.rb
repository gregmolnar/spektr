require 'test_helper'

class CsrfSettingTest < Minitest::Test
  def test_it_does_not_fail_when_parent_enables_protection
    application_controller = <<-CODE
      require "foobar"
      class ApplicationController
        protect_from_forgery
      end
    CODE
    code = <<-CODE
     class PostsController < ApplicationController
     end
    CODE
    app = Spektr::App.new(checks: [Spektr::Checks::CsrfSetting])
    app.rails_version = Gem::Version.new('4.0.0')
    app.controllers = [Spektr::Targets::Controller.new('application_controller.rb', application_controller)]
    controller = Spektr::Targets::Controller.new('posts_controller.rb', code)
    check = Spektr::Checks::CsrfSetting.new(app, controller)
    check.run
    assert_equal 0, app.warnings.size
  end

  def test_it_fails_when_parent_does_not_enable_protection
    application_controller = <<-CODE
      class ApplicationController
      end
    CODE
    code = <<-CODE
     class PostsController < ApplicationController
     end
    CODE
    app = Spektr::App.new(checks: [Spektr::Checks::CsrfSetting])
    app.rails_version = Gem::Version.new('4.0.0')
    app.controllers = [Spektr::Targets::Controller.new('application_controller.rb', application_controller)]
    controller = Spektr::Targets::Controller.new('posts_controller.rb', code)
    check = Spektr::Checks::CsrfSetting.new(app, controller)
    check.run
    assert_equal 1, app.warnings.size
  end

  def test_it_doesnot_fail_with_multi_level_parents
    application_controller = <<-CODE
      class ApplicationController
        protect_from_forgery
      end
    CODE
    admin_controller = <<-CODE
      class AdminController < ApplicationController
      end
    CODE

    code = <<-CODE
      class PostsController < AdminController
      end
    CODE
    app = Spektr::App.new(checks: [Spektr::Checks::CsrfSetting])
    app.rails_version = Gem::Version.new('4.0.0')
    app.controllers = [Spektr::Targets::Controller.new('application_controller.rb', application_controller),
                       Spektr::Targets::Controller.new('admin_controller.rb', admin_controller)]
    controller = Spektr::Targets::Controller.new('posts_controller.rb', code)
    check = Spektr::Checks::CsrfSetting.new(app, controller)
    check.run
    assert_equal 0, app.warnings.size

    code = <<-CODE
      module Admin
        module Settings
          class BaseController < Admin::ApplicationController
          end
        end
      end
    CODE
    app.controllers << Spektr::Targets::Controller.new('admin/settings/base_controller.rb', code)
    code = <<-CODE
      module Admin
        module Settings
          class CampaignsController < Admin::Settings::BaseController
          end
        end
      end
    CODE
    controller = Spektr::Targets::Controller.new('admin/settings/campaigns_controller.rb', code)
    app.controllers << controller
    check = Spektr::Checks::CsrfSetting.new(app, controller)
    check.run
    assert_equal 0, app.warnings.size

    generic_controller = <<-CODE
      module Admin
        class GenericController < ApplicationController
        end
      end
    CODE
    code = <<-CODE
      module Admin
        class PostsController < Admin::GenericController
        end
      end
    CODE
    app = Spektr::App.new(checks: [Spektr::Checks::CsrfSetting])
    app.rails_version = Gem::Version.new('4.0.0')
    app.controllers = [
      Spektr::Targets::Controller.new('application_controller.rb', application_controller),
      Spektr::Targets::Controller.new('generic_controller.rb', generic_controller)
    ]
    controller = Spektr::Targets::Controller.new('posts_controller.rb', code)
    check = Spektr::Checks::CsrfSetting.new(app, controller)
    check.run
    assert_equal 0, app.warnings.size
  end

  def test_it_fails_when_skips_protection
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
    app.rails_version = Gem::Version.new('4.0.0')
    app.controllers = [Spektr::Targets::Controller.new('application_controller.rb', application_controller)]
    controller = Spektr::Targets::Controller.new('posts_controller.rb', code)
    check = Spektr::Checks::CsrfSetting.new(app, controller)
    check.run
    assert_equal 1, app.warnings.size
  end
end
