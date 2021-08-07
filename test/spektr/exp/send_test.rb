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
      hash = { name: Parser::AST::Node.new(:str, ["dhh"]), password: Parser::AST::Node.new(:str, ["secret"]), except: Parser::AST::Node.new(:sym, [:index]) }
      assert_equal hash, @send.options
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
