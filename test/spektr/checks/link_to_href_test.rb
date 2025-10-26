require "test_helper"

class LinkToHrefTest < Minitest::Test
  def test_it_fails_with_a_user_supplied_value_with_block
    code = <<-CODE
      <%=
      link_to params[:blog] do
        "hello"
      end
      %>
    CODE
    app = Spektr::App.new(checks: [Spektr::Checks::LinkToHref])
    view = Spektr::Targets::View.new("index.html.erb", code)
    check = Spektr::Checks::LinkToHref.new(app, view)
    check.run
    assert_equal 1, app.warnings.size
  end

  def test_it_fails_with_a_user_supplied_value
    code = <<-CODE
      <%= link_to "Hello", params[:blog] %>
      <%= link_to "Hello".html_safe, params[:blog] %>
      link_to "\#{inline_svg_tag('email.svg', aria_hidden: true, class: 'crayons-icon', title: 'email')}Sign up with Email".html_safe,
                request.params.merge(state: "email_signup").except("i"),
                class: "crayons-btn crayons-btn--l crayons-btn--brand-email crayons-btn--icon-left whitespace-nowrap",
                data: { no_instant: "" }
    CODE
    app = Spektr::App.new(checks: [Spektr::Checks::LinkToHref])
    view = Spektr::Targets::View.new("index.html.erb", code)
    check = Spektr::Checks::LinkToHref.new(app, view)
    check.run
    assert_equal 2, app.warnings.size
  end

  def test_it_does_not_fail_with_url_helpers
    code = <<-CODE
      <%= link_to school.activities.count, school_activities_path(params[:id]) %>
      <%= link_to school.activities.count, school_activities_path(params[:id]) %>
    CODE
    app = Spektr::App.new(checks: [Spektr::Checks::LinkToHref])
    view = Spektr::Targets::View.new("index.html.erb", code)
    check = Spektr::Checks::LinkToHref.new(app, view)
    check.run
    assert_equal 0, app.warnings.size
  end
end
