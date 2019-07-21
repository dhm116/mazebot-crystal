require "./edge"
require "./node"

class Graph
  getter node_hash : Hash(String, Node)
  property nodes : Array(Node)
  property edges : Array(Edge)

  def initialize
    @nodes = [] of Node
    @edges = [] of Edge
    @node_hash = {} of String => Node
  end

  def add_node(node : Node)
    @nodes << node
    node.graph = self
    @node_hash = {} of String => Node
    @nodes[-1]
  end

  def add_node(node : String, location : Coordinate = nil)
    self.add_node(Node.new(node, graph: self, location: location))
  end

  def add_edge(from : Node, to : Node, weight : Float64)
    @edges << Edge.new(from, to, weight)
  end

  def node_hash : Hash(String, Node)
    unless @node_hash.size > 0
      @node_hash = @nodes.index_by {|n| n.name}
    end
    @node_hash
  end
end
