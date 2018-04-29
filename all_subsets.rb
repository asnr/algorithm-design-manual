
def all_subsets(set_size, current_subset, next_idx)
  if next_idx == set_size
    print_subset current_subset
    return
  end
  [true, false].each do |include_element|
    current_subset[next_idx] = include_element
    all_subsets(set_size, current_subset, next_idx + 1)
  end
end

def print_subset(subset)
  print '{'
  first_element_to_print = true
  subset.each_with_index do |include_element, element|
    next unless include_element
    print ', ' unless first_element_to_print
    print element + 1
    first_element_to_print = false
  end
  puts '}'
end

unless ARGV.length == 1
  puts 'Usage: ruby all_subsets.rb set_size'
  exit 1
end
set_size = ARGV[0].to_i
all_subsets(set_size, [nil] * set_size, 0)
