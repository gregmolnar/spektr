require "test_helper"

class FileDisclosureTest < Minitest::Test

  def test_it_fails_with_insecure_config
    code = <<-CODE
     Rails.application.configure do
      config.serve_static_assets = true
     end
    CODE
    app = Spektr::App.new(checks: [Spektr::Checks::FileDisclosure])
    app.rails_version = Gem::Version.new("4.0.0")
    config = Spektr::Targets::Base.new("production.rb", code)
    app.production_config = config
    check = Spektr::Checks::FileDisclosure.new(app, config)
    check.run
    assert_equal 1, app.warnings.size
  end

end
