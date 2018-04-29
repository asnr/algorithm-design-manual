require 'set'

BOARD_LENGTH = 9
SECTOR_LENGTH = 3

def main(sudoku_file)
  board_string = open(sudoku_file).read
  board_array = parse(board_string)
  board = SudokuBoard.new(board_array)
  solve(board)
end

def solve(board)
  if board.finished?
    print board.to_s if board.solved?
    return board.solved?
  end

  next_space = board.next_space
  board.possible_choices(next_space).each do |choice|
    board.play(next_space, choice)
    solved = solve(board)
    return solved if solved
    board.erase(next_space)
  end
  return false
end

def parse(board_string)
  board = []
  lines = board_string.split("\n")
  lines[0...BOARD_LENGTH].each do |line|
    row = []
    (0...BOARD_LENGTH).each do |column|
      character = line[2 * column]
      value = character == ' ' ? nil : character.to_i
      row << value
    end
    board << row
  end
  board
end

class SudokuBoard
  def initialize(board_array)
    @length = BOARD_LENGTH
    @sector_length = SECTOR_LENGTH
    @sectors_per_side = @length / @sector_length
    @board = board_array.map(&:dup)
    @unfilled_points = []
    each_with_point do |value, point|
      @unfilled_points << point if value.nil?
    end
    # Bit vectors would be a better choice for the below
    all_choices = Set.new(1..@length)
    @remaining_row_choices = (0...@length).map { |_| all_choices.dup }
    @remaining_column_choices = (0...@length).map { |_| all_choices.dup }
    @remaining_sector_choices = (0...@sectors_per_side).map do |_|
      (0...@sectors_per_side).map{ |_| all_choices.dup }
    end
    each_with_point do |value, point|
      next if value.nil?
      @remaining_row_choices[point.row].delete(value)
      @remaining_column_choices[point.column].delete(value)
      @remaining_sector_choices[point.row/@sector_length][point.column/@sector_length].delete(value)
    end
  end

  def each_with_point
    (0...@length).each do |row|
      (0...@length).each do |column|
        yield @board[row][column], Point.new(row, column)
      end
    end
  end

  def finished?
    @unfilled_points.empty?
  end

  def solved?
    finished?
  end

  def next_space
    most_constrained = nil
    most_constrained_choices = @length + 1
    @unfilled_points.each do |point|
      number_of_choices = possible_choices(point).size
      next unless number_of_choices < most_constrained_choices
      most_constrained = point
      most_constrained_choices = number_of_choices
    end
    most_constrained
  end

  def possible_choices(point)
    row_choices = @remaining_row_choices[point.row]
    column_choices = @remaining_column_choices[point.column]
    sector_choices = @remaining_sector_choices[point.row/@sector_length][point.column/@sector_length]
    row_choices & column_choices & sector_choices
  end

  def play(point, choice)
    raise StandardError, 'Already played' unless @board[point.row][point.column].nil?
    @board[point.row][point.column] = choice
    @unfilled_points.delete(point)
    @remaining_row_choices[point.row].delete(choice)
    @remaining_column_choices[point.column].delete(choice)
    @remaining_sector_choices[point.row/@sector_length][point.column/@sector_length].delete(choice)
  end

  def erase(point)
    previous_value = @board[point.row][point.column]
    raise StandardError, 'Not played' if previous_value.nil?
    @board[point.row][point.column] = nil
    @unfilled_points << point
    @remaining_row_choices[point.row].add(previous_value)
    @remaining_column_choices[point.column].add(previous_value)
    @remaining_sector_choices[point.row/@sector_length][point.column/@sector_length].add(previous_value)
  end

  def to_s
    puts @board.map { |row| row.map { |x| x || ' ' }.join(' ') }.join("\n")
  end
end

class Point
  attr_reader :row, :column
  def initialize(row, column)
    @row = row
    @column = column
  end

  def hash
    BOARD_LENGTH * @row + @column
  end

  def ==(other)
    @row == other.row && @column == other.column
  end

  alias :eql? :==
end

unless ARGV.length == 1
  puts 'Usage: ruby solve_sudoku.rb SUDOKU_FILE'
  exit 1
end
sudoku_file = ARGV[0]
main sudoku_file
