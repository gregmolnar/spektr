class WelcomeController < ApplicationController
  def index
    @welcome_message = params[:welcome_message]
    @attr = params[:attr]
    @safe_attr = "class"
    @post = Post.last
  end
end
