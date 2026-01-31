require "test_helper"

class DeserializeTest < Minitest::Test

  def test_with_csv_load
    code = <<-CODE
      class ApplicationController
        def index
          CSV.load(params[:path])
          CSV.load("test.csv")
        end
      end
    CODE
    app = Spektr::App.new(checks: [Spektr::Checks::Deserialize])
    controller = Spektr::Targets::Controller.new("application_controller.rb", code)
    check = Spektr::Checks::Deserialize.new(app, controller)
    check.run
    assert_equal 1, app.warnings.size
  end

  def test_with_yaml
    code = <<-CODE
      class ApplicationController
        def index
          YAML.load_documents(params[:path])
          YAML.load_stream(params[:path])
          YAML.parse_documents(params[:path])
          YAML.parse_stream(params[:path])
        end
      end
    CODE
    app = Spektr::App.new(checks: [Spektr::Checks::Deserialize])
    controller = Spektr::Targets::Controller.new("application_controller.rb", code)
    check = Spektr::Checks::Deserialize.new(app, controller)
    check.run
    assert_equal 4, app.warnings.size
  end

  def test_with_marshal
    code = <<-CODE
      class ApplicationController
        def index
          Marshal.load("test")
          Marshal.load(params[:path])
          Marshal.restore(params[:path])
          Marshal.load(Base64.decode64(params[:user]))
        end
      end
    CODE
    app = run_check(code)
    assert_equal 3, app.warnings.size
  end

  def test_with_oj
    code = <<-CODE
      class ApplicationController
        def index
          Oj.object_load("test")
          Oj.object_load(params[:path])
          Oj.load(params[:path])
        end
      end
    CODE
    app = run_check(code)
    assert_equal 2, app.warnings.size

    # with safe mode
    code = <<~'CODE'
      class ApplicationController
        def index
          Oj.default_options = { mode: :strict }
          Oj.object_load("test")
          Oj.object_load(params[:path])
          Oj.load(params[:path])
          result = Curl.get("https://posts.#{Carrot.config[:service_domain_root]}/audit_log", query).body_str
          data = data = Oj.load(result, mode: :compat)
        end
      end
    CODE
    app = run_check(code)
    assert_equal 1, app.warnings.size
  end

  def run_check(code)
    app = Spektr::App.new(checks: [Spektr::Checks::Deserialize])
    controller = Spektr::Targets::Controller.new("application_controller.rb", code)
    check = Spektr::Checks::Deserialize.new(app, controller)
    check.run
    app
  end
end
