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
end
