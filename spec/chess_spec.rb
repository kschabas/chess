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
    let(:test_piece) { double('Piece') }
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
  describe '@create_pawn' do
    subject(:test_game) { described_class.new }
    let(:test_piece) { double('Piece', name: 'p1W', location: 'a1')  }

    before do
      allow(Piece).to receive(:new).and_return(test_piece)
    end

    it 'calls set_board_loc correctly' do
      expect(test_game).to receive(:set_board_loc).with('a1',test_piece).once
      test_game.create_pawn('p1W', 'W', 'a1')
    end

    it 'sets piece_to_loc_hash' do
      test_game.create_pawn('p1W', 'W', 'a1')
      expect(test_game.instance_variable_get(:@piece_to_loc_hash)[:p1W]).to eq(test_piece)
    end
  end
  describe '#setup_pawns' do
    subject(:test_game) { described_class.new }

    it 'check that it create 8 pawns' do
      expect(test_game).to receive(:create_pawn).exactly(8).times
      test_game.setup_pawns('W')
    end

    it 'create the first pawn correctly' do
      allow(test_game).to receive(:create_pawn)
      expect(test_game).to receive(:create_pawn).with('p1W', 'W', 'a2').once
      test_game.setup_pawns('W')
    end

    it 'creates last black pawn correctly' do
      allow(test_game).to receive(:create_pawn)
      expect(test_game).to receive(:create_pawn).with('p8B', 'B', 'h7').once
      test_game.setup_pawns('B')
    end
  end
  describe '#parse_mode' do
    subject(:test_game) { described_class.new}
    context 'legal inputs' do
      it 'works on simple move' do
        input = 'Qe4'
        expect(test_game.parse_move(input.downcase)).to eq(['q', false, 'e4', ''])
      end
      it 'works on move with file provided' do
        input = 'Nbc7'
        expect(test_game.parse_move(input.downcase)).to eq(['n', false, 'c7', 'b'])
      end
      it 'works on move with rank provided' do
        input = 'R1f1'
        expect(test_game.parse_move(input.downcase)).to eq(['r', false, 'f1', '1'])
      end
      it 'works on a capture' do
        input = 'Pxd4'
        expect(test_game.parse_move(input.downcase)).to eq(['p', true, 'd4', ''])
      end
      it 'works on a capture with a rank provided' do
        input = 'N3xe2'
        expect(test_game.parse_move(input.downcase)).to eq(['n', true, 'e2', '3'])
      end
    end
    context 'illegal move provided' do
      it 'fails if piece provided is wrong' do
        input = 'Ce3'
        expect(test_game.parse_move(input.downcase)).to be nil
      end
      it 'fails if illegal coordinate provided' do
        input = 'Bj2'
        expect(test_game.parse_move(input.downcase)).to be nil
      end
      it 'fails if illegal rank provided' do
        input = 'Bh9'
        expect(test_game.parse_move(input.downcase)).to be nil
      end
      it 'fails if random capture provided' do
        input = 'Bhx7'
        expect(test_game.parse_move(input.downcase)).to be nil
      end
    end
  end
  describe '#setup_board' do
    subject(:test_game) { described_class.new }

    before do
      test_game.setup_board
    end

    it 'pieces hash should have 32 total pieces' do
      hash = test_game.instance_variable_get(:@piece_to_loc_hash)
      expect(hash.size).to eq(32)
    end

    it 'should have 2 black bishops' do
      hash = test_game.instance_variable_get(:@piece_to_loc_hash)
      result = hash.select { |name, piece| piece.is_a?(Bishop) && piece.color == 'B'}
      expect(result.size).to eq(2)
    end

    it 'should be a white king on e1' do
      piece = test_game.instance_variable_get(:@board)[0][4]
      expect(piece.is_a?(King)).to be true
      expect(piece.color).to eq('W')
      expect(piece.location).to eq('e1')
    end
  end
end

describe Pawn do
  describe '#valid_move?' do
    subject(:test_piece) { described_class.new('P1', 'W', 'd2') }

    it 'can be moved to d3' do
      result = test_piece.valid_move?('d3', false, 'W')
      expect(result).to be true
    end
    it 'can be moved to d4' do
      result = test_piece.valid_move?('d4', false, 'W')
      expect(result).to be true
    end
    it 'cannot be moved to d5' do
      result = test_piece.valid_move?('d5', false, 'W')
      expect(result).to be false
    end
    it 'can be moved to e3 if capture' do
      result = test_piece.valid_move?('e3', true, 'W')
      expect(result).to be true
    end
    it 'cannot be moved to e3 if no capture' do
      result = test_piece.valid_move?('e3', false, 'W')
      expect(result).to be false
    end
  end
end
