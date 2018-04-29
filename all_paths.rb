def main(graph_definition_file)
  graph_definition_string = open(graph_definition_file).read
  definition = parse(graph_definition_string)
  graph = Graph.new(definition[:edges], definition[:number_of_vertices])
  all_paths(graph, 0, 2)
end

def parse(graph_definition_string)
  lines = graph_definition_string.split("\n")
  number_of_vertices = lines.first.to_i
  edge_strings = lines.drop(1)
  edges = edge_strings.map { |s| s.split(',').map(&:to_i) }
  {
    number_of_vertices: number_of_vertices,
    edges: edges
  }
end

def all_paths(graph, start, finish)
  path_so_far = [nil] * graph.number_of_vertices
  path_so_far[0] = start
  depth_first_search(graph, finish, path_so_far, 1)
end

def depth_first_search(graph, finish, path_so_far, next_idx)
  last_vertex = path_so_far[next_idx - 1]
  if last_vertex == finish
    print_path(path_so_far[0...next_idx])
    return
  end
  graph.neighbours(last_vertex).each do |vertex|
    next if path_so_far[0...next_idx].include?(vertex)  # a set will make this faster
    path_so_far[next_idx] = vertex
    depth_first_search(graph, finish, path_so_far, next_idx + 1)
  end
end

def print_path(path)
  puts path.join(', ')
end

class Graph
  attr_reader :number_of_vertices
  def initialize(edges, number_of_vertices)
    @number_of_vertices = number_of_vertices
    @adjacency_list = []
    (0...number_of_vertices).each { @adjacency_list << [] }
    edges.each do |edge|
      first_vertex, second_vertex = edge
      @adjacency_list[first_vertex] << second_vertex
      @adjacency_list[second_vertex] << first_vertex
    end
  end

  def neighbours(vertex)
    @adjacency_list[vertex].dup
  end
end

unless ARGV.length == 1
  puts 'Usage: ruby all_paths.rb GRAPH_DEFINITION_FILE'
  exit 1
end

graph_definition_file = ARGV[0]
main(graph_definition_file)
