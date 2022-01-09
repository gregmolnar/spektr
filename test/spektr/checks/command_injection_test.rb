require "test_helper"

class CommandInjectionTest < Minitest::Test
  def setup
    @code = <<-CODE
      class ApplicationController
        def index
          `ls /home`
          `ls \#{params[:directory]}`
          Kernel.open(params[:directory])
        end
      end
    CODE
    @app = Spektr::App.new(checks: [Spektr::Checks::CommandInjection])
    @controller = Spektr::Targets::Controller.new("application_controller.rb", @code)
    @check = Spektr::Checks::CommandInjection.new(@app, @controller)
  end

  def test_it_fails_with_user_supplied_value
    @check.run
    assert_equal 2, @app.warnings.size
  end

  def test_it_fails_with_interpolation
    code = <<-CODE
      class Benefits
        def self.make_backup(file, data_path, full_file_name)
          if File.exist?(full_file_name)
            silence_streams(STDERR) { system("cp \#{full_file_name} \#{data_path}/bak\#{Time.zone.now.to_i}_\#{file.original_filename}") }
          end
        end
      end
    CODE

    app = Spektr::App.new(checks: [Spektr::Checks::CommandInjection])
    model = Spektr::Targets::Model.new("benefits.rb", code)
    app.models = [model]
    check = Spektr::Checks::CommandInjection.new(app, model)
    check.run
    assert_equal 1, app.warnings.size
  end

  def test_it_fails_with_exec
    code = <<-CODE
      exec("ls \#{params[:directory]}")
    CODE
    app = Spektr::App.new(checks: [Spektr::Checks::CommandInjection])
    model = Spektr::Targets::Model.new("benefits.rb", code)
    app.models = [model]
    check = Spektr::Checks::CommandInjection.new(app, model)
    check.run
    assert_equal 1, app.warnings.size
  end


  def test_it_does_not_fail_on_db_exec
    code = <<-CODE
      rows = DB.exec(<<~SQL, args)
        UPDATE post_timings
         SET msecs = msecs + :msecs
         WHERE topic_id = :topic_id
          AND user_id = :user_id
          AND post_number = :post_number
      SQL
    CODE
    app = Spektr::App.new(checks: [Spektr::Checks::CommandInjection])
    model = Spektr::Targets::Model.new("benefits.rb", code)
    app.models = [model]
    check = Spektr::Checks::CommandInjection.new(app, model)
    check.run
    assert_equal 0, app.warnings.size
  end
end
