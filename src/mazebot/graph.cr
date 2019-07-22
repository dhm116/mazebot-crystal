module Mazebot
  class Graph
    getter node_hash : Hash(String, Mazebot::Node)
    property nodes : Array(Mazebot::Node)
    property edges : Array(Mazebot::Edge)

    def initialize
      @nodes = [] of Mazebot::Node
      @edges = [] of Mazebot::Edge
      @node_hash = {} of String => Mazebot::Node
    end

    def add_node(node : Mazebot::Node)
      @nodes << node
      node.graph = self
      @node_hash = {} of String => Mazebot::Node
      @nodes[-1]
    end

    def add_node(node : String, location : Mazebot::Coordinate = nil)
      self.add_node(Mazebot::Node.new(node, graph: self, location: location))
    end

    def add_edge(from : Mazebot::Node, to : Mazebot::Node, weight : Float64)
      @edges << Mazebot::Edge.new(from, to, weight)
    end

    def node_hash : Hash(String, Mazebot::Node)
      unless @node_hash.size > 0
        @node_hash = @nodes.index_by {|n| n.name}
      end
      @node_hash
    end
  end
end
