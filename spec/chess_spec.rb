# frozen_string_literal: true

require './lib/chess'

describe Chess do
  # describe '#clear_board' do
  #   subject(:test_game) { Chess.new }

  #   it 'has 8 rows' do
  #     test_game.clear_board
  #     expect(test_game.instance_variable_get(:@board).size).to eq(8)
  #   end

  #   it 'has 8 columns' do
  #     test_game.clear_board
  #     expect(test_game.instance_variable_get(:@board).first.size).to eq(8)
  #   end

  #   it 'columns are nil' do
  #     test_game.clear_board
  #     expect(test_game.instance_variable_get(:@board).last.all? {|sq| sq.nil? }).to be true
  #   end
  # end
  # describe '#alpha_to_coord' do
  #   subject(:test_game) { Chess.new }

  #   it 'returns correct values for a1' do
  #     result = test_game.alpha_to_coord('a1')
  #     expect(result).to eq([0, 0])
  #   end

  #   it 'returns correct values for h8' do
  #     result = test_game.alpha_to_coord('h8')
  #     expect(result).to eq([7, 7])
  #   end
  # end
  describe 'add_piece' do
    subject(:test_game) { described_class.new }
    let(:test_piece) { WhitePawn.new(nil) }
    before do
      test_game.add_piece(test_piece, 'a1')
    end
    it 'assigns to a1 correctly' do
      expect(test_game.instance_variable_get(:@board).grid[0][0]).to eq(test_piece)
    end
    it 'does not assign a2' do
      expect(test_game.instance_variable_get(:@board).grid[1][0]).to eq(nil)
    end
  end
  describe '@create_pawn' do
    subject(:test_game) { described_class.new }
    let(:test_piece) { WhitePawn.new(nil) }

    before do
      allow(Piece).to receive(:new).and_return(test_piece)
    end

    it 'calls set_board_loc correctly' do
      expect(test_game).to receive(:add_piece).with(test_piece, 'a1').once
      test_game.create_pawn('W', 'a1')
    end

    it 'sets piece_to_loc_hash' do
      test_game.create_pawn('W', 'a1')
      expect(test_game.instance_variable_get(:@piece_to_loc_hash)[:a1]).to eq(test_piece)
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
      expect(test_game).to receive(:create_pawn).with('W', 'a2').once
      test_game.setup_pawns('W')
    end

    it 'creates last black pawn correctly' do
      allow(test_game).to receive(:create_pawn)
      expect(test_game).to receive(:create_pawn).with('B', 'h7').once
      test_game.setup_pawns('B')
    end
  end
  describe '#parse_mode' do
    subject(:test_game) { described_class.new }
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
      result = hash.select { |_loc, piece| piece.is_a?(BlackBishop) }
      expect(result.size).to eq(2)
    end

    it 'should be a white king on e1' do
      piece = test_game.instance_variable_get(:@board).grid[0][4]
      expect(piece.is_a?(WhiteKing)).to be true
      expect(piece.color).to eq('W')
      expect(piece.location).to eq('e1')
    end
  end
  describe '#exposes_king?' do
    subject(:test_game) { described_class.new }
    let(:test_piece) { WhiteQueen.new('e2') }

    before do
      test_game.add_piece(WhiteKing.new('e1'), 'e1')
      test_game.add_piece(test_piece, 'e2')
      test_game.add_piece(BlackRook.new('e8'), 'e8')
    end

    it 'is a valid move to move queen away' do
      result = test_piece.valid_move?('d2', false, test_game.instance_variable_get(:@board))
      expect(result).to be true
    end
    it 'will be flagged by expose_king?' do
      result = test_game.exposes_king?(test_piece, 'd2', false)
      expect(result).to be true
    end
    it 'will not be flagged by expose_king? if we keep on same file' do
      result = test_game.exposes_king?(test_piece, 'e3', false)
      expect(result).to be false
    end
  end
end

describe WhitePawn do
  describe '#valid_move?' do
    subject(:test_piece) { described_class.new('d2') }
    let(:test_game) { Chess.new }
    let(:board) { test_game.instance_variable_get(:@board) }
    before do
      test_game.setup_board
    end

    it 'can be moved to d3' do
      result = test_piece.valid_move?('d3', false, board)
      expect(result).to be true
    end
    it 'can be moved to d4' do
      result = test_piece.valid_move?('d4', false, board)
      expect(result).to be true
    end
    it 'cannot be moved to d5' do
      result = test_piece.valid_move?('d5', false, board)
      expect(result).to be false
    end
    it 'can be moved to e3 if capture and enemy piece present' do
      test_game.add_piece(BlackPawn.new(nil), 'e3')
      result = test_piece.valid_move?('e3', true, board)
      expect(result).to be true
    end
    it 'cannot be moved to e3 if friendly piece present' do
      test_game.add_piece(WhitePawn.new(nil), 'e3')
      result = test_piece.valid_move?('e3', true, board)
      expect(result).to be false
    end
    it 'cannot be moved to e3 if no piece present' do
      result = test_piece.valid_move?('e3', true, board)
      expect(result).to be false
    end
    it 'cannot be moved to e3 if no capture' do
      result = test_piece.valid_move?('e3', false, board)
      expect(result).to be false
    end
  end

  describe BlackKnight do
    describe '#valid_move?' do
      subject(:test_piece) { BlackKnight.new('b8') }
      let(:test_board) { Board.new }

      before do
        test_board.add_piece(test_piece, 'b8')
        test_board.add_piece(WhiteQueen.new('a6'), 'a6')
        test_board.add_piece(BlackPawn.new('d7'), 'd7')
      end

      it 'will move to an empty space' do
        result = test_piece.valid_move?('c6', false, test_board)
        expect(result).to be true
      end
      it 'will not move to an empty space if capture set' do
        result = test_piece.valid_move?('c6', true, test_board)
        expect(result).to be false
      end
      it 'will capture an enemy piece' do
        result = test_piece.valid_move?('a6', true, test_board)
        expect(result).to be true
      end
      it 'will not capture an enemy piece if capture not set' do
        result = test_piece.valid_move?('a6', false, test_board)
        expect(result).to be false
      end
      it 'will not capture a friendly piece' do
        result = test_piece.valid_move?('d7', true, test_board)
        expect(result).to be false
      end
    end
  end
  describe WhiteBishop do
    subject(:test_piece) { WhiteBishop.new('e4') }
    let(:test_board) { Board.new }

    before do
      test_board.add_piece(test_piece, 'e4')
      test_board.add_piece(WhiteKing.new('c6'), 'c6')
      test_board.add_piece(BlackRook.new('g6'), 'g6')
      test_board.add_piece(BlackBishop.new('b1'), 'b1')
    end

    it 'will move to open diagonal' do
      result = test_piece.valid_move?('h1', false, test_board)
      expect(result).to be true
    end
    it 'will not move past an obstruction' do
      result = test_piece.valid_move?('b7', false, test_board)
      expect(result).to be false
    end
    it 'will not move onto its own piece' do
      result = test_piece.valid_move?('c6', false, test_board)
      expect(result).to be false
    end
    it 'will capture an enemy piece' do
      result = test_piece.valid_move?('g6', true, test_board)
      expect(result).to be true
    end
    it 'will capture an edge piece' do
      result = test_piece.valid_move?('b1', true, test_board)
      expect(result).to be true
    end
    it 'will not move to a random spot' do
      result = test_piece.valid_move?('d6', false, test_board)
      expect(result).to be false
    end
  end
  describe BlackRook do
    subject(:test_piece) { described_class.new('b8') }
    let(:test_board) { Board.new }

    before do
      test_board.add_piece(test_piece, 'b8')
      test_board.add_piece(WhiteRook.new('b2'), 'b2')
      test_board.add_piece(BlackKing.new('e8'), 'e8')
      test_board.add_piece(WhitePawn.new('e5'), 'e5')
    end
    it 'moves down the board' do
      result = test_piece.valid_move?('b3', false, test_board)
      expect(result).to be true
    end
    it 'wont move past a piece' do
      result = test_piece.valid_move?('h8', false, test_board)
      expect(result).to be false
    end
    it 'will capture an enemy piece' do
      result = test_piece.valid_move?('b2', true, test_board)
      expect(result).to be true
    end
    it 'wont move diagonally' do
      result = test_piece.valid_move?('d6', false, test_board)
      expect(result).to be false
    end
    it 'wont capture diagonally' do
      result = test_piece.valid_move?('e5', true, test_board)
      expect(result).to be false
    end
  end
  describe BlackQueen do
    subject(:test_piece) { described_class.new('b8') }
    let(:test_board) { Board.new }

    before do
      test_board.add_piece(test_piece, 'b8')
      test_board.add_piece(WhiteRook.new('b2'), 'b2')
      test_board.add_piece(BlackKing.new('e8'), 'e8')
      test_board.add_piece(WhitePawn.new('e5'), 'e5')
    end
    it 'moves down the board' do
      result = test_piece.valid_move?('b3', false, test_board)
      expect(result).to be true
    end
    it 'wont move past a piece' do
      result = test_piece.valid_move?('h8', false, test_board)
      expect(result).to be false
    end
    it 'will capture an enemy piece' do
      result = test_piece.valid_move?('b2', true, test_board)
      expect(result).to be true
    end
    it 'will move diagonally' do
      result = test_piece.valid_move?('d6', false, test_board)
      expect(result).to be true
    end
    it 'will capture diagonally' do
      result = test_piece.valid_move?('e5', true, test_board)
      expect(result).to be true
    end
  end
end
