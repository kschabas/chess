# frozen_string_literal: true

require './lib/chess'

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
  describe '#alpha_to_coord' do
    subject(:test_game) { Chess.new }

    it 'returns correct values for a1' do
      result = test_game.alpha_to_coord('a1')
      expect(result).to eq([0, 0])
    end

    it 'returns correct values for h8' do
      result = test_game.alpha_to_coord('h8')
      expect(result).to eq([7, 7])
    end
  end
  describe 'set_board_loc' do
    subject(:test_game) { described_class.new }
    let(:test_piece) { double('Board') }
    before do
      test_game.set_board_loc('a1', test_piece)
    end
    it 'assigns to a1 correctly' do
      expect(test_game.instance_variable_get(:@board)[0][0]).to eq(test_piece)
    end
    it 'does not assign a2' do
      expect(test_game.instance_variable_get(:@board)[1][0]).to eq(nil)
    end
  end
end 