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
  describe 'check?' do
    subject(:test_game) { described_class.new }
    let(:test_board) { test_game.instance_variable_get(:@board) }
    let(:test_knight) { WhiteKnight.new('d6') }
    let(:test_bishop) { WhiteBishop.new('e2') }

    before do
      test_game.instance_variable_set(:@turn, 'W')
      test_game.add_piece(BlackKing.new('e8'), 'e8')
      test_game.add_piece(WhiteRook.new('e1'), 'e1')
      test_game.add_piece(test_bishop, 'e2')
      test_game.add_piece(test_knight, 'd6')
    end

    it 'should be a check' do
      result = test_game.check?
      expect(result).to be true
    end
    it 'should not be a check if knight moves' do
      test_game.execute_move(test_knight, 'b5', false)
      result = test_game.check?
      expect(result).to be false
    end
    it 'should be a check if knight and bishop move' do
      test_game.execute_move(test_knight, 'b5', false)
      test_game.execute_move(test_bishop, 'd3', false)
      result = test_game.check?
      expect(result).to be true
    end
  end
  describe 'checkmate?' do
    subject(:test_game) { described_class.new }

    context 'arbitrary board with checkmate' do
      before do
        test_game.instance_variable_set(:@turn, 'W')
        test_game.add_piece(BlackKing.new('a8'), 'a8')
        test_game.add_piece(WhiteQueen.new('a7'), 'a7')
        test_game.add_piece(WhiteKing.new('b6'), 'b6')
      end

      it 'should be a checkmate' do
        result = test_game.checkmate?
        expect(result).to be true
      end
      it 'should not be a checkmate if we move the queen' do
        test_game.execute_move(test_game.get_piece_from_loc('a7'), 'a3', false)
        result = test_game.checkmate?
        expect(result).to be false
      end
    end
    context 'checkmate from a start position' do
      it 'finds the checkmate' do
        test_game.setup_board
        test_game.instance_variable_set(:@turn, 'B')
        test_game.execute_move(test_game.get_piece_from_loc('f2'), 'f3', false)
        test_game.execute_move(test_game.get_piece_from_loc('e7'), 'e5', false)
        test_game.execute_move(test_game.get_piece_from_loc('g2'), 'g4', false)
        test_game.execute_move(test_game.get_piece_from_loc('d8'), 'h4', false)
        result = test_game.checkmate?
        expect(result).to be true
      end
    end
  end
  describe 'castling' do
    subject(:test_game) { described_class.new }
    let(:test_king) { WhiteKing.new('e1')}
    let(:test_rook) { WhiteRook.new('h1')}
    before do
      test_game.add_piece(test_king,'e1')
      test_game.add_piece(test_rook,'h1')
    end

    it 'castles when legal' do
      result = test_game.castle_move('o-o')
      expect(result).to be true
      expect(test_king.location).to eq('g1')
      expect(test_rook.location).to eq('f1')
    end

    it 'does not castle if king has moved' do
      test_game.execute_move(test_king, 'd1', false)
      test_game.execute_move(test_king, 'e1', false)
      result = test_game.castle_move('o-o')
      expect(result).to be false
      expect(test_king.location).to eq('e1')
      expect(test_rook.location).to eq('h1')
    end

    it 'does not castle if rook not present' do
      result = test_game.castle_move('o-o-o')
      expect(result).to be false
    end

    it 'does not castle if obstruction' do
      test_game.add_piece(WhiteBishop.new('f1'), 'f1')
      result = test_game.castle_move('o-o')
      expect(result).to be false
    end

    it 'does not castle if in check' do
      test_game.add_piece(BlackRook.new('e8'), 'e8')
      result = test_game.castle_move('o-o')
      expect(result).to be false
    end

    it 'does not castle if it ends up in a check' do
      test_game.add_piece(BlackKnight.new('h3'), 'h3')
      result = test_game.castle_move('o-o')
      expect(result).to be false
    end

    it 'does not castle if it passes through an attacked square' do
      test_game.add_piece(BlackBishop.new('a6'), 'a6')
      result = test_game.castle_move('o-o')
      expect(result).to be false
    end

    it 'does not castle if attacking piece is block ' do
      test_game.add_piece(BlackBishop.new('a6'), 'a6')
      test_game.add_piece(WhitePawn.new('e2'), 'e2')
      result = test_game.castle_move('o-o')
      expect(result).to be true
    end
  end
  describe 'simulated game' do
    subject(:test_game) { described_class.new }

    it 'ends when supposed to' do
      allow(test_game).to receive(:gets).and_return('pe4','pc5','nf3','pd6','pd4','pxd4','nxd4','nf6','nc3','pe6',\
        'bc4','pa6','pa3','be7','ba2','pb5','be3','o-o','qf3','bb7','o-o-o','nbd7','qh3','rc8','pf3','rxc3','pxc3','pd5',\
      'pxd5', 'bxa3', 'kb1', 'bxd5', 'nb3', 'qc7', 'bd2', 'rc8', 'rhe1', 'nb6', 'qh4', 'na4', 'qd4', 'bb2', \
      'qe5', 'qc6', 'nd4', 'bxa2', 'kxa2', 'qc4', 'kb1', 'bxc3', 'bxc3', 'qxc3', 'kc1', 'nb6', 're3', 'qa1', \
      'kd2', 'nc4', 'ke2', 'qb2', 'qg3', 'nxe3', 'kxe3', 'pb4', 'qd6', 'ph6', 'qxa6', 'rc3', 'rd3', 'pb3',\
      'nxb3', 'nd5', 'ke4', 'rxc2', 'qa8', 'kh7', 'nd4', 're2', 'nxe2', 'pf5')
      test_game.play_game
      expect(test_game.checkmate?).to be true
    end
  end
  describe 'load_game' do
    subject(:test_game) { described_class.new }

    it 'loads a game correctly' do
      allow(test_game).to receive(:gets).and_return('karl_json_test')
      test_game.load_game
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
