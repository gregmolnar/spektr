require "test_helper"
describe Spektr::Exp::Send do
  describe "with options" do
    before do
      code = <<-CODE
        http_basic_authenticate_with name: "dhh", password: "secret", except: :index
      CODE
      ast = Parser::CurrentRuby.parse(code)
      @call = Spektr::Exp::Send.new(ast)
    end

    it "sets name" do
      assert_equal :http_basic_authenticate_with, @call.name
    end

    it "has options" do
      hash = { name: Parser::AST::Node.new(:str, ["dhh"]), password: Parser::AST::Node.new(:str, ["secret"]), except: Parser::AST::Node.new(:sym, [:index]) }
      assert_equal hash, @call.options
    end
  end

  describe "with no options" do
    before do
      code = <<-CODE
        http_basic_authenticate_with
      CODE

      ast = Parser::CurrentRuby.parse(code)
      @call = Spektr::Exp::Send.new(ast)
    end

    it "has no options" do
      assert_empty @call.options
    end
  end
end
