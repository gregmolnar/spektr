require "test_helper"
describe Spektr::Exp::Send do
  describe "with options" do
    before do
      code = <<-CODE
        http_basic_authenticate_with name: "dhh", password: "secret", except: :index
      CODE
      ast = Parser::CurrentRuby.parse(code)
      @send = Spektr::Exp::Send.new(ast)
    end

    it "sets name" do
      assert_equal :http_basic_authenticate_with, @send.name
    end

    it "sets receiver" do
      assert_nil @send.receiver
    end

    it "sets receiver" do
      _send = Spektr::Exp::Send.new(Parser::CurrentRuby.parse('"foobar".upcase'))
      assert_equal '(str "foobar")', _send.receiver.to_s
    end

    it "has options" do
      refute @send.options.nil?
      assert_equal :sym, @send.options[:name].key.type
      assert_equal :str, @send.options[:name].value.type
      assert_equal :sym, @send.options[:except].key.type
      assert_equal :sym, @send.options[:except].value.type
    end

    it "handles ivar in options key" do
      code = <<-CODE
        content_tag "test", @class => "hello"
      CODE
      ast = Parser::CurrentRuby.parse(code)
      _send = Spektr::Exp::Send.new(ast)
      assert_equal :ivar, _send.options[:@class].key.type
      assert_equal :str, _send.options[:@class].value.type
    end

    it "handles params argument" do
      code = <<-CODE
        create_with(params[:blog_post])
      CODE
      ast = Parser::CurrentRuby.parse(code)
      _send = Spektr::Exp::Send.new(ast)
      assert_equal :send, _send.arguments.first.type
      assert_equal :params, _send.arguments.first.name
    end

    it "handles chained argument" do
      code = <<-CODE
        create_with(params[:blog_post].permit(:title))
      CODE
      ast = Parser::CurrentRuby.parse(code)
      _send = Spektr::Exp::Send.new(ast)
      assert_equal :send, _send.arguments.first.type
      assert_equal :params, _send.arguments.first.name
    end
  end

  describe "with no options" do
    before do
      code = <<-CODE
        http_basic_authenticate_with
      CODE

      ast = Parser::CurrentRuby.parse(code)
      @send = Spektr::Exp::Send.new(ast)
    end

    it "has no options" do
      assert_empty @send.options
    end
  end
end
