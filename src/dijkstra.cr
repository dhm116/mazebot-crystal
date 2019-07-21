require "./edge"
require "./graph"
require "./node"
require "./priority_queue"

class Dijkstra
  getter distance_to : Hash(Node, Float64)

  def initialize(graph : Graph, source_node : Node)
    @graph = graph
    @source_node = source_node
    @path_to = {} of Node => Node
    @distance_to = {} of Node => Float64
    @pq = PriorityQueue(Node, Float64).new

    compute_shortest_path
  end

  def shortest_path_to(node : Node)
    # puts "Shortest path from #{@source_node.to_s} to #{node.to_s}"
    path = [] of Node
    while !node.nil? && node != @source_node
      path.unshift(node)
      # puts "\t@path_to has #{node.to_s}? #{@path_to.keys().includes?(node)}"
      node = @path_to.fetch(node, nil)
      # if node.nil?
      #   puts "Unable to find path entry for #{node.to_s}"
      # end
    end

    path.unshift(@source_node)
  end

  # This method will compute the shortest path from the source node to all the
  # other nodes in the graph.
  private def compute_shortest_path
    update_distance_of_all_edges_to(Float64::INFINITY)
    @distance_to[@source_node] = 0

    # The prioriy queue holds a node and its distance from the source node.
    @pq.insert(@source_node, 0.to_f64)
    while @pq.any?
      node = @pq.remove_min
      node.adjacent_edges.each do |adj_edge|
        relax(adj_edge)
      end
    end
  end

  def update_distance_of_all_edges_to(distance : Float64)
    @graph.nodes.each do |node|
      @distance_to[node] = distance
    end
  end

  # Edge relaxation basically means that we are checking if the shortest known
  # path to a given node is still valid (i.e. we didn't find an even
  # shorter path).
  def relax(edge : Edge)
    # puts "Relaxing #{edge.from.to_s} ---- #{edge.to.to_s}"
    return if @distance_to[edge.to] <= @distance_to[edge.from] + edge.weight

    if @distance_to[edge.from].infinite?
      @distance_to[edge.from] = 0
    end

    @distance_to[edge.to] = @distance_to[edge.from] + edge.weight
    @path_to[edge.to] = edge.from
    # puts "\t Updating distance to #{@distance_to[edge.to]}"

    # If the node is already in this priority queue, the only that happens is
    # that its distance is decreased.
    @pq.insert(edge.to, @distance_to[edge.to])
  end
end
