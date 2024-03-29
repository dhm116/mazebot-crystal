
module Mazebot
  class Dijkstra
    getter distance_to = Hash(Mazebot::Node, Float64).new

    def initialize(graph : Mazebot::Graph, source_node : Mazebot::Node)
      @graph = graph
      @source_node = source_node
      @path_to = {} of Mazebot::Node => Mazebot::Node
      @pq = Mazebot::PriorityQueue(Mazebot::Node, Float64).new

      compute_shortest_path
    end

    def shortest_path_to(node : Mazebot::Node)
      path = [] of Mazebot::Node
      while !node.nil? && node != @source_node
        path.unshift(node)
        node = @path_to.fetch(node, nil)
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
        node.neighbors.each do |neighbor, weight|
          relax(node, neighbor, weight.to_f)
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
    def relax(from : Mazebot::Node, to : Mazebot::Node, weight : Float64)
      return if @distance_to[to] <= @distance_to[from] + weight

      if @distance_to[from].infinite?
        @distance_to[from] = 0
      end

      @distance_to[to] = @distance_to[from] + weight
      @path_to[to] = from

      # If the node is already in this priority queue, the only that happens is
      # that its distance is decreased.
      @pq.insert(to, @distance_to[to])
    end
  end
end
