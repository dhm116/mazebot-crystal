module Mazebot
  class Graph
    getter node_hash : Hash(Mazebot::Point, Mazebot::Node)
    property nodes : Array(Mazebot::Node)
    property edges : Array(Mazebot::Edge)

    def initialize
      @nodes = [] of Mazebot::Node
      @edges = [] of Mazebot::Edge
      @node_hash = {} of Mazebot::Point => Mazebot::Node
    end

    # def add_node(value : Mazebot::Node)
    #   node = value
    #   unless node.graph === self
    #     node = Mazebot::Node.new(value.point, value.character, graph: self)
    #   end
    #   @nodes << node
    #   if @node_hash.size > 0
    #     @node_hash = {} of Mazebot::Point => Mazebot::Node
    #   end
    #   @nodes[-1]
    # end

    def add_node(point : Mazebot::Point, character : String | Char)
      node = Mazebot::Node.new(point, character, graph: self)
      @nodes << node
      if @node_hash.size > 0
        @node_hash = {} of Mazebot::Point => Mazebot::Node
      end
      @nodes[-1]
    end

    def add_edge(from : Mazebot::Node, to : Mazebot::Node, weight : Float64)
      @edges << Mazebot::Edge.new(from, to, weight)
    end

    def node_hash : Hash(Mazebot::Point, Mazebot::Node)
      unless @node_hash.size > 0
        @node_hash = @nodes.index_by {|n| n.point}
      end
      @node_hash
    end
  end
end
