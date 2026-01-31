require "test_helper"

class BaseTest < Minitest::Test
  def test_user_input_and_model_input_can_parse
    code = <<~'CODE'
      @game.metrics_game_id == @game.id ? @game : Game.find(@game.metrics_game_id)
      send(:"#{some_var}")
      [1,2,3]
      time ||= Time.now
      date = (time || Time.now).in_time_zone('Pacific Time (US & Canada)').to_date
      true && true
      full_uri = 'file://' + Rails.public_path.join(*url.split('/')).to_s
      OgObject.where(game_id: self[:'games.id'], type: 'NotificationObject').first
      relation = finder_class.unscoped.where(relation)
    CODE
    app = Spektr::App.new(checks: [])
    target = Spektr::Targets::Base.new('example.rb', code)
    check = Spektr::Checks::Base.new(app, target)
    target.ast.value.statements.body.each do |node|
      check.user_input?(node)
      check.model_attribute?(node)
    end
  end
end
