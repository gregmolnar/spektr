require "test_helper"

class EvaluationTest < Minitest::Test
  def setup
    @code = <<-CODE
      class ApplicationController
        def index
          eval("whoami")
          eval(`ls \#{params[:directory]}`)
          instance_eval params[:code]
        end
      end
    CODE
    @app = Spektr::App.new(checks: [Spektr::Checks::Evaluation])
    @controller = Spektr::Targets::Controller.new("application_controller.rb", @code)
    @check = Spektr::Checks::Evaluation.new(@app, @controller)
  end

  def test_it_fails_with_user_supplied_value
    @check.run
    assert_equal 2, @app.warnings.size
  end

  def test_a_finding_can_be_ignored_with_a_comment_on_the_previous_line
    code = <<~CODE
      class ApplicationController
        def index
          # spektr:ignore Arbitrary code execution -- params are validated before this method is called
          eval(params[:trusted_code])
          eval(params[:untrusted_code])
        end
      end
    CODE
    app = Spektr::App.new(checks: [Spektr::Checks::Evaluation])
    controller = Spektr::Targets::Controller.new("application_controller.rb", code)

    Spektr::Checks::Evaluation.new(app, controller).run

    assert_equal 1, app.warnings.size
    assert_equal 5, app.warnings.first.location.start_line
  end

  def test_an_ignore_comment_only_applies_to_the_immediately_following_line
    code = <<~CODE
      class ApplicationController
        def index
          # spektr:ignore Arbitrary code execution

          eval(params[:code])
        end
      end
    CODE
    app = Spektr::App.new(checks: [Spektr::Checks::Evaluation])
    controller = Spektr::Targets::Controller.new("application_controller.rb", code)

    Spektr::Checks::Evaluation.new(app, controller).run

    assert_equal 1, app.warnings.size
  end

  def test_ignore_comment_only_ignores_the_named_check
    code = <<~CODE
      class ApplicationController
        def index
          # spektr:ignore Arbitrary code execution
          eval(send(params[:method]))
        end
      end
    CODE
    checks = [Spektr::Checks::Evaluation, Spektr::Checks::Send]
    app = Spektr::App.new(checks: checks)
    controller = Spektr::Targets::Controller.new("application_controller.rb", code)

    checks.each { |check| check.new(app, controller).run }

    assert_equal 1, app.warnings.size
    assert_instance_of Spektr::Checks::Send, app.warnings.first.check
  end

  def test_ignore_comment_accepts_multiple_checks
    code = <<~CODE
      class ApplicationController
        def index
          # spektr:ignore Arbitrary code execution, Dangerous send -- both uses are safe
          eval(send(params[:method]))
        end
      end
    CODE
    checks = [Spektr::Checks::Evaluation, Spektr::Checks::Send]
    app = Spektr::App.new(checks: checks)
    controller = Spektr::Targets::Controller.new("application_controller.rb", code)

    checks.each { |check| check.new(app, controller).run }

    assert_empty app.warnings
  end

  def test_ignore_comment_requires_at_least_one_check
    code = <<~CODE
      class ApplicationController
        def index
          # spektr:ignore
          eval(params[:code])
        end
      end
    CODE
    app = Spektr::App.new(checks: [Spektr::Checks::Evaluation])
    controller = Spektr::Targets::Controller.new("application_controller.rb", code)

    Spektr::Checks::Evaluation.new(app, controller).run

    assert_equal 1, app.warnings.size
  end
end
