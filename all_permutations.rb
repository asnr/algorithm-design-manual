
def all_permutations(set_size, current_permutation, already_in_permutation, next_idx)
  if next_idx == set_size
    print_permutation current_permutation
    return
  end
  (0..set_size).each do |value|
    next if already_in_permutation.include?(value)
    current_permutation[next_idx] = value
    already_in_permutation.add(value)
    all_permutations(set_size, current_permutation, already_in_permutation, next_idx + 1)
    already_in_permutation.delete(value)
  end
end

def print_permutation(current_permutation)
  puts "(#{current_permutation.join(', ')})"
end

class BitVector
  def initialize(size)
    raise Error
  end

  def add(n)
    raise Error
  end

  def delete(n)
    raise Error
  end

  def include?(n)
    raise Error
  end
end

unless ARGV.length == 1
  puts 'Usage: ruby all_permutations.rb set_size'
  exit 1
end

set_size = ARGV[0].to_i
permutation_array = [nil] * set_size
already_in_permutation = BitVector.new(set_size)
all_permutations(set_size, permutation_array, already_in_permutation, 0)
