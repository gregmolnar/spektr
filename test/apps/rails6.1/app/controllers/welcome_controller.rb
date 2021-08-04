class WelcomeController < ApplicationController
  def index
    @welcome_message = params[:welcome_message]
    @attr = params[:attr]
  end
end
