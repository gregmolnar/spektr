require "test_helper"

class CookieSerializationTest < Minitest::Test
  def test_it_fails_with_marshal
    code = <<-CODE
      Rails.application.config.action_dispatch.cookies_serializer = :marshal
    CODE
    app = Spektr::App.new(checks: [Spektr::Checks::CookieSerialization])
    initializer = Spektr::Targets::Base.new("cookies_serialization.rb", code)
    check = Spektr::Checks::CookieSerialization.new(app, initializer)
    check.run
    assert_equal 1, app.warnings.size
  end
end
