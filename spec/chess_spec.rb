# frozen_string_literal: true

require './lib/chess.rb'

describe Chess do
  describe '#clear_board' do
    subject(:test_game) { Chess.new }

    it 'has 8 rows' do
      test_game.clear_board
      expect(test_game.instance_variable_get(:@board).size).to eq(8)
    end

    it 'has 8 columns' do
      test_game.clear_board
      expect(test_game.instance_variable_get(:@board).first.size).to eq(8)
    end

    it 'columns are nil' do
      test_game.clear_board
      expect(test_game.instance_variable_get(:@board).last.all? {|sq| sq.nil? }).to be true
    end
  end
end